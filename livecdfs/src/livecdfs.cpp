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
 * $Id: livecdfs.cpp,v 1.26 2004/02/01 07:16:13 jaco Exp $
 */

#include <dirent.h>
#include <errno.h>
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
	FUNC_START("root='%s', tmp='%s'", root.c_str(), tmp.c_str());
	
	for (vector<t_active_livecdfs>::iterator i = activefs.begin(); i != activefs.end(); ) {
		TRACE("Testing LiveCDFS instance, i=%p, root='%s', tmp='%s'", &*i, i->root.c_str(), i->tmp.c_str());
		if ((i->root == root) && (i->tmp == tmp)) {
			TRACE("Found existing LiveCDFS at i=%p, fs=%p, root='%s', tmp='%s'", &*i, i->fs, root.c_str(), tmp.c_str());
			FUNC_RET("%p", &*i, &*i);
		} 
		i++;
	}
	TRACE("Existing LiveCDFS instance not found");
	FUNC_RET("%p", NULL, NULL);
}


t_active_livecdfs *
LiveCDFS::findActive(const LiveCDFS* fs)
{
	FUNC_START("fs=%p", fs);
	
	for (vector<t_active_livecdfs>::iterator i = activefs.begin(); i != activefs.end(); ) {
		TRACE("Testing LiveCDFS instance, i=%p, fs=%p", &*i, i->fs);
		if (i->fs == fs) {
			TRACE("Found existing LiveCDFS at i=%p, fs=%p", &*i, i->fs);
			FUNC_RET("%p", &*i, &*i);
		} 
		i++;
	}
	TRACE("Existing LiveCDFS instance not found");
	FUNC_RET("%p", NULL, NULL);
}


LiveCDFS *
LiveCDFS::create(struct list_head *cfg, 
		 struct dir_cache *cache, 
		 struct credentials *cred)
{
	FUNC_START("cfg=%p, cache=%p, cred=%p", cfg, cache, cred);
	
	const char *opt = lu_opt_getchar(cfg, "MOUNT", "ro_root");
	if (opt == NULL) {
		ERROR("FATAL: Please specify '-o ro_root=<point>', defining the ro root (underlay) as a mount option");
		FUNC_RET("%p", NULL, NULL);
	}
	string root = string(opt);
	
	opt = lu_opt_getchar(cfg, "MOUNT", "rw_tmp");
	if (opt == NULL) {
		ERROR("FATAL: Please specify '-o rw_tmp=<point>', defining the temporary rw workspace, as a mount option");
		FUNC_RET("%p", NULL, NULL);
	}
	string tmp = string(opt);
	
	opt = lu_opt_getchar(cfg, "MOUNT", "mount");
	if (opt == NULL) {
		ERROR("FATAL: Please specify '-o mount=<point>', defining the final mountpoint, as a mount option");
		FUNC_RET("%p", NULL, NULL);
	}
	string mount = string(opt);

	t_active_livecdfs *active = findActive(root, tmp);
	LiveCDFS *fs = NULL;
	if (active == NULL) {
		Path *path = NULL;
		Whiteout *wo = NULL;
		
		if (((path = Path::create(root, tmp)) != NULL) && 
		    ((wo = Whiteout::create(tmp)) != NULL)) {
			fs = new LiveCDFS(cfg, cache, cred, mount, path, wo);
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
			activefs.push_back((t_active_livecdfs){mount,root,tmp,1,fs});
			TRACE("Created new LiveCDFS instance, fs=%p", fs);
		}
	}
	else {
		fs = active->fs;
		active->count++;
	}
	FUNC_RET("%p", fs, fs);
}


void
LiveCDFS::destroy(LiveCDFS *fs) 
{
	FUNC_START("fs=", fs);
	
	t_active_livecdfs *active = findActive(fs);
	if (active != NULL) {
		active->count--;
		if (active->count == 0) {
			TRACE("fs=%p not active anymore, destroying", fs);
			activefs.erase((vector<t_active_livecdfs>::iterator)active);
			delete fs;
		}
		else {
			TRACE("fs=%p still has %u references", fs, active->count);
		}
	}
	else {
		ERROR("fs=%p not found, cannot destroy", fs);
	}
	FUNC_END();
}


