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
 * $Id: handles.cpp,v 1.1 2004/01/18 15:47:52 jaco Exp $
 */

#include <fcntl.h>

#include "handles.h"

#include "debug.h"

Handles::Handles() 
{
	FUNC("");
}


Handles::~Handles()
{
	FUNC("~destructor");
}


t_handle *
Handles::find(const char *file, 
	     unsigned flags, 
	     unsigned modes)
{
	FUNC("file='"   << file << "', " <<
	     "flags="   << flags << ", " <<
	     "modes="   << modes);

	for (vector<t_handle>::iterator i = handles.begin(); i != handles.end(); ) {
		if ((i->name == file) && 
		    (((modes == 0xffff) && (flags == 0xffff)) || 
		     ((i->modes != O_RDWR) && (i->modes == modes) && (i->flags == flags)))) {
			TRACE("Found handle for file='" << file << "', fd=" << i->fd);
			return &*i;
		} 
		else {
			i++;
		}
	}
	
	TRACE("Existing handle for file='" << file << "' not found");
	return NULL;
}

void 
Handles::add(string name, 
	    int fd, 
	    unsigned flags, 
	    unsigned modes)
{
	FUNC("name='" << name  << "', " <<
	     "fd="    << fd    << ", " <<
	     "flags=" << flags << ", " <<
	     "modes=" << modes);
	     
	handles.push_back((t_handle){name, fd, flags, modes});
}


void
Handles::erase(vector<t_handle>::iterator it)
{
	FUNC("it=(iterator)");
	
	handles.erase(it);
}
