/*
 * fsctl.h
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

#ifndef _FSCTL_H_
#define _FSCTL_H_

struct fs_operations;
struct file_system;

struct thread_info{
    struct file_system	*fs;
    int			sock;
    pid_t		ppid;
};

struct fs_ctl{
    struct credentials 		cred;
    struct fs_operations 	*fs_ops;
    struct file_system 		*fs_available;
    struct dir_cache 		*cache;
    struct list_head 		*cfg;
    void 			*dlhandle;
    void			*global_ctx;
};


struct fs_ctl *lu_fsctl_create(struct list_head*);
void lu_fsctl_destroy(struct fs_ctl*);
void lu_fsctl_run(struct fs_ctl*, int, char*);
int lu_fsctl_mount(struct fs_ctl*);

#endif



