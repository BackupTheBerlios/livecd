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
 * $Id: debug.h,v 1.2 2004/01/19 06:42:17 jaco Exp $
 */
 
#ifndef _DEBUG_dot_H_
#define _DEBUG_dot_H_

using namespace std;

#include <iostream>

#define PTR(x)		(void *)x
#define DEC(x)		std::dec << x << std::hex

#ifdef DEBUG
	#undef TRACE
	#undef WARN
	#undef ERROR 

	#define HDR		"[" << getpid() << "]: " << __FILE__ << "(" << __LINE__ << "): "

	#define FUNC(x)		cout << " INFO: " << HDR << __func__ << "(" << std::hex << x << std::dec << ")\n"
	#define TRACE(x) 	cout << " INFO: " << HDR << __func__ << ": " << std::hex << x << std::dec << "\n"
	#define TRACE_START()	cout << " INFO: " << HDR << "{" << "\n"
	#define TRACE_END()	cout << " INFO: " << HDR << "}" << "\n"
	#define TRACE_RET(x)	TRACE_END(); return x
	
	#define WARN(x)		cerr << " WARN: " << HDR << ": " << std::hex << x << std::dec << "\n"
	#define ERROR(x)	cerr << "ERROR: " << HDR << ": " << std::hex << x << std::dec << "\n"
#endif

#endif
