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
 * $Id: livecdfs.cpp,v 1.3 2004/01/18 18:14:30 jaco Exp $
 */

#include <dirent.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
       
#include <vector>

#include "livecdfs.h"
#include "handles.h"
#include "path.h"

#include "debug.h"

LiveCDFS *
LiveCDFS::createLiveCDFS(struct list_head *cfg, 
			 struct dir_cache *cache, 
			 struct credentials *cred)
{
	FUNC("cfg="   << cfg   << ", " <<
	     "cache=" << cache << ", " <<
	     "cred="  << cred);
	
	const char *opt = lu_opt_getchar(cfg, "MOUNT", "ro_root");
	if (opt == NULL) {
		ERROR("FATAL: Please specify '-o ro_root=<point>', defining the ro root (underlay) as a mount option");
		return NULL;
	}
	string root = string(opt);
	
	opt = lu_opt_getchar(cfg, "MOUNT", "rw_tmp");
	if (opt == NULL) {
		ERROR("FATAL: Please specify '-o rw_tmp=<point>', defining the temporary rw workspace, as a mount option");
		return NULL;
	}
	string tmp = string(opt);

	Path *path = Path::createPath(root, tmp);
	return path ? new LiveCDFS(cfg, cache, cred, path) : NULL;
}


LiveCDFS::LiveCDFS(struct list_head *cfg, 
		   struct dir_cache *cache, 
		   struct credentials *cred,
		   Path *path) 
{
	FUNC("cfg="   << cfg   << ", "  <<
	     "cache=" << cache << ", "  <<
	     "cred="  << cred  << ", "  <<
	     "path="  << path);
	
	this->cfg = cfg;
	this->cache = cache;
	this->cred = cred;
	this->path = path;
	
	this->handles = new Handles();
}


LiveCDFS::~LiveCDFS() 
{
	FUNC("~destructor");
	
	delete path;
	delete handles;
}


int 
LiveCDFS::doMount()
{
	FUNC("");
	
	return 1;
}


void 
LiveCDFS::doUmount()
{
	FUNC("");
}


int 
LiveCDFS::doReaddir(char *name, 
		    struct directory *dir)
{
	FUNC("name='" << name << "', " <<
	     "dir="   << dir);
	
	if (path->isWhiteout(name)) {
		return -1;
	}
	
	DIR *rdir, *tdir;
	struct lufs_fattr attr;
	struct dirent *ent;
	
	string rootpath = path->mkroot(name);//path->mkpath(name);
	if (!Path::exists(rootpath, S_IFDIR) || !(rdir = opendir(rootpath.c_str()))) {
		WARN("could not open directory, name='" << name << "'");
		return -1;
	}
	
	string tmppath = path->mktmp(name);
	vector<string> entries;
	if ((tdir = opendir(tmppath.c_str()))) {
		while ((ent = readdir(tdir))) {
			TRACE("Adding direntry='" << ent->d_name << "'");
			string subpath = path->join(name, ent->d_name);
			if (!path->isWhiteout(subpath)) {
				if ((doStat(subpath.c_str(), &attr)) < 0) {
					WARN("could not stat file='" << ent->d_name << "'");
					closedir(tdir);
					closedir(rdir);
					return -1;
				}
				lu_cache_add2dir(dir, ent->d_name, NULL, &attr);
			}
			entries.push_back(subpath);
		}
		closedir(tdir);
	}
	
	while ((ent = readdir(rdir))){
		string subpath = path->join(name, ent->d_name);
		TRACE("Adding direntry='" << ent->d_name << "'");
		bool found = false;
		vector<string>::iterator i = entries.begin();
		while (!found && (i != entries.end())) {
			if (i->compare(subpath) == 0) { 
				found = true;
			} 
			i++;
		}
		if (!found && !path->isWhiteout(subpath)) {
			if ((doStat(subpath.c_str(), &attr)) < 0) {
				WARN("could not stat file='" << ent->d_name << "'");
				closedir(rdir);
				return -1;
			}
			lu_cache_add2dir(dir, ent->d_name, NULL, &attr);
		}
	}
	closedir(rdir);
	
	return 0;
}


int 
LiveCDFS::doStat(const char *name, 
		 struct lufs_fattr *attr)
{
	FUNC("name='" << name << "', " <<
	     "attr="  << attr);
	
	if (path->isWhiteout(name)) {
		return -1;
	}
	
	string fullpath = path->mkpath(name);
	struct stat stat;
	if (lstat(fullpath.c_str(), &stat) < 0) {
		WARN("Could not perform stat on file='" << name << "'");
		return -1;
	}

	attr->f_mode = stat.st_mode;
	attr->f_nlink = stat.st_nlink;
	attr->f_uid = stat.st_uid; 
	attr->f_gid = stat.st_gid;
	attr->f_size = stat.st_size;
	attr->f_atime = stat.st_atime;
	attr->f_mtime = stat.st_mtime;
	attr->f_ctime = stat.st_ctime;
	
	return 0;
}


int 
LiveCDFS::doReadlink(char *link, 
		     char *buf, 
		     int buflen)
{
	FUNC("link='"  << link       << "', " <<
	     "buf="    << PTR(buf)   << ", " <<
	     "buflen=" << DEC(buflen));
	
	string fullpath = path->mkpath(link);
	return readlink(fullpath.c_str(), buf, buflen);
}


