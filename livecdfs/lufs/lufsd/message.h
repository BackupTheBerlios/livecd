/*
 * message.h
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

#ifndef _MESSAGE_H_
#define _MESSAGE_H_

#define MAX_DATA	LU_MAXDATA*2

struct lu_msg;

struct message{
    struct lu_msg	m_hdr;
    char		*m_data;
    char		m_buffer[MAX_DATA];
};


int lu_sendmsg(struct message*, int);
struct message* lu_recvmsg(struct message*, int);
struct message* lu_makemsg(struct message*, unsigned short, char*, unsigned short); 

#endif
