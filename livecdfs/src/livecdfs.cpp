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
 * $Id: livecdfs.cpp,v 1.17 2004/01/24 19:42:33 jaco Exp $
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

vector<t_active_livecdfs> LiveCDFS::activefs;

t_active_livecdfs *
LiveCDFS::findActive(const string &root, 
		     const string &tmp)
{
	FUNC("root='" << root << "', " <<
	     "tmp='"  << tmp  << "'");
	
	for (vector<t_active_livecdfs>::iterator i = activefs.begin(); i != activefs.end(); ) {
		TRACE("Testing LiveCDFS instance, i=" << &*i << ", root='" << i->root << "', tmp='" << i->tmp << "'");
		if ((i->root == root) && (i->tmp == tmp)) {
			TRACE("Found existing LiveCDFS at i=" << &*i << ", fs=" << i->fs << ", root='" << root << "', tmp='" << tmp << "'");
			return &*i;
		} 
		i++;
	}
	TRACE("Existing LiveCDFS instance not found");
	return NULL;
}


t_active_livecdfs *
LiveCDFS::findActive(const LiveCDFS* fs)
{
	FUNC("fs=" << fs);
	
	for (vector<t_active_livecdfs>::iterator i = activefs.begin(); i != activefs.end(); ) {
		TRACE("Testing LiveCDFS instance, i=" << &*i << ", fs=" << i->fs);
		if (i->fs == fs) {
			TRACE("Found existing LiveCDFS at i=" << &*i << ", fs=" << i->fs);
			return &*i;
		} 
		i++;
	}
	TRACE("Existing LiveCDFS instance not found");
	return NULL;
}


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

	t_active_livecdfs *active = findActive(root, tmp);
	LiveCDFS *fs = NULL;
	if (active == NULL) {
		Path *path = NULL;
		Whiteout *wo = NULL;
		
		if (((path = Path::create(root, tmp)) != NULL) && 
		    ((wo = Whiteout::create(tmp)) != NULL)) {
			fs = new LiveCDFS(cfg, cache, cred, path, wo);
		}
		
		if (fs == NULL) {
			if (path != NULL) {
				delete path;
			}
			if (wo != NULL) {
				delete wo;
			}
			ERROR("Could not create new LiveCDFS instance");
		}
		else {
			activefs.push_back((t_active_livecdfs){root,tmp,1,fs});
			TRACE("Created new LiveCDFS instance, fs=" << fs);
		}
	}
	else {
		fs = active->fs;
		active->count++;
	}
	return fs;
}


