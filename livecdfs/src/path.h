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
 * $Id: path.h,v 1.3 2004/01/23 12:39:49 jaco Exp $
 */
 
#ifndef _PATH_dot_H_
#define _PATH_dot_H_

using namespace std;

#include <string>

class Path
{
private:
	string root;
	string tmp;

public:
	static Path *create(const string &, const string &);
	
	Path(const string &, const string &);
	~Path();
	
	const string &getRoot() { return root; }
	const string &getTmp() { return tmp; }
	
	string mkpath(const string &);
	string mkpath(const char *path) { return mkpath(string(path)); }
	
	string mktmp(const string &path) { return join(tmp, path); }
	string mktmp(const char *path) { return mktmp(string(path)); }
	
	string mkroot(const string &path) { return join(root, path); }
	string mkroot(const char *path) { return mkroot(string(path)); }
	
	bool copyTmp(const string &);
	bool copyTmp(const char *path) { return copyTmp(string(path)); }
	
	bool isTmp(const string &path, int flags = 0) { return exists(join(tmp, path), flags); }
	bool isTmp(const char *path, int flags = 0) { return isTmp(string(path), flags); }
	
	bool isRoot(const string &path, int flags = 0) { return exists(join(root, path), flags); }
	bool isRoot(const char *path, int flags = 0) { return isRoot(string(path), flags); }
	
	string getDir(const string &);
	string getDir(const char *path) { return getDir(string(path)); }
	
public:
	static string join(const string &, 
			   const string &);
	
	static string join(const string &s1, const char *s2) { return join(s1, string(s2)); }
	static string join(const char *s1, const char *s2) { return join(string(s1), string(s2)); }
			   		   
	static bool exists(const string &, int);
};

#endif
