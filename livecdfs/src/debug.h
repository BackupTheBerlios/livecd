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
 * $Id: debug.h,v 1.8 2004/01/25 14:28:11 jaco Exp $
 */
 
#ifndef _DEBUG_dot_H_
#define _DEBUG_dot_H_

#include <stdio.h>

#undef TRACE
#undef WARN
#undef ERROR

#define PTR(x)		(void *)x
	
#ifdef DEBUG 
	#define HDR(x)		fprintf(stdout, "%s: %s(%u): %s", x, __FILE__, __LINE__, __func__)

	#define FUNC(x...)	HDR(" FUNC"); fprintf(stdout, "("); fprintf(stdout, x); fprintf(stdout, ")\n")
	#define TRACE(x...) 	HDR(" INFO"); fprintf(stdout, ": "); fprintf(stdout, x); fprintf(stdout, "\n")
	#define TRACE_START()	HDR(" INFO"); fprintf(stdout, "{\n")
	#define TRACE_END()	HDR(" INFO"); fprintf(stdout, "}\n")
	#define TRACE_RET(x)	TRACE_END(); return x
	
	#define WARN(x...)	HDR(" WARN"); fprintf(stdout, ": "); fprintf(stdout, x); fprintf(stdout, "\n")
	#define ERROR(x...)	HDR("ERROR"); fprintf(stdout, ": "); fprintf(stdout, x); fprintf(stdout, "\n")
#else
	#define FUNC(x...)	if (0) { fprintf(stdout, x); }
	#define TRACE(x...) 	if (0) { fprintf(stdout, x); }
	#define TRACE_START()	if (0) { fprintf(stdout, ""); }
	#define TRACE_END()	if (0) { fprintf(stdout, ""); }
	#define TRACE_RET(x)	return x
	
	#define WARN(x...)	if (0) { fprintf(stdout, x); }
	#define ERROR(x...)	if (0) { fprintf(stdout, x); }
#endif

#endif
