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
 * $Id: whiteout.cpp,v 1.3 2004/01/22 08:41:10 jaco Exp $
 */

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "path.h" 
#include "whiteout.h"

#include "debug.h"

Whiteout *
Whiteout::create(const string &tmp)
{
	FUNC("tmp='" << tmp << "'");
	     
	if (!Path::exists(tmp.c_str(), S_IFDIR)) {
		ERROR("FATAL: The path specified by 'rw_tmp='" << tmp << "' does not exist as a directory.");
		return NULL;
	}
	
	int fd = open(Path::join(tmp, WHITEOUT).c_str(), O_RDWR | O_CREAT, 0644);
	if (fd > 0) {
		close(fd);
		return new Whiteout(tmp);
	}
	else {
		ERROR("FATAL: Unable to create/read '.whiteout' in rw_tmp='" << tmp << "'");
		return NULL;
	}
}


Whiteout::Whiteout(const string &tmp)
{
	FUNC("tmp='" << tmp << "'");
	
	this->tmp = tmp;
	
	this->load("");
}


Whiteout::~Whiteout()
{
	FUNC("~destructor");
}


bool 
Whiteout::isVisible(const string &path)
{
	FUNC("path='" << path << "'");

	if (!(path.rfind(WHITEOUT) < path.length())) {
		t_whiteout *entry = find(path);
		return (entry == NULL) ? true : false;
	}
	return false;
}


void
Whiteout::setVisible(const string &path, bool visible)
{
	FUNC("path='" << path << "', " <<
	     "visible='" << visible);
	     
	t_whiteout *entry = find(path);
	if (visible) {
		if (entry != NULL) {
			erase((vector<t_whiteout>::iterator)entry);
		}
	}
	else if (entry == NULL) {
		add(path);
	}
	
}


t_whiteout *
Whiteout::find(const string &path)
{
	FUNC("path='" << path << "'");
	
	for (vector<t_whiteout>::iterator i = entries.begin(); i != entries.end(); ) {
		if (i->path == path) {
			return &*i;
		} 
		i++;
	}
	return NULL;
}

void 
Whiteout::add(const string &path) 
{
	FUNC("path='" << path << "'");
	     
	entries.push_back((t_whiteout){path});
	store("");
}


void
Whiteout::erase(vector<t_whiteout>::iterator it)
{
	FUNC("it=(iterator)");
	
	entries.erase(it);
	store("");
}


void 
Whiteout::load(const string &path)
{
	FUNC("path='" << path << "'");
	
	string file = Path::join(Path::join(tmp, path), WHITEOUT);
	int fd = open(file.c_str(), O_RDWR | O_TRUNC | O_CREAT, 0644);
	if (fd > 0) {
		entries.clear();
		char sz[2];
		string line("");
		sz[1] = '\0';
		while (read(fd, &sz, 1) == 1) {
			if (sz[0] == '\n') {
				add(line);
				line = string("");
			}
			else {
				line.append(sz);
			}
		}
		close(fd);
	}
	else {
		ERROR("Unable to open/read '.whiteout' in rw_tmp='" << tmp << "'");
	}
}


void 
Whiteout::store(const string &path)
{
	FUNC("path='" << path << "'");
	
	string file = Path::join(Path::join(tmp, path), WHITEOUT);
	int fd = open(file.c_str(), O_RDWR | O_TRUNC | O_CREAT, 0644);
	if (fd > 0) {
		for (vector<t_whiteout>::iterator i = entries.begin(); i != entries.end(); ) {
			string line = i->path + string("\n");
			write(fd, line.c_str(), line.length());
			i++;
		}
		close(fd);
	}
	else {
		ERROR("Unable to create/write '.whiteout' in rw_tmp='" << tmp << "'");
	}
}