LiveCDFS::LiveCDFS(struct list_head *cfg, 
		   struct dir_cache *cache, 
		   struct credentials *cred,
		   const string &mount,
		   Path *path,
		   Whiteout *whiteout) 
{
	FUNC_START("cfg=%p, cache=%p, cred=%p, mount='%s', path=%p, whiteout=%p", cfg, cache, cred, mount.c_str(), path, whiteout);
	
	this->cfg = cfg;
	this->cache = cache;
	this->cred = cred;
	
	this->mount = mount;
	this->path = path;
	this->whiteout = whiteout;
	
	this->handles = new Handles();
	
	FUNC_END();
}


LiveCDFS::~LiveCDFS() 
{
	FUNC_START("~destructor");
	
	delete path;
	delete whiteout;
	delete handles;
	
	FUNC_END();
}


int 
LiveCDFS::doMount()
{
	FUNC_START("");
	FUNC_RET("%d", 1, 1);
}


void 
LiveCDFS::doUmount()
{
	FUNC_START("");
	FUNC_END();
}


int 
LiveCDFS::doReaddir(const char *name, 
		    struct directory *dir)
{
	FUNC_START("name='%s', dir=%p", name, dir);
	
	if (!whiteout->isVisible(name)) {
		FUNC_RET("%d", -1, -1);
	}
	
	DIR *rdir = NULL, *tdir = NULL;
	struct lufs_fattr attr;
	struct dirent *ent;
	vector<string> entries;
	
	string rootpath = path->mkroot(name);
	string tmppath = path->mktmp(name);
	
	if ((tdir = opendir(tmppath.c_str()))) {
		while ((ent = readdir(tdir))) {
			string subpath = path->join(name, ent->d_name);
			if (whiteout->isVisible(subpath)) {
				TRACE("Adding direntry='%s'", ent->d_name);
				if ((doStat(subpath.c_str(), &attr)) < 0) {
					ERROR("Could not stat file='%s'", ent->d_name);
					closedir(rdir);
					FUNC_RET("%d", -1, -1);
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
				TRACE("Adding direntry='%s'", ent->d_name);
				if ((doStat(subpath.c_str(), &attr)) < 0) {
					ERROR("could not stat file='%s'", ent->d_name);
					closedir(rdir);
					FUNC_RET("%d", -1, -1);
				}
				lu_cache_add2dir(dir, ent->d_name, NULL, &attr);
			}
		}
		closedir(rdir);
	}
	else {
		WARN("could not open directory, name='%s'", name);
	}
	
	FUNC_RET("%d", 0, 0);
}


int 
LiveCDFS::doStat(const char *name, 
		 struct lufs_fattr *attr)
{
	FUNC_START("name='%s', attr=%p", name, attr);
	
	if (!whiteout->isVisible(name)) {
		FUNC_RET("%d", -1, -1);
	}
	
	string fullpath = path->mkpath(name);
	struct stat buf;
	if (lstat(fullpath.c_str(), &buf) < 0) {
		WARN("Could not perform lstat on file='%s'", fullpath.c_str());
		FUNC_RET("%d", -1, -1);
	}

	TRACE("name='%s', buf.st_uid=%u, buf.st_gid=%u, buf.st_size=%u", name, buf.st_uid, buf.st_gid, buf.st_size);
	      
	attr->f_mode  = buf.st_mode;
	attr->f_nlink = buf.st_nlink;
	attr->f_uid   = 2; // This makes us default to the specified -o uid
	attr->f_gid   = 2; // This makes us default to the specified -o gid
	attr->f_size  = buf.st_size;
	attr->f_atime = buf.st_atime;
	attr->f_mtime = buf.st_mtime;
	attr->f_ctime = buf.st_ctime;
		
