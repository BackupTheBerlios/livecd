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
 * $Id: livecdfs.cpp,v 1.8 2004/01/22 08:32:42 jaco Exp $
 */

#include <dirent.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>
#include <utime.h>
       
#include <vector>

#include "livecdfs.h"
#include "handles.h"
#include "path.h"

#include "debug.h"

LiveCDFS *
LiveCDFS::create(struct list_head *cfg, 
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

	Path *path = Path::create(root, tmp);
	Whiteout *wo = Whiteout::create(tmp);
	return ((path != NULL) && (wo != NULL)) ? new LiveCDFS(cfg, cache, cred, path, wo) : NULL;
}


LiveCDFS::LiveCDFS(struct list_head *cfg, 
		   struct dir_cache *cache, 
		   struct credentials *cred,
		   Path *path,
		   Whiteout *whiteout) 
{
	FUNC("cfg="   << cfg   << ", "  <<
	     "cache=" << cache << ", "  <<
	     "cred="  << cred  << ", "  <<
	     "path="  << path);
	
	this->cfg = cfg;
	this->cache = cache;
	this->cred = cred;
	
	this->path = path;
	this->whiteout = whiteout;
	
	this->handles = new Handles();
}


LiveCDFS::~LiveCDFS() 
{
	FUNC("~destructor");
	
	delete path;
	delete whiteout;
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
	
	if (!whiteout->isVisible(name)) {
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
			if (whiteout->isVisible(subpath)) {
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
		if (!found) {
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
	
	if (!whiteout->isVisible(name)) {
		return -1;
	}
	
	string fullpath = path->mkpath(name);
	struct stat stat;
	if (lstat(fullpath.c_str(), &stat) < 0) {
		WARN("Could not perform stat on file='" << name << "'");
		return -1;
	}

	TRACE("name='"        << name         << "', " << std::dec <<
	      "stat.st_uid="  << stat.st_uid  << ", " <<
	      "stat.st_uid="  << stat.st_uid  << ", " <<
	      "stat.st_size=" << stat.st_size);
	      
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
	
	if (!whiteout->isVisible(link)) {
		return -1;
	}
	
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
	
	if (!whiteout->isVisible(file)) {
		return -1;
	}
	
	if (handles->find(file, flags, modes)) {
		TRACE("file='" << file << "' already open.");
		return 0;
	}
	
	bool created = false;
	string tmppath = path->mktmp(file);
	string openpath = string("");
	if (flags & O_CREAT) {
		// if we are creating a file, do so on the temp space
		TRACE("Creating empty file='" << file << "' on temp space");
		openpath = tmppath;
		created = true;
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
	else if (created) {
		whiteout->setVisible(file, true);
	}
	
	// We don't really use the opened handle since lufs currently doesn't
	// describe the concept of a handle. This creates problems in doRead, 
	// doWrite and doRelease where the only information passed is the 
	// actual filename (what happens if multiples are open???) So, we take
	// the completely unoptimal (slow) approach in opening the file again in 
	// doRead and doWrite (When an elegant work-around is in place, we can
	// use the handles infrastructure, currently it only indicates the number
	// of files we are budy with.)
	close(fd);
	handles->add(string(file), fd, flags, modes);
	TRACE(handles->size() << " files currently open.");
	
	return 0;
}


int 
LiveCDFS::doRelease(char *file)
{
	FUNC("file='" << file << "'");
	
	t_handle *handle;
	if ((handle = handles->find(file, 0xffff, 0xffff)) != NULL) {
		int fd = handle->fd;
		handles->erase((vector<t_handle>::iterator)handle);
		TRACE("fd=" << fd << " for file='" << file << "' released");
	}
	else {
		WARN("Unable to find open handle for file='" << file << "'");
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
	
	int fd = open(path->mkpath(file).c_str(), O_RDWR);
	if (fd <= 0) {
		WARN("Cannot open file='" << file << "' O_RDWR");
		return -1;
	}
	
	if (lseek(fd, offset, SEEK_SET) < 0) {
		WARN("Seek for file='" << file << "', fd=" << fd << " failed");
		close(fd);
		return -1;
	}

	int res = read(fd, buf, count);
	close(fd);
	TRACE("Read count=" << std::dec << count << ", res=" << res);
	return res;
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
	
	int fd = open(path->mkpath(file).c_str(), O_RDWR);
	if (fd <= 0) {
		WARN("Cannot open file='" << file << "' O_RDWR");
		return fd;
	}
	
	if (lseek(fd, offset, SEEK_SET) < 0) {
		WARN("Seek for file='" << file << "', fd=" << fd << " failed");
		close(fd);
		return -1;
	}
	
	int res = write(fd, buf, count);
	close(fd);
	return res;
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

	if (path->isTmp(dir)) {
		rmdir(path->mktmp(dir).c_str());
	}
	if (path->isRoot(dir)) {
		whiteout->setVisible(dir, false);
	}
	return 0;
}


int 
LiveCDFS::doUnlink(char *file)
{
	FUNC("file='" << file << "'");
	
	if (path->isTmp(file)) {
		unlink(path->mktmp(file).c_str());
	}
	if (path->isRoot(file)) {
		whiteout->setVisible(file, false);
	}
	return 0;
}


int 
LiveCDFS::doCreate(char *file, 
		   int mode)
{
	FUNC("file='" << file << "', " <<
	     "mode=" << mode);
	
	int fd = open(path->mktmp(file).c_str(), O_WRONLY | O_CREAT | O_TRUNC, mode);
	if (fd > 0) {
		whiteout->setVisible(file, true);
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
	
	if (!whiteout->isVisible(oldname)) {
		return -1;
	}
	
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
	
	if (!whiteout->isVisible(file)) {
		return -1;
	}
	
	if (!path->isTmp(file)) {
		path->copyTmp(file);
	}
	
	string tmppath = path->mktmp(file);
	struct stat stat;
	int res;
	if ((res = lstat(tmppath.c_str(), &stat)) < 0) {
		ERROR("Could not perform stat on file='" << file << "', res=" << std::dec << res);
		return res;
	}
	
	if (stat.st_size > attr->f_size) {
		TRACE("Truncating file to " << std::dec << attr->f_size << " bytes");
		if ((res = truncate(tmppath.c_str(), attr->f_size)) < 0) {
			ERROR("Unable to truncate, res=" << std::dec << res);
			return res;
		}
	}
	
	if (stat.st_mode != attr->f_mode) {
		TRACE("Set mode=" <<  attr->f_mode << ", old=" << stat.st_mode);
		if ((res = chmod(tmppath.c_str(), attr->f_mode)) < 0) {
			ERROR("Unable to chmod, res=" << std::dec << res);
			return res;
		}
	}
	
	if ((stat.st_atime != (time_t)attr->f_atime) || 
	    (stat.st_mtime != (time_t)attr->f_mtime)) {
		struct utimbuf utim = {attr->f_atime, attr->f_mtime};
		if ((res = utime(tmppath.c_str(), &utim)) < 0) {
			ERROR("Unable to utime, res=" << std::dec << res);
			return res;
		}
	}
	
	return 0;
}
