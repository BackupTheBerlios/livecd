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
 * $Id: livecdfs.h,v 1.1 2004/01/18 15:47:52 jaco Exp $
 */

#ifndef _LIVECDFS_dot_H_
#define _LIVECDFS_dot_H_

using namespace std;

#include <string>
#include <vector>

#include <lufs/proto.h>
#include <lufs/fs.h>

#include "handles.h"
#include "path.h"

class LiveCDFS
{
private:
	struct credentials *cred;
	struct dir_cache *cache;
	struct list_head *cfg;
	
	Path *path;
	Handles *handles;

public:
	static LiveCDFS *createLiveCDFS(struct list_head *, 
					struct dir_cache *, 
					struct credentials *);
					
	LiveCDFS(struct list_head *, 
		 struct dir_cache *, 
		 struct credentials *,
		 Path *);
	~LiveCDFS();
	
	int doMount();
	void doUmount();
	int doReaddir(char *, struct directory *);
	int doStat(const char *, struct lufs_fattr *);
	int doReadlink(char *, char *, int);
	int doOpen(char *, unsigned);
	int doRelease(char *);
	int doRead(char *, long long, unsigned long, char *);
	int doWrite(char *, long long, unsigned long, char *);
	int doMkdir(char *, int);
	int doRmdir(char *);
	int doUnlink(char *);
	int doCreate(char *, int);
	int doRename(char *, char *);
	int doSetattr(char *, struct lufs_fattr *);
	int doLink(char *, char *);
	int doSymlink(char *, char *);
};

#endif
