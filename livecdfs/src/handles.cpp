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
 * $Id: handles.cpp,v 1.5 2004/01/25 17:09:59 jaco Exp $
 */

#include <fcntl.h>

#include "handles.h"

#include "debug.h"

Handles::Handles() 
{
	FUNC_START("");
	FUNC_END();
}


Handles::~Handles()
{
	FUNC_START("~destructor");
	FUNC_END();
}


t_handle *
Handles::find(const char *file, 
	      unsigned flags, 
	      unsigned modes)
{
	FUNC_START("file='%s', flags=%u, modes=%u", file, flags, modes);

	for (vector<t_handle>::iterator i = handles.begin(); i != handles.end(); ) {
		if (i->name == file) {
			if ((modes == 0xffff) && 
			    (((flags == 0xffff) || (i->flags == flags)) ||
			     ((i->modes == modes) && (i->flags == flags)))) {
				TRACE("Found handle for file='%s', fd=%d", file, i->fd);
				FUNC_RET("%p", &*i, &*i);
			}
		} 
		i++;
	}
	
	TRACE("Existing handle for file='%s' not found", file);
	FUNC_RET("%p", NULL, NULL);
}

void 
Handles::add(string name, 
	    int fd, 
	    unsigned flags, 
	    unsigned modes)
{
	FUNC_START("name='%s', fd=%d, flags=%u, modes=%u", name.c_str(), fd, flags, modes);
	handles.push_back((t_handle){name, fd, flags, modes});
	FUNC_END();
}


void
Handles::erase(vector<t_handle>::iterator it)
{
	FUNC_START("it=(iterator)");
	handles.erase(it);
	FUNC_END();
}
