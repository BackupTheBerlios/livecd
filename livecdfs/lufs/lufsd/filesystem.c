/*
 * filesystem.c
 * Copyright (C) 2002 Florin Malita <mali@go.ro>
 *
 * This file is part of LUFS, a free userspace filesystem implementation.
 * See http://lufs.sourceforge.net/ for updates.
 *
 * LUFS is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * LUFS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <dirent.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#include <lufs/proto.h>
#include <lufs/fs.h>

#include "list.h"
#include "message.h"
#include "dircache.h"
#include "filesystem.h"



static struct message*
generic_umount(struct file_system *fs, struct message *msg){
    TRACE("unmounting this filesystem");

    if(!fs->fs_ops->umount)
	return NULL;

    fs->fs_ops->umount(fs->fs_context);
    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_readdir(struct file_system *fs, struct message *msg){
    struct lufs_req_readdir *req;
    struct directory *dir;
    struct message *res;
    
    if(!fs->fs_ops->readdir)
	return NULL;

    req = (struct lufs_req_readdir*)msg->m_data;

    TRACE("readdir %s, offset %d",req->dirname, req->offset);
    
    if(lu_cache_readdir(fs->fs_cache, req->dirname, req->offset, fs->fs_buf, LU_MAXDATA) < 0){
	if(!(dir = lu_cache_mkdir(req->dirname)))
	    return NULL;

	if(fs->fs_ops->readdir(fs->fs_context, req->dirname, dir) < 0){
	    lu_cache_killdir(dir);
	    return NULL;
	}

	lu_cache_add_dir(fs->fs_cache, dir);
	
	if(lu_cache_readdir(fs->fs_cache, req->dirname, req->offset, fs->fs_buf, LU_MAXDATA) < 0){
	    WARN("could not read directory!");
	    return NULL;
	}

    }

    res = lu_makemsg(&fs->fs_msg, PTYPE_OK, fs->fs_buf, strlen(fs->fs_buf) + 1);
    return res;
}

static struct message*
generic_illegal(struct file_system *fs, struct message *msg){
    WARN("Illegal message type: %d", msg->m_hdr.msg_type);
    return NULL;
}

static struct message*
generic_read(struct file_system *fs, struct message *msg){
    struct lufs_req_rw *req;
    struct message *res;
    int r;
    
    if(!fs->fs_ops->read)
	return NULL;

    req = (struct lufs_req_rw*)msg->m_data;
    TRACE("read");
    TRACE("read %s, offset= %Ld, count= %d", req->name, req->offset, (int)req->count);
    
    if((r = fs->fs_ops->read(fs->fs_context, req->name, req->offset, req->count, fs->fs_buf)) < 0){
	TRACE("read failed\n");
	res = NULL;
    }else{
	if((unsigned)r < req->count)
	    memset(fs->fs_buf + r, 0, req->count - r);
	res = lu_makemsg(&fs->fs_msg, PTYPE_OK, fs->fs_buf, req->count);
    }
    return res;
}

static struct message*
generic_write(struct file_system *fs, struct message *msg){
    struct lufs_req_rw *req;
    char *buf;
    struct message *res;

    if(!fs->fs_ops->write)
	return NULL;

    req = (struct lufs_req_rw*)msg->m_data;
    buf = req->name + strlen(req->name) + 1;

    TRACE("write %s, offset=%Ld, count=%d", req->name, req->offset, (int)req->count);

    if(fs->fs_ops->write(fs->fs_context, req->name, req->offset, req->count, buf) < 0){
	TRACE("write failed\n");
	res = NULL;
    }else
	res = lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);

    return res;
}

static struct message*
generic_stat(struct file_system *fs, struct message *msg){
    struct lufs_fattr *fattr = (struct lufs_fattr*)fs->fs_buf;

    if(!fs->fs_ops->stat)
	return NULL;

    TRACE("stat %s", msg->m_data);

    memset(fattr, 0, sizeof(struct lufs_fattr));

    if(lu_cache_lookup_file(fs->fs_cache, msg->m_data, fattr, NULL, 0) < 0){
	TRACE("lookup failed on master");

	if(strlen(msg->m_data) <= 1)
	    sprintf(msg->m_data, "/.");

	if(fs->fs_ops->stat(fs->fs_context, msg->m_data , fattr) < 0){
	    TRACE("do_stat failed too");
	    return NULL;
	}
    }

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, (char*)fattr, sizeof(struct lufs_fattr));
}

static struct message*
generic_mkdir(struct file_system *fs, struct message *msg){
    struct lufs_req_mkdir *req;


    if(!fs->fs_ops->mkdir)
	return NULL;

    TRACE("mkdir");

    req = (struct lufs_req_mkdir*)msg->m_data;
    
    if(fs->fs_ops->mkdir(fs->fs_context, req->dirname, req->mode) < 0){
	TRACE("mkdir failed!");
	return NULL;
    }

    lu_cache_invalidate(fs->fs_cache, req->dirname);

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_rmdir(struct file_system *fs, struct message *msg){
    
    if(!fs->fs_ops->rmdir)
	return NULL;

    TRACE("rmdir");

    if(fs->fs_ops->rmdir(fs->fs_context, msg->m_data) < 0){
	TRACE("rmdir failed!");
	return NULL;
    }

    lu_cache_invalidate(fs->fs_cache, msg->m_data);

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_create(struct file_system *fs, struct message *msg){
    struct lufs_req_mkdir *req;

    if(!fs->fs_ops->create)
	return NULL;

    TRACE("create");

    req = (struct lufs_req_mkdir*)msg->m_data;
    
    if(fs->fs_ops->create(fs->fs_context, req->dirname, req->mode) < 0){
	TRACE("create failed!");
	return NULL;
    }
    
    lu_cache_invalidate(fs->fs_cache, req->dirname);

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_unlink(struct file_system *fs, struct message *msg){

    if(!fs->fs_ops->unlink)
	return NULL;

    TRACE("unlink");

    if(fs->fs_ops->unlink(fs->fs_context, msg->m_data) < 0){
	TRACE("unlink failed!");
	return NULL;
    }

    lu_cache_invalidate(fs->fs_cache, msg->m_data);

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_rename(struct file_system *fs, struct message *msg){

    if(!fs->fs_ops->rename)
	return NULL;

    TRACE("old: %s, new: %s", msg->m_data, msg->m_data + strlen(msg->m_data) + 1);

    if(fs->fs_ops->rename(fs->fs_context, msg->m_data, msg->m_data + strlen(msg->m_data) + 1) < 0){
	TRACE("rename failed!");
	return NULL;
    }

    lu_cache_invalidate(fs->fs_cache, msg->m_data);
    lu_cache_invalidate(fs->fs_cache, msg->m_data + strlen(msg->m_data) + 1);

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_open(struct file_system *fs, struct message *msg){
    struct lufs_req_open *req;

    if(!fs->fs_ops->open)
	return NULL;

    TRACE("open");
    
    req = (struct lufs_req_open*)msg->m_data;

    if(fs->fs_ops->open(fs->fs_context, req->name, req->mode) < 0){
	TRACE("open failed!");
	return NULL;
    }

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_release(struct file_system *fs, struct message *msg){

    if(!fs->fs_ops->release)
	return NULL;

    TRACE("release");

    if(fs->fs_ops->release(fs->fs_context, msg->m_data) < 0){
	TRACE("release failed!");
	return NULL;
    }

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}


static struct message*
generic_readlink(struct file_system *fs, struct message *msg){
    struct lufs_fattr fattr;
    int len;

    if(!fs->fs_ops->readlink)
	return NULL;

    TRACE("readlink %s", msg->m_data);
    
    /* try to get the link target from dircache first */
    if(lu_cache_lookup_file(fs->fs_cache, msg->m_data, &fattr, fs->fs_buf, LU_MAXDATA) < 0)
	goto def;

    if(strcmp(fs->fs_buf, "")){
	TRACE("link target found in dircache.");
	return lu_makemsg(&fs->fs_msg, PTYPE_OK, fs->fs_buf, strlen(fs->fs_buf) + 1);
    }
	

