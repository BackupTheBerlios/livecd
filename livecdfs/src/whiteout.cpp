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
 * $Id: whiteout.cpp,v 1.8 2004/01/25 17:09:59 jaco Exp $
 */

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "path.h" 
#include "whiteout.h"

#include "debug.h"

//vector<t_whiteout> Whiteout::entries;

Whiteout *
Whiteout::create(const string &tmp)
{
	FUNC_START("tmp='%s'", tmp.c_str());
	     
	if (!Path::exists(tmp.c_str(), S_IFDIR)) {
		ERROR("FATAL: The path specified by 'rw_tmp='%s' does not exist as a directory.", tmp.c_str());
		FUNC_RET("%p", NULL, NULL);
	}
	
	int fd = open(Path::join(tmp, WHITEOUT).c_str(), O_RDWR | O_CREAT, 0644);
	if (fd > 0) {
		close(fd);
		Whiteout *wo = new Whiteout(tmp);
		FUNC_RET("%p", wo, wo);
	}
	else {
		ERROR("FATAL: Unable to create/read '.whiteout' in rw_tmp='%s'", tmp.c_str());
		FUNC_RET("%p", NULL, NULL);
	}
}


Whiteout::Whiteout(const string &tmp)
{
	FUNC_START("tmp='%s'", tmp.c_str());
	this->tmp = tmp;
	this->load("");
	FUNC_END();
}


Whiteout::~Whiteout()
{
	FUNC_START("~destructor");
	FUNC_END();
}


bool 
Whiteout::isVisible(const string &path)
{
	FUNC_START("path='%s'", path.c_str());

	if (!(path.rfind(WHITEOUT) < path.length())) {
		t_whiteout *entry = find(path);
		bool ret = (entry == NULL) ? true : false;
		FUNC_RET("%i", ret, ret);
	}
	FUNC_RET("%i", false, false);
}


void
Whiteout::setVisible(const string &path, bool visible)
{
	FUNC_START("path='%s', visible='", path.c_str(), visible);
	     
	t_whiteout *entry = find(path);
	if (visible) {
		if (entry != NULL) {
			erase((vector<t_whiteout>::iterator)entry);
		}
	}
	else if (entry == NULL) {
		add(path);
	}
	FUNC_END();
}


t_whiteout *
Whiteout::find(const string &path)
{
	FUNC_START("path='%s'", path.c_str());
	
	TRACE("Number of whiteout entries=%u", entries.size());
	for (vector<t_whiteout>::iterator i = entries.begin(); i != entries.end(); ) {
		if (i->path == path) {
			TRACE("Found whiteout path='%s'", path.c_str());
			FUNC_RET("%p", &*i, &*i);
		} 
		i++;
	}
	TRACE("Could not find whiteout path='%s'", path.c_str());
	FUNC_RET("%p", NULL, NULL);
}

void 
Whiteout::add(const string &path) 
{
	FUNC_START("path='%s'", path.c_str());
	     
	entries.push_back((t_whiteout){path});
	TRACE("Number of whiteout entries=%u", entries.size());
	store("");
	
	FUNC_END();
}


void
Whiteout::erase(vector<t_whiteout>::iterator it)
{
	FUNC_START("it=(iterator)");
	
	entries.erase(it);
	TRACE("Number of whiteout entries=%u", entries.size());
	
	store("");
	
	FUNC_END();
}


void 
Whiteout::load(const string &path)
{
	FUNC_START("path='%s'", path.c_str());
	
	string file = Path::join(Path::join(tmp, path), WHITEOUT);
	int fd = open(file.c_str(), O_RDWR | O_CREAT, 0644);
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
		ERROR("Unable to open/read '.whiteout' in rw_tmp='%s'", tmp.c_str());
	}
	TRACE("Number of whiteout entries=%u", entries.size());
	FUNC_END();
}


void 
Whiteout::store(const string &path)
{
	FUNC_START("path='%s'", path.c_str());
	
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
		ERROR("Unable to create/write '.whiteout' in rw_tmp='%s'", tmp.c_str());
	}
	TRACE("Number of whiteout entries=%u", entries.size());
	FUNC_END();
}
