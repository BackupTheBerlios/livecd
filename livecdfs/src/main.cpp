/*
 * LiveCD UnionFS implementation
 * Copyright (C) 2004, Jaco Greeff <jaco@linuxminicd.org>
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * The latest version of this file can be found at http://livecd.berlios.de
 *
 * $Id: main.cpp,v 1.4 2004/01/25 14:28:11 jaco Exp $
 */
 
#include <lufs/proto.h>
#include <lufs/fs.h>

#include "livecdfs.h"

#include "debug.h"

extern "C"{

void *
livecdfs_init(struct list_head *cfg, 
	      struct dir_cache *cache, 
	      struct credentials *cred, 
	      void **global_ctx)
{
	FUNC("cfg=%p, cache=%p, cred=%p, global_ctx=%p", cfg, cache, cred, global_ctx);
	
	TRACE_START();    
	void *fs = (void *)LiveCDFS::create(cfg, cache, cred);
	TRACE("create(...)=%p", fs);
	TRACE_RET(fs);
}


void 
livecdfs_free(void *fs)
{
	FUNC("fs=%p", fs);
	
	TRACE_START();
	LiveCDFS::destroy((LiveCDFS*)fs);
	TRACE_END();
}


int 
livecdfs_mount(void *fs)
{
	FUNC("fs=%p", fs);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doMount();
	TRACE("(fs=%p)->doMount()=%d", fs, ret);
	TRACE_RET(ret);
}


void 
livecdfs_umount(void *fs)
{
	FUNC("fs=%p", fs);
	
	TRACE_START();
	((LiveCDFS*)fs)->doUmount();
	TRACE_END();
}


int 
livecdfs_readdir(void *fs, 
		 char *name, 
		 struct directory *dir)
{
	FUNC("fs=%p, name='%s', dir=%p", fs, name, dir);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doReaddir(name, dir);
	TRACE("(fs=%p)->doReaddir(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_stat(void *fs, 
	      char *name, 
	      struct lufs_fattr *attr)
{
	FUNC("fs=%p, name='%s', attr=%p", fs, name, attr);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doStat(name, attr);
	TRACE("(fs=%p)->doStat(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_mkdir(void *fs, 
	       char *dir, 
	       int mode)
{
	FUNC("fs=%p, dir='%s', mode=%u", fs, dir, mode);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doMkdir(dir, mode);
	TRACE("(fs=%p)->doMkdir(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_rmdir(void *fs, 
	       char *dir)
{
	FUNC("fs=%p, dir='%s'", fs, dir);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRmdir(dir);
	TRACE("(fs=%p)->doRmdir(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_create(void *fs, 
		char *file, 
		int mode)
{
	FUNC("fs=%p, file='%s', mode=%u", fs, file, mode);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doCreate(file, mode);
	TRACE("(fs=%p)->doCreate(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_unlink(void *fs, 
		char *file)
{
	FUNC("fs=%p, file='%s'", fs, file);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doUnlink(file);
	TRACE("(fs=%p)->doUnlink(...)=%d", ret);
	TRACE_RET(ret);
}


int 
livecdfs_rename(void *fs, 
		char *oldname, 
		char *newname)
{
	FUNC("fs=%p, old='%s', new='%s'", fs, oldname, newname);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRename(oldname, newname);
	TRACE("(fs=%p)->doRename(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_open(void *fs, 
	      char *file, 
	      unsigned mode)
{
	FUNC("fs=%p, file='%s', mode=%u", fs, file, mode);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doOpen(file, mode);
	TRACE("(fs=%p)->doOpen(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_release(void *fs, 
		 char *file)
{
	FUNC("fs=%p, file='%s'", fs, file);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRelease(file);
	TRACE("(fs=%p)->doRelease(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_read(void *fs, 
	      char *file, 
	      long long offset, 
	      unsigned long count, 
	      char *buf)
{
	FUNC("fs=%p, file='%s', offset=%l, count=%ul, buf=%p", fs, file, offset, count, buf);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRead(file, offset, count, buf);
	TRACE("(fs=%p)->doRead(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_write(void *fs, 
	       char *file, 
	       long long offset, 
	       unsigned long count, 
	       char *buf)
{
	FUNC("fs=%p, file='%s', offset=%l, count=%ul, buf=%p", fs, file, offset, count, buf);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doWrite(file, offset, count, buf);
	TRACE("(fs=%p)->doWrite(...)=", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_readlink(void *fs, 
		  char *link, 
		  char *buf, 
		  int buflen)
{
	FUNC("fs=%p, link='%s', buf=%p, buflen=%u", fs, link, buf, buflen);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doReadlink(link, buf, buflen);
	TRACE("(fs=%pdoReadlink(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_link(void *fs, 
	      char *target, 
	      char *link)
{
	FUNC("fs=%p, target='%s', link='%s'", fs, target, link);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doLink(target, link);
	TRACE("(fs=%p)->doLink(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_symlink(void *fs, 
		 char *target, 
		 char *link)
{
	FUNC("fs=%p, target='%s', link='%s'", fs, target, link);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doSymlink(target, link);
	TRACE("(fs=%p)->doSymlink(...)=%d", fs, ret);
	TRACE_RET(ret);
}


int 
livecdfs_setattr(void *fs, 
		 char *file, 
		 struct lufs_fattr *attr)
{
	FUNC("fs=%p, file='%s', attr=%p", fs, file, attr);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doSetattr(file, attr);
	TRACE("(fs=%p)->doSetattr(...)=%d", fs, ret);
	TRACE_RET(ret);
}

}