def:

    if((len = fs->fs_ops->readlink(fs->fs_context, msg->m_data, fs->fs_buf, LU_MAXDATA)) < 0){
	TRACE("readlink failed!");
	return NULL;
    }
    
    fs->fs_buf[len++] = 0;
    
    return lu_makemsg(&fs->fs_msg, PTYPE_OK, fs->fs_buf, len);
}

static struct message*
generic_link(struct file_system *fs, struct message *msg){

    if(!fs->fs_ops->link)
	return NULL;

    TRACE("link %s %s", msg->m_data, &msg->m_data[strlen(msg->m_data)+1]);

    if(fs->fs_ops->link(fs->fs_context, msg->m_data, &msg->m_data[strlen(msg->m_data) + 1]) < 0){
	TRACE("link failed!");
	return NULL;
    }
    
    lu_cache_invalidate(fs->fs_cache, msg->m_data);
    lu_cache_invalidate(fs->fs_cache, &msg->m_data[strlen(msg->m_data) + 1]);
    
    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_symlink(struct file_system *fs, struct message *msg){

    if(!fs->fs_ops->symlink)
	return NULL;

    TRACE("symlink %s %s", msg->m_data, &msg->m_data[strlen(msg->m_data)+1]);

    if(fs->fs_ops->symlink(fs->fs_context, &msg->m_data[strlen(msg->m_data) + 1], msg->m_data) < 0){
	TRACE("symlink failed!");
	return NULL;
    }

    lu_cache_invalidate(fs->fs_cache, msg->m_data);

    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}

static struct message*
generic_setattr(struct file_system *fs, struct message *msg){
    struct lufs_req_setattr *req = (struct lufs_req_setattr*)msg->m_data;

    if(!fs->fs_ops->setattr)
	return NULL;

    TRACE("setattr %s", req->name);

    if(fs->fs_ops->setattr(fs->fs_context, req->name, &req->fattr) < 0){
	TRACE("setattr failed!");
	return NULL;
    }
    
    lu_cache_invalidate(fs->fs_cache, req->name);
    
    return lu_makemsg(&fs->fs_msg, PTYPE_OK, NULL, 0);
}


void
handle_fs(struct file_system *fs, int sock, pid_t pid){
    struct message *msg, *rep;
    struct message* (*handlers[PTYPE_MAX + 1])(struct file_system*, struct message*);

    handlers[0] = generic_illegal; 	// PTYPE_OK
    handlers[1] = generic_illegal; 	// PTYPE_MOUNT
    handlers[2] = generic_read;		// PTYPE_READ
    handlers[3] = generic_write;   	// PTYPE_WRITE
    handlers[4] = generic_readdir; 	// PTYPE_READDIR
    handlers[5] = generic_stat;    	// PTYPE_STAT
    handlers[6] = generic_umount;  	// PTYPE_UMOUNT
    handlers[7] = generic_setattr;	// PTYPE_SETATTR
    handlers[8] = generic_mkdir;   	// PTYPE_MKDIR
    handlers[9] = generic_rmdir;   	// PTYPE_RMDIR
    handlers[10] = generic_create;	// PTYPE_CREATE
    handlers[11] = generic_unlink; 	// PTYPE_UNLINK
    handlers[12] = generic_rename; 	// PTYPE_RENAME
    handlers[13] = generic_open;   	// PTYPE_OPEN
    handlers[14] = generic_release;     // PTYPE_RELEASE
    handlers[15] = generic_readlink;    // PTYPE_READLINK
    handlers[16] = generic_link;        // PTYPE_LINK
    handlers[17] = generic_symlink;	// PTYPE_SYMLINK

    if(!fs->fs_mounted){
	TRACE("connecting the slot...");

	if(!fs->fs_ops->mount(fs->fs_context)){
	    WARN("couldn't connect!");
	    return;
	}
    }

    signal(SIGPIPE, SIG_IGN);

    TRACE("entering I/O loop...");
    
    for(;;){
	msg = lu_recvmsg(&fs->fs_msg, sock);

	if(!msg){
	    TRACE("oops, my kernel pair disconnected");
	    return;
	}

	rep = NULL;
	if(msg->m_hdr.msg_type <= PTYPE_MAX){
	    rep = (handlers[msg->m_hdr.msg_type])(fs, msg);
	}

	if(!rep){
	    TRACE("operation failed, sending error reply...");
	    rep = lu_makemsg(&fs->fs_msg, PTYPE_ERROR, NULL, 0);
	}

	lu_sendmsg(rep, sock);
    }

}



