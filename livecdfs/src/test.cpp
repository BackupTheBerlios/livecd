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
 * $Id: test.cpp,v 1.1 2004/01/18 15:47:52 jaco Exp $
 */

using namespace std;
 
#include <iostream>
#include <string.h>
 
#include <lufs/proto.h>
#include <lufs/fs.h>

#include "../lufs/lufsd/list.h"

#include "debug.h"

extern "C" {

extern void *livecdfs_init(struct list_head *cfg, struct dir_cache *cache, struct credentials *cred, void **global_ctx);
extern void livecdfs_free(void *fs);
extern int livecdfs_mount(void *fs);
extern void livecdfs_umount(void *fs);
extern int livecdfs_readdir(void *fs, char *name, struct directory *dir);
extern int livecdfs_stat(void *fs, char *name, struct lufs_fattr *attr);
extern int livecdfs_mkdir(void *fs, char *dir, int mode);
extern int livecdfs_rmdir(void *fs, char *dir);
extern int livecdfs_create(void *fs, char *file, int mode);
extern int livecdfs_unlink(void *fs, char *file);
extern int livecdfs_rename(void *fs, char *oldname, char *newname);
extern int livecdfs_open(void *fs, char *file, unsigned mode);
extern int livecdfs_release(void *fs, char *file);
extern int livecdfs_read(void *fs, char *file, long long offset, unsigned long count, char *buf);
extern int livecdfs_write(void *fs, char *file, long long offset, unsigned long count, char *buf);
extern int livecdfs_readlink(void *fs, char *link, char *buf, int buflen);
extern int livecdfs_link(void *fs, char *target, char *link);
extern int livecdfs_symlink(void *fs, char *target, char *link);
extern int livecdfs_setattr(void *fs, char *file, struct lufs_fattr *attr);

}

#define MOUNT_DOMAIN "MOUNT"
#define UNDERLAY_KEY "underlay"

struct s_option {
    char *key;
    char *value;
    struct list_head list;
};

struct s_domain {
    char *name;
    struct list_head properties;
    struct list_head list;
};

int 
main(int argc, char **argv)
{
	if (argc != 3) {
		ERROR("USAGE: " << argv[0] << " <mount> <underlay>");
		return -1;
	}
	
	struct list_head cfg;
	INIT_LIST_HEAD(&cfg);
	
	struct s_domain *d = (struct s_domain *)malloc(sizeof(struct s_domain));
	memset(d, 0, sizeof(struct s_domain));
	d->name = (char *)malloc(strlen(MOUNT_DOMAIN) + 1);
	strcpy(d->name, MOUNT_DOMAIN);
	INIT_LIST_HEAD(&d->properties);
	list_add(&d->list, &cfg);
	
	struct s_option *u = (struct s_option *)malloc(sizeof(struct s_option));
	u->key = (char *)malloc(strlen(UNDERLAY_KEY) + 1);
	u->value = (char *)malloc(strlen(argv[2]) + 1);
	strcpy(u->key, UNDERLAY_KEY);
	strcpy(u->value, argv[2]);
	list_add(&u->list, &d->properties);
	
	void *fs = NULL;
	if ((fs = livecdfs_init(&cfg, NULL, NULL, NULL)) != NULL) {
		livecdfs_mount(fs);
		livecdfs_umount(fs);
		livecdfs_free(fs);
		return 0;
	}
	else {
		ERROR("FATAL: Unable to create LiveCDFS instance");
		return -1;
	}
}