	FUNC_RET("%d", 0, 0);
}


int 
LiveCDFS::doReadlink(const char *link, 
		     char *buf, 
		     int buflen)
{
	FUNC_START("link='%s', buf=%p, buflen=%u", link, buf, buflen);
	
	if (!whiteout->isVisible(link)) {
		FUNC_RET("%d", -1, -1);
	}
	
	string linkpath = path->mkpath(link);
	TRACE("Reading linkpath='%s'", linkpath.c_str());
	int ret = readlink(linkpath.c_str(), buf, buflen);
	if (ret < 0) {
		ERROR("strerror(errno)='%s' on readlink(link='%s', &buf, buflen=%d)", strerror(errno), linkpath.c_str(), buflen);
	}
	else {
		buf[ret] = '\0';
		TRACE("After readlink, ret=%d, buf='%s'", ret, buf);
		if (buf[0] == '/') {
			string relpath = string("../");
			int pos = 0;
			while ((pos = string(link).find("/", pos+1)) > 0) {
				relpath = path->join(relpath, "../");
			}
			
			pos = 0;
			while ((pos = mount.find("/", pos+1)) > 0) {
				relpath = path->join(relpath, "../");
			}
			
			relpath = path->join(relpath, string(buf)); 
			memset(buf, 0, 256);
			strncpy(buf, relpath.c_str(), 255);
			ret = strlen(buf);
			TRACE("Translated relpath='%s'", buf);
		}
	}
	FUNC_RET("%d", ret, ret);
}


int 
LiveCDFS::doOpen(const char *file, 
		 unsigned mode)
{
	unsigned flags = mode ^ O_ACCMODE;
	unsigned modes = mode & O_ACCMODE;
	
	FUNC_START("file='%s', mode=%u (flags=%u, modes=%u)", file, mode, flags, modes);
	
	if (!whiteout->isVisible(file)) {
		FUNC_RET("%d", -1, -1);
	}
	
	if (handles->find(file, flags, modes)) {
		TRACE("file='%s' already open", file);
		FUNC_RET("%d", 0, 0);
	}
	
	bool created = false;
	string tmppath = path->mktmp(file);
	string openpath = string("");
	if (mode & O_CREAT) {
		TRACE("Flags for file='%s' is set to O_CREAT", file);
		string dir = path->getDir(file);
		if ((dir.length() != 0) && !path->isTmp(dir)) {
			TRACE("Creating directory dir='%s'", dir.c_str());
			path->recurseMkdir(dir.c_str()); 
		}
	
		openpath = tmppath;
		created = true;
		TRACE("Creating empty file='%s' on temp space", file);
	}
	else if ((modes == O_RDWR) || (modes == O_WRONLY)) {
		TRACE("Mode for file='%s' is set to O_RDWR || O_WRONLY", file);
		string rootpath = path->mkroot(file);
		if (path->exists(rootpath, S_IFREG) || path->exists(rootpath, S_IFLNK)) {
			TRACE("File='%s' is a regular file or symlink on root", file);
			if (!path->exists(tmppath, 0)) {
				path->copyTmp(file);
			}
			openpath = tmppath;
		}
		else if (path->exists(tmppath, S_IFREG) || path->exists(tmppath, S_IFLNK)) {
			TRACE("File='%s' is a regular file or symlink on tmp", file);
			openpath = tmppath;
		}
		else {
			ERROR("File='%s', is not a regular file nor symlink, cannot create copy on temp space", file);
			FUNC_RET("%d", -1, -1);
		}
	}
	else {
		// normal read
		TRACE("Mode for file='%s' is set for normal read", file);
		openpath = path->mkpath(file);
	}
	
	int fd = open(openpath.c_str(), mode, 0666);
	if (fd <= 0) {
		WARN("Unable to open file='%s', flags=%u, modes=%u", file, flags, modes);
		FUNC_RET("%d", -1, -1);
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
	TRACE("%u files currently open", handles->size());
	
	FUNC_RET("%d", 0, 0);
}


int 
LiveCDFS::doRelease(const char *file)
{
	FUNC_START("file='%s'", file);
	
	t_handle *handle;
	if ((handle = handles->find(file, 0xffff, 0xffff)) != NULL) {
		int fd = handle->fd;
		handles->erase((vector<t_handle>::iterator)handle);
		TRACE("fd=%d, for file='%s' released", fd, file);
	}
	else {
		WARN("Unable to find open handle for file='%s'", file);
	}
	
	TRACE("%u files currently open.", handles->size());
	FUNC_RET("%d", 0, 0);
}


int 
LiveCDFS::doRead(const char *file, 
		 long long offset, 
		 unsigned long count, 
		 char *buf)
{
	FUNC_START("file='%s', offset=%l, count=%ul, buf=%p", file, offset, count, buf);
	
	int fd = open(path->mkpath(file).c_str(), O_RDONLY);
	if (fd <= 0) {
		WARN("Cannot open file='%s' O_RDONLY", file);
		FUNC_RET("%d", -1, -1);
	}
	
	if (lseek(fd, offset, SEEK_SET) < 0) {
		WARN("Seek for file='%s', fd=%d failed", file, fd);
		close(fd);
		FUNC_RET("%d", -1, -1);
	}

	int res = read(fd, buf, count);
	close(fd);
	TRACE("Read count=%ul, res=%d", count, res);
	FUNC_RET("%d", res, res);
}


int 
LiveCDFS::doWrite(const char *file, 
		  long long offset, 
		  unsigned long count, 
		  char *buf)
{
	FUNC_START("file='%s', offset=%l, count=%ul, buf=%p", file, offset, count, buf);
	
	int fd = open(path->mkpath(file).c_str(), O_WRONLY);
	if (fd <= 0) {
		WARN("Cannot open file='%s' O_WRONLY", file);
		FUNC_RET("%d", fd, fd);
	}
	
	if (lseek(fd, offset, SEEK_SET) < 0) {
		WARN("Seek for file='%s', fd=%d failed", file, fd);
		close(fd);
		FUNC_RET("%d", -1, -1);
	}
	
	int res = write(fd, buf, count);
	close(fd);
	TRACE("Write count=%ul, res=%d", count, res);
	FUNC_RET("%d", res, res);
}


int 
LiveCDFS::doMkdir(const char *dir, 
		  int mode)
{
	FUNC_START("dir='%s', mode=%d", dir, mode);
	
	int res = mkdir(path->mktmp(dir).c_str(), mode);
	if (res < 0) {
		ERROR("strerror(errno)='%s' on mkdir(dir='%s', mode=%d)", strerror(errno), dir, mode);
	}
	else {
		whiteout->setVisible(dir, true);
	}
	FUNC_RET("%d", res, res);
}


int 
LiveCDFS::doRmdir(const char *dir)
{
	FUNC_START("dir='%s'", dir);

	int res = 0;
	if (path->isTmp(dir)) {
		if ((res = rmdir(path->mktmp(dir).c_str())) < 0) {
			ERROR("Could not remove directory, dir='%s'", dir);
		}
	}
	if (path->isRoot(dir)) {
		whiteout->setVisible(dir, false);
	}
	FUNC_RET("%d", res, res);
}


int 
LiveCDFS::doUnlink(const char *file)
{
	FUNC_START("file='%s'", file);
	
	int res = 0;
	if (path->isTmp(file)) {
		if ((res = unlink(path->mktmp(file).c_str())) < 0) {
			ERROR("Could not unlink file='%s'", file);
		}
	}
	if (path->isRoot(file)) {
		whiteout->setVisible(file, false);
	}
	
	FUNC_RET("%d", res, res);
}


int 
LiveCDFS::doCreate(const char *file, 
		   int mode)
{
	FUNC_START("file='%s', mode=%d(0x%x)", file, mode, mode);
	
	string dir = path->getDir(file);
	if ((dir.length() != 0) && !path->isTmp(dir)) {
		TRACE("Creating directory dir='%s'", dir.c_str());
		path->recurseMkdir(dir); 
	}
	
	int ret = mknod(path->mktmp(file).c_str(), mode, 0);
	if (ret < 0) {
		ERROR("strerror(errno)='%s' on mknod(file='%s', mode=%d, 0)", strerror(errno), file, mode);
	}
	else {
		whiteout->setVisible(file, true);
	}
	
	FUNC_RET("%d", ret, ret);
}


int 
LiveCDFS::doRename(const char *oldname, 
		   const char *newname)
{
	FUNC_START("old='%s', new='%s'", oldname, newname);
	
	if (!whiteout->isVisible(oldname)) {
		FUNC_RET("%d", -1, -1);
	}
	
	if (path->isDir(oldname)) {
		// Ok, yes I'm playing lazy - with directories, a rename
		// means that the old ceases to exist (whiteout), but the
		// new directory should contain the contents of the old
		// one. Pretty easy if it is only on temp, but not so
		// easy if it is on the root directory... (Amd we don't
		// really want to copy all the contents over, now do we?)
		ERROR("Rename of directories is currently not implemented");
		FUNC_RET("%d", -1, -1);
	}
	
	string sold = path->mktmp(oldname);
	string snew = path->mktmp(newname);
	if (!path->exists(sold, 0)) {
		path->copyTmp(oldname);
	}
	
	int ret = rename(sold.c_str(), snew.c_str());
	if (ret < 0) {
		ERROR("strerror(errno)='%s' on rename(old='%s', new='%s')", strerror(errno), sold.c_str(), snew.c_str());
	}
	else {
		whiteout->setVisible(oldname, false);
		whiteout->setVisible(newname, true);
	}
	
	FUNC_RET("%d", ret, ret);
}


int
LiveCDFS::doLinkAll(const char *target, 
		    const char *newlink, 
		    bool issymlink = false)
{
	FUNC_START("target='%s', link='%s'", target, newlink);
	
	if (!whiteout->isVisible(target)) {
		FUNC_RET("%d", -1, -1);
	}
	
	string dir = path->getDir(newlink);
	string slink = path->mktmp(newlink);
	if ((dir.length() != 0) && !path->isTmp(dir)) {
		TRACE("Creating directory dir='%s' (link)", dir.c_str());
		path->recurseMkdir(dir); 
	}
	
	if (*target != '/') {
		if (!path->isDir(target)) {
			dir = path->getDir(target);
			if ((dir.length() != 0) && !path->isTmp(dir)) {
				TRACE("Creating directory dir='%s' (target)", dir.c_str());
				path->recurseMkdir(dir); 
			}
		}
		
		if (!path->exists(path->mktmp(target), 0)) {
			if (path->exists(path->mkroot(target), 0)) {
				path->copyTmp(target);
			}
		}
	}
	
	TRACE("Creating link, target='%s', link='%s'", target, slink.c_str());
	int ret = issymlink ? symlink(target, slink.c_str()) : link(target, slink.c_str());
	if (ret < 0) {
		ERROR("strerror(errno)='%s' on link(target='%s', link='%s')", strerror(errno), target, slink.c_str());
	}
	FUNC_RET("%d", ret, ret);
}

int 
LiveCDFS::doLink(const char *target, 
		 const char *link)
{
	FUNC_START("target='%s', link='%s'", target, link);
	int ret = doLinkAll(target, link, false);
	FUNC_RET("%d", ret, ret);
}


int 
LiveCDFS::doSymlink(const char *target, 
		    const char *link)
{
	FUNC_START("target='%s', link='%s'", target, link);
	int ret = doLinkAll(target, link, true);
	FUNC_RET("%d", ret, ret);
}


int 
LiveCDFS::doSetattr(const char *file, 
		    struct lufs_fattr *attr)
{
	FUNC_START("file='%s', attr=%p", file, attr);
	
	if (!whiteout->isVisible(file)) {
		FUNC_RET("%d", -1, -1);
	}
	
	if (!path->isTmp(file)) {
		path->copyTmp(file);
	}
	
	string tmppath = path->mktmp(file);
	struct stat buf;
	int res;
	if ((res = lstat(tmppath.c_str(), &buf)) < 0) {
		ERROR("Could not perform lstat on file='%s', res=", file, res);
		FUNC_RET("%d", res, res);
	}
	
	if (buf.st_size > attr->f_size) {
		TRACE("Truncating file to %u bytes", attr->f_size);
		if ((res = truncate(tmppath.c_str(), attr->f_size)) < 0) {
			ERROR("Unable to truncate, res=%u", res);
			FUNC_RET("%d", res, res);
		}
	}
	
	if (buf.st_mode != attr->f_mode) {
		TRACE("Set mode=%u, old=%u", attr->f_mode, buf.st_mode);
		if ((res = chmod(tmppath.c_str(), attr->f_mode)) < 0) {
			ERROR("Unable to chmod, res=%u", res);
			FUNC_RET("%d", res, res);
		}
	}
	
	if ((buf.st_atime != (time_t)attr->f_atime) || 
	    (buf.st_mtime != (time_t)attr->f_mtime)) {
		struct utimbuf utim = {attr->f_atime, attr->f_mtime};
		if ((res = utime(tmppath.c_str(), &utim)) < 0) {
			ERROR("Unable to utime, res=%u", res);
			FUNC_RET("%d", res, res);
		}
	}
	
	FUNC_RET("%d", 0, 0);
}
