/*
 * filesystem.h
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

#ifndef _FILESYSTEM_H_
#define _FILESYSTEM_H_

struct fs_operations{
    void	*(*init)(struct list_head*, struct dir_cache*, struct credentials*, void**);
    void	(*free)(void*);
    int 	(*mount)(void*);
    void 	(*umount)(void*);
    int 	(*readdir)(void*, char*, struct directory*);
    int 	(*stat)(void*, char*, struct lufs_fattr*);
    int 	(*mkdir)(void*, char*, int);
    int 	(*rmdir)(void*, char*);
    int 	(*create)(void*, char*, int);
    int 	(*unlink)(void*, char*);
    int 	(*rename)(void*, char*, char*);
    int 	(*open)(void*, char*, unsigned);
    int 	(*release)(void*, char*);
    int 	(*read)(void*, char*, long long, unsigned long, char*);
    int		(*write)(void*, char*, long long, unsigned long, char*);
    int 	(*readlink)(void*, char*, char*, int);
    int 	(*link)(void*, char*, char*);
    int 	(*symlink)(void*, char*, char*);
    int 	(*setattr)(void*, char*, struct lufs_fattr*);
};

struct file_system{
    struct message		fs_msg;
    struct fs_operations	*fs_ops;
    struct credentials		*fs_credentials;
    struct list_head		*fs_config;
    struct dir_cache   		*fs_cache;
    void			*fs_context;
    int				fs_mounted;
    char			fs_buf[LU_MAXDATA];
};


void handle_fs(struct file_system*, int, pid_t);

#endif

