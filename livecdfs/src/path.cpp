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
 * $Id: path.cpp,v 1.4 2004/01/22 08:40:22 jaco Exp $
 */

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <string> 

#include "path.h"

#include "debug.h"

Path *
Path::create(const string &root, 
	     const string &tmp)
{
	FUNC("root='" << root << "', " <<
	     "tmp='" << tmp << "'");
	     
	if (!exists(tmp.c_str(), S_IFDIR)) {
		ERROR("FATAL: The path specified by 'rw_tmp='" << tmp << "' does not exist as a directory.");
		return NULL;
	}
	
	return new Path(root, tmp);
}


Path::Path(const string &root, 
	   const string &tmp)
{
	FUNC("root='" << root << "', " <<
	     "tmp='" << tmp << "'");
	     
	this->root = root;
	this->tmp = tmp;
}


Path::~Path()
{
	FUNC("~destructor");
}


string
Path::mkpath(const string &path)
{
	FUNC("path='" << path << "'");
	
	string retpath = mktmp(path);
	if (!exists(retpath, 0)) {
		retpath = mkroot(path);
	}
	return retpath;
}


bool
Path::copyTmp(const string &path)
{
	FUNC("path='" << path << "'");
	
	bool ret = false;
	struct stat buf;
	string rootpath = mkroot(path);
	
	if (stat(rootpath.c_str(), &buf) == 0) {
		string tmppath = mktmp(path);
		int dst = open(tmppath.c_str(), O_WRONLY | O_CREAT | O_TRUNC, buf.st_mode);
		if (dst > 0) {
			int src = open(rootpath.c_str(), O_RDONLY);
			if (src > 0) {
				char buf[8192];
				int len;
				int rtot = 0, wtot = 0;
				while ((len = read(src, &buf, 8192))) {
					rtot += len;
					wtot += write(dst, &buf, len);
				}
				close(src);
				ret = true;
				TRACE("Read " << std::dec << rtot << " bytes, wrote " << std::dec << wtot << " bytes");
			}
			else {
				WARN("Unable to open file='" << rootpath << "'");
			}
			close(dst);
		}
		else {
			WARN("Unable to open file='" << tmppath << "'");
		}
	}
	
	return ret;
}


string
Path::join(const string &s1, 
	   const string &s2)
{
	FUNC("s1='" << s1 << "', s2='" << s2 << "'");
	 
	size_t len1 = s1.length();
	while (len1 && s1[len1 - 1] == '/') {
		--len1;
	}
	 
	string ret = string("");   
	if (s2.length() == 0 || s2 == string(".")) {
		ret = string(s1.c_str(), len1) + string("/");
	}
	else {
		size_t pos2 = 0;
		while ((pos2 < s2.length()) && s2[pos2] == '/') {
			pos2++;
		}
		ret = string(s1.c_str(), len1) + string("/") + string(s2.c_str(), pos2, s2.length());
	}
	
	TRACE("ret='" << ret << "'");
	return ret;
}


bool 
Path::exists(const string &path, 
	     int flags = 0)
{
	FUNC("path='" << path << "', flags=" << flags);
	
	struct stat buf;
	if (stat(path.c_str(), &buf) == 0) {
		TRACE("buf.st_mode=" << buf.st_mode);
		if ((buf.st_mode & flags) == (unsigned int)flags) {
			return true;
		}
	}
	else {
		ERROR("errno=" << errno << " on stat('" << path << "', &buf");
	}
	
	return false;
}
