/*
 * message.c
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
#include <string.h>
#include <time.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/socket.h>

#include <lufs/proto.h>
#include <lufs/fs.h>

#include "message.h"

int
lu_check_to(int rd_fd, int wr_fd, int time_out){
    fd_set rd, wr;
    int res, maxfd = 0;
    struct timeval tv;

    FD_ZERO(&rd);
    FD_ZERO(&wr);

    if(rd_fd){
	FD_SET(rd_fd, &rd);
	maxfd = rd_fd > maxfd ? rd_fd : maxfd;
    }

    if(wr_fd){
	FD_SET(wr_fd, &wr);
	maxfd = wr_fd > maxfd ? wr_fd : maxfd;
    }

    tv.tv_sec = time_out;
    tv.tv_usec = 0;

    do{
	res = select(maxfd + 1, &rd, &wr, NULL, &tv);

    }while((res < 0) && (errno == EINTR));    

    if(res > 0)
	return 0;

    if(res < 0){
	    WARN("select call failed: %s", strerror(errno));
	    return -errno;
    }
       
    WARN("operation timed out!");

    return -ETIMEDOUT;
}

int
lu_atomic_read(int fd, char *buf, int len, int time_out){
    int res, offset = 0;

    do{
	if((time_out) && ((res = lu_check_to(fd, 0, time_out)) < 0))
	    return res;

	do{
	    res = read(fd, buf + offset, len - offset);
	}while((res < 0) && (errno == EINTR));

	if(res <= 0){
	    WARN("read call failed: %s", strerror(errno));
	    return (res < 0) ? -errno : (offset > 0 ? offset : -EPIPE);
	}

	offset += res;

    }while(offset < len);

    return offset;
}

int
lu_atomic_write(int fd, char *buf, int len, int time_out){
    int res, offset = 0;

    do{
	if((time_out) && ((res = lu_check_to(0, fd, time_out)) < 0))
	    return res;

	do{
	    res = write(fd, buf + offset, len - offset);
	}while((res < 0) && (errno == EINTR));

	if(res <= 0){
	    WARN("write call failed: %s", strerror(errno));
	    return (res < 0) ? -errno : (offset > 0 ? offset : -EPIPE);
	}

	offset += res;

    }while(offset < len);

    return offset;
}

struct message*
lu_recvmsg(struct message *msg, int sock){

    msg->m_data = msg->m_buffer;

    if(lu_atomic_read(sock, (char*)&msg->m_hdr, sizeof(struct lu_msg), 0) < 0){
	WARN("recv failed");
	return NULL;
    }

    if(msg->m_hdr.msg_datalen){
	if(msg->m_hdr.msg_datalen > MAX_DATA){
	    ERROR("message too long: %u bytes", msg->m_hdr.msg_datalen);
	    return NULL;
	}
	
	if(lu_atomic_read(sock, msg->m_data, msg->m_hdr.msg_datalen, 0) < 0){
	    WARN("recv failed");
	    return NULL;
	}
    }

    return msg;
}

int
lu_sendmsg(struct message *msg, int sock){

    if(lu_atomic_write(sock, (char*)&msg->m_hdr, sizeof(struct lu_msg), 0) < 0){
	WARN("send failed");
	return -1;
    }

    if((msg->m_hdr.msg_datalen) && (lu_atomic_write(sock, msg->m_data, msg->m_hdr.msg_datalen, 0) < 0)){
	WARN("send failed");
	return -1;
    }
    
    return 0;
}

struct message*
lu_makemsg(struct message *msg, unsigned short type, char *data, unsigned short len){
    
    msg->m_hdr.msg_type = type;
    msg->m_hdr.msg_version = PVERSION;
    msg->m_hdr.msg_datalen = len;
    msg->m_hdr.msg_pid = getpid();
    
    if(data)
	msg->m_data = data;
    else
	msg->m_data = msg->m_buffer;

    return msg;
}

