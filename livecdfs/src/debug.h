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
 * $Id: debug.h,v 1.13 2004/01/28 06:27:40 jaco Exp $
 */
 
#ifndef _DEBUG_dot_H_
#define _DEBUG_dot_H_

#include <stdio.h>

#undef TRACE
#undef WARN
#undef ERROR

#define PTR(x)		(void *)x
	
#ifdef DEBUG 

extern int _debug;

#define SPACE()			for (int _i = 0; _i < _debug; _i++) { printf("    "); }
#define HDR(x)			printf("%5s:%17s(%3u): ", x, __FILE__, __LINE__); SPACE()
#define HDR_F(x)		HDR(x); printf("%s", __func__)

#define TRACE(x...) 		HDR("INFO"); printf("INFO: "); printf(x); printf("\n")
#define FUNC_START(x...)	HDR_F("FUNC"); printf("("); printf(x); printf(") {\n"); _debug++
#define FUNC_END()		_debug--; HDR("FUNC"); printf("}\n"); return
#define FUNC_RET(x,y,z)		_debug--; HDR("FUNC"); printf("} = "); printf(x,y); printf("\n"); return z

#define WARN(x...)		HDR("WARN"); printf("WARN: "); printf(x); printf("\n")
#define ERROR(x...)		HDR("ERROR"); printf("ERROR: "); printf(x); printf("\n")

#else

#define TRACE(x...) 		if (0) { printf(x); }
#define FUNC_START(x...)	if (0) { printf(x); }
#define FUNC_END()		return
#define FUNC_RET(x,y,z)		return z

#define WARN(x...)		if (0) { printf(x); }
#define ERROR(x...)		if (0) { printf(x); }

#endif

#endif