int 
LiveCDFS::doOpen(char *file, 
		 unsigned mode)
{
	unsigned flags = mode ^ O_ACCMODE;
	unsigned modes = mode & O_ACCMODE;
	
	FUNC("file='" << file << "', " <<
	     "mode="  << mode << " (" <<
	     "modes=" << modes << ", " <<
	     "flags=" << flags);
	
	if (path->isWhiteout(file)) {
		return -1;
	}
	
	if (handles->find(file, flags, modes)) {
		TRACE("file='" << file << "' already open.");
		return 0;
	}
	
	string tmppath = path->mktmp(file);
	string openpath = string("");
	if (flags & O_CREAT) {
		// if we are creating a file, do so on the temp space
		TRACE("Creating empty file='" << file << "' on temp space");
		openpath = tmppath;
	}
	else if ((flags & O_RDWR) || (flags & O_WRONLY)) {
		struct stat buf;
		string rootpath = path->mkroot(file);
		if (path->exists(rootpath.c_str(), S_IFREG) || path->exists(rootpath.c_str(), S_IFLNK)) {
			if (!path->exists(tmppath.c_str(), 0)) {
				// doesn't already exist, copy-on-write
				path->copyTmp(file);
			}
			openpath = tmppath;
		}
		else if (path->exists(tmppath.c_str(), S_IFREG) || path->exists(tmppath.c_str(), S_IFLNK)) {
			openpath = tmppath;
		}
		else {
			ERROR("File, file='" << file << "', is not a regular file nor symlink, cannot create copy on temp space.");
			return -1;
		}
	}
	else {
		// normal read
		openpath = path->mkpath(file);
	}
	
	int fd = open(openpath.c_str(), flags, modes);
	if (fd <= 0) {
		WARN("Unable to open file='" << file << "', flags=" << flags << ", modes=" << modes);
		return -1;
	}
	handles->add(string(file), fd, flags, modes);
	TRACE(handles->size() << " files currently open.");
	
	return 0;
}


int 
LiveCDFS::doRelease(char *file)
{
	FUNC("file='" << file << "'");
	
	t_handle *handle;
	while ((handle = handles->find(file, 0xffff, 0xffff)) != NULL) {
		int fd = handle->fd;
		handles->erase((vector<t_handle>::iterator)handle);
		close(fd);
		TRACE("fd=" << fd << " for file='" << file << "' closed");
	}
	
	TRACE(handles->size() << " files currently open.");
	return 0;
}


int 
LiveCDFS::doRead(char *file, 
		 long long offset, 
		 unsigned long count, 
		 char *buf)
{
	FUNC("file='" << file        << "', " <<
	     "offset" << DEC(offset) << ", " <<
	     "count=" << DEC(count)  << ", " <<
	     "buf="   << PTR(buf));
	
	t_handle *handle = handles->find(file, O_RDWR, 0xffff);
	if (handle == NULL) {
		if ((handle = handles->find(file, O_RDONLY, 0xffff)) == NULL) {
			WARN("Redable handle for file='" << file << "' not found");
			return -1;
		}
	}
	
	if (lseek(handle->fd, offset, SEEK_SET) < 0) {
		WARN("Seek for file='" << file << "', fd=" << handle->fd << " failed");
		return -1;
	}

	return read(handle->fd, buf, count);
}


int 
LiveCDFS::doWrite(char *file, 
		  long long offset, 
		  unsigned long count, 
		  char *buf)
{
	FUNC("file='" << file        << "', " <<
	     "offset" << DEC(offset) << ", " <<
	     "count=" << DEC(count)  << ", " <<
	     "buf="   << PTR(buf));
	
	t_handle *handle = handles->find(file, O_RDWR, 0xffff);
	if (handle == NULL) {
		if ((handle = handles->find(file, O_WRONLY, 0xffff)) == NULL) {
			WARN("Writable handle for file='" << file << "' not found");
			return -1;
		}
	}
	
	if (lseek(handle->fd, offset, SEEK_SET) < 0) {
		WARN("Seek for file='" << file << "', fd=" << handle->fd << " failed");
		return -1;
	}
	
	return write(handle->fd, buf, count);
}


int 
LiveCDFS::doMkdir(char *dir, 
		  int mode)
{
	FUNC("dir='"  << dir  << "', " <<
	     "mode=" << mode);
	
	return -1;
}


int 
LiveCDFS::doRmdir(char *dir)
{
	FUNC("dir='" << dir << "'");

	return -1;
}


int 
LiveCDFS::doUnlink(char *file)
{
	FUNC("file='" << file << "'");
	
	return -1;
}


int 
LiveCDFS::doCreate(char *file, 
		   int mode)
{
	FUNC("file='" << file << "', " <<
	     "mode=" << mode);
	
	if (path->isWhiteout(file)) {
		return -1;
	}
	
	int fd = open(path->mktmp(file).c_str(), O_WRONLY | O_CREAT | O_TRUNC, mode);
	if (fd > 0) {
		close(fd);
	}
	return fd;
}


int 
LiveCDFS::doRename(char *oldname, 
		   char *newname)
{
	FUNC("old='" << oldname << "', " <<
	     "new='" << newname << "'");
	
	return -1;
}


int 
LiveCDFS::doLink(char *target, 
		 char *link)
{
	FUNC("target='" << target << "', " <<
	     "link='"   << link) << "'";
	
	return -1;
}


int 
LiveCDFS::doSymlink(char *target, 
		    char *link)
{
	FUNC("target='" << target << "', " <<
	     "link='"   << link << "'");
	
	return -1;
}


int 
LiveCDFS::doSetattr(char *file, 
		    struct lufs_fattr *attr)
{
	FUNC("file='" << file << "', " <<
	     "attr=" << attr);
	
	return -1;
}
