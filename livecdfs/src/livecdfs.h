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
 * $Id: livecdfs.h,v 1.5 2004/01/23 17:56:05 jaco Exp $
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
#include "whiteout.h"

class LiveCDFS;

typedef struct active_livecdfs 
{
	string root;
	string tmp;
	int count;
	LiveCDFS *fs;
} t_active_livecdfs;

class LiveCDFS
{
private:
	struct credentials *cred;
	struct dir_cache *cache;
	struct list_head *cfg;
	
	Path *path;
	Whiteout *whiteout;
	Handles *handles;

	static vector<t_active_livecdfs> activefs;
	
	static t_active_livecdfs *findActive(const string &, const string &);
	static t_active_livecdfs *findActive(const LiveCDFS *);
	
public:
	static LiveCDFS *create(struct list_head *, 
				struct dir_cache *, 
				struct credentials *);
				
	static void destroy(LiveCDFS *fs);
	
	LiveCDFS(struct list_head *, 
		 struct dir_cache *, 
		 struct credentials *,
		 Path *,
		 Whiteout *);
	~LiveCDFS();
	
	int doMount();
	void doUmount();
	int doReaddir(const char *, struct directory *);
	int doStat(const char *, struct lufs_fattr *);
	int doReadlink(const char *, char *, int);
	int doOpen(const char *, unsigned);
	int doRelease(const char *);
	int doRead(const char *, long long, unsigned long, char *);
	int doWrite(const char *, long long, unsigned long, char *);
	int doMkdir(const char *, int);
	int doRmdir(const char *);
	int doUnlink(const char *);
	int doCreate(const char *, int);
	int doRename(const char *, const char *);
	int doSetattr(const char *, struct lufs_fattr *);
	int doLink(const char *, const char *);
	int doSymlink(const char *, const char *);
};

#endif