void
LiveCDFS::destroy(LiveCDFS *fs) 
{
	FUNC("fs=" << fs);
	
	t_active_livecdfs *active = findActive(fs);
	if (active != NULL) {
		active->count--;
		if (active->count == 0) {
			TRACE("fs=" << fs << " not active anymore, destroying");
			activefs.erase((vector<t_active_livecdfs>::iterator)active);
			delete fs;
		}
		else {
			TRACE("fs=" << fs << " still has " << active->count << " references");
		}
	}
	else {
		ERROR("fs=" << fs << " not found, cannot destroy");
	}
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
LiveCDFS::doReaddir(const char *name, 
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
	vector<string> entries;
	
	string tmppath = path->mktmp(name);
	if ((tdir = opendir(tmppath.c_str()))) {
		while ((ent = readdir(tdir))) {
			string subpath = path->join(name, ent->d_name);
			if (whiteout->isVisible(subpath)) {
				TRACE("Adding direntry='" << ent->d_name << "'");
				if ((doStat(subpath.c_str(), &attr)) < 0) {
					ERROR("Could not stat file='" << ent->d_name << "'");
					closedir(rdir);
					return -1;
				}
				lu_cache_add2dir(dir, ent->d_name, NULL, &attr);
			}
			entries.push_back(subpath);
		}
		closedir(tdir);
	}
	else {
		path->recurseMkdir(name);
	}
	
	string rootpath = path->mkroot(name);
	if (whiteout->isVisible(name) && 
	    Path::exists(rootpath, S_IFDIR) && 
	    (rdir = opendir(rootpath.c_str()))) {
		while ((ent = readdir(rdir))){
			string subpath = path->join(name, ent->d_name);
			bool found = false;
			vector<string>::iterator i = entries.begin();
			while (!found && (i != entries.end())) {
				if (i->compare(subpath) == 0) { 
					found = true;
				} 
				i++;
			}
			if (!found && whiteout->isVisible(subpath)) {
				TRACE("Adding direntry='" << ent->d_name << "'");
				if ((doStat(subpath.c_str(), &attr)) < 0) {
					ERROR("could not stat file='" << ent->d_name << "'");
					closedir(rdir);
					return -1;
				}
				lu_cache_add2dir(dir, ent->d_name, NULL, &attr);
			}
		}
		closedir(rdir);
	}
	else {
		WARN("could not open directory, name='" << name << "'");
	}
	
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
	struct stat buf;
	if (stat(fullpath.c_str(), &buf) < 0) {
		WARN("Could not perform stat on file='" << fullpath << "'");
		return -1;
	}

	TRACE("name='"       << name         << "', " << std::dec <<
	      "buf.st_uid="  << buf.st_uid  << ", " <<
	      "buf.st_uid="  << buf.st_uid  << ", " <<
	      "buf.st_size=" << buf.st_size);
	      
	attr->f_mode  = buf.st_mode;
	attr->f_nlink = buf.st_nlink;
	attr->f_uid   = buf.st_uid; 
	attr->f_gid   = buf.st_gid;
	attr->f_size  = buf.st_size;
	attr->f_atime = buf.st_atime;
	attr->f_mtime = buf.st_mtime;
	attr->f_ctime = buf.st_ctime;
	
	return 0;
}


int 
LiveCDFS::doReadlink(const char *link, 
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
LiveCDFS::doOpen(const char *file, 
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
		string dir = path->getDir(file);
		if ((dir.length() != 0) && !path->isTmp(dir)) {
			TRACE("Creating directory dir='" << dir << "'");
			path->recurseMkdir(dir.c_str()); 
		}
	
		openpath = tmppath;
		created = true;
		TRACE("Creating empty file='" << file << "' on temp space");
	}
	else if ((flags & O_RDWR) || (flags & O_WRONLY)) {
		string rootpath = path->mkroot(file);
		if (path->exists(rootpath, S_IFREG) || path->exists(rootpath, S_IFLNK)) {
			if (!path->exists(tmppath, 0)) {
				path->copyTmp(file);
			}
			openpath = tmppath;
		}
		else if (path->exists(tmppath, S_IFREG) || path->exists(tmppath, S_IFLNK)) {
			openpath = tmppath;
		}
		else {
			ERROR("File='" << file << "', is not a regular file nor symlink, cannot create copy on temp space.");
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
	// of files we are busy with.)
	close(fd);
	handles->add(string(file), fd, flags, modes);
	TRACE(handles->size() << " files currently open.");
	
	return 0;
}


int 
LiveCDFS::doRelease(const char *file)
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
LiveCDFS::doRead(const char *file, 
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
LiveCDFS::doWrite(const char *file, 
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
LiveCDFS::doMkdir(const char *dir, 
		  int mode)
{
	FUNC("dir='"  << dir  << "', " <<
	     "mode=" << mode);
	
	int res = mkdir(path->mktmp(dir).c_str(), mode);
	if (res >= 0) {
		whiteout->setVisible(dir, true);
	}
	else {
		ERROR("Could not create directory, dir='" << dir << "'");
	}
	return res;
}


int 
LiveCDFS::doRmdir(const char *dir)
{
	FUNC("dir='" << dir << "'");

	int res = 0;
	if (path->isTmp(dir)) {
		if ((res = rmdir(path->mktmp(dir).c_str())) < 0) {
			ERROR("Could not remove directory, dir='" << dir << "'");
		}
	}
	if (path->isRoot(dir)) {
		whiteout->setVisible(dir, false);
	}
	return res;
}


int 
LiveCDFS::doUnlink(const char *file)
{
	FUNC("file='" << file << "'");
	
	int res = 0;
	if (path->isTmp(file)) {
		if ((res = unlink(path->mktmp(file).c_str())) < 0) {
			ERROR("Could not unlink file='" << file << "'");
		}
	}
	if (path->isRoot(file)) {
		whiteout->setVisible(file, false);
	}
	return res;
}


int 
LiveCDFS::doCreate(const char *file, 
		   int mode)
{
	FUNC("file='" << file << "', " <<
	     "mode=" << mode);
	
	string dir = path->getDir(file);
	if ((dir.length() != 0) && !path->isTmp(dir)) {
		TRACE("Creating directory dir='" << dir << "'");
		path->recurseMkdir(dir); 
	}
	
	int fd = open(path->mktmp(file).c_str(), O_WRONLY | O_CREAT | O_TRUNC, mode);
	if (fd > 0) {
		whiteout->setVisible(file, true);
		close(fd);
	}
	else {
		ERROR("Could not create file='" << file << "', mode=" << mode);
	}
	return fd;
}


int 
LiveCDFS::doRename(const char *oldname, 
		   const char *newname)
{
	FUNC("old='" << oldname << "', " <<
	     "new='" << newname << "'");
	
	if (!whiteout->isVisible(oldname)) {
		return -1;
	}
	
	if (path->isDir(oldname)) {
		// Ok, yes I'm playing lazy - with directories, a rename
		// means that the old ceases to exist (whiteout), but the
		// new directory should contain the contents of the old
		// one. Pretty easy if it is only on temp, but not so
		// easy if it is on the root directory... (Amd we don't
		// really want to copy all the contents over, now do we?)
		ERROR("Rename of directories is currently not implemented");
		return -1;
	}
	
	string sold = path->mktmp(oldname);
	string snew = path->mktmp(newname);
	if (!path->exists(sold, 0)) {
		path->copyTmp(oldname);
	}
	
	int ret = rename(sold.c_str(), snew.c_str());
	if (ret > 0) {
		whiteout->setVisible(oldname, false);
		whiteout->setVisible(newname, true);
	}
	else {
		ERROR("Could not rename old='" << oldname << "' top new='" << newname << "', ret=" << ret);
	}
	
	return ret;
}


int 
LiveCDFS::doLink(const char *target, 
		 const char *newlink)
{
	FUNC("target='" << target << "', " <<
	     "link='"   << newlink << "'");
	
	if (!whiteout->isVisible(target)) {
		return -1;
	}
	
	string dir = path->getDir(newlink);
	if ((dir.length() != 0) && !path->isTmp(dir)) {
		TRACE("Creating directory dir='" << dir << "' (link)");
		path->recurseMkdir(dir); 
	}
	
	if (!path->isDir(target)) {
		if ((dir.length() != 0) && !path->isTmp(dir)) {
			TRACE("Creating directory dir='" << dir << "' (target)");
			path->recurseMkdir(dir); 
		}
	}
	else if (!path->exists(path->mktmp(target), 0)) {
		path->copyTmp(target);
	}
	
	TRACE("Creating link, target='" << target << "', link='" << newlink << "'");
	return link(target, path->mktmp(newlink).c_str());
}


int 
LiveCDFS::doSymlink(const char *target, 
		    const char *newlink)
{
	FUNC("target='" << target << "', " <<
	     "link='"   << newlink << "'");
	     
	if (!whiteout->isVisible(target)) {
		return -1;
	}
	
	string dir = path->getDir(newlink);
	if ((dir.length() != 0) && !path->isTmp(dir)) {
		TRACE("Creating directory dir='" << dir << "' (link)");
		path->recurseMkdir(dir); 
	}
	
	if (!path->isDir(target)) {
		dir = path->getDir(target);
		if ((dir.length() != 0) && !path->isTmp(dir)) {
			TRACE("Creating directory dir='" << dir << "' (target)");
			path->recurseMkdir(dir); 
		}
	}
	else if (!path->exists(path->mktmp(target), 0)) {
		path->copyTmp(target);
	}
	
	TRACE("Creating link, target='" << target << "', link='" << newlink << "'");
	return symlink(target, path->mktmp(newlink).c_str());
}


int 
LiveCDFS::doSetattr(const char *file, 
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
	struct stat buf;
	int res;
	if ((res = stat(tmppath.c_str(), &buf)) < 0) {
		ERROR("Could not perform stat on file='" << file << "', res=" << std::dec << res);
		return res;
	}
	
	if (buf.st_size > attr->f_size) {
		TRACE("Truncating file to " << std::dec << attr->f_size << " bytes");
		if ((res = truncate(tmppath.c_str(), attr->f_size)) < 0) {
			ERROR("Unable to truncate, res=" << std::dec << res);
			return res;
		}
	}
	
	if (buf.st_mode != attr->f_mode) {
		TRACE("Set mode=" <<  attr->f_mode << ", old=" << buf.st_mode);
		if ((res = chmod(tmppath.c_str(), attr->f_mode)) < 0) {
			ERROR("Unable to chmod, res=" << std::dec << res);
			return res;
		}
	}
	
	if ((buf.st_atime != (time_t)attr->f_atime) || 
	    (buf.st_mtime != (time_t)attr->f_mtime)) {
		struct utimbuf utim = {attr->f_atime, attr->f_mtime};
		if ((res = utime(tmppath.c_str(), &utim)) < 0) {
			ERROR("Unable to utime, res=" << std::dec << res);
			return res;
		}
	}
	
	return 0;
}
