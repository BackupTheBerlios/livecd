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
 * $Id: main.cpp,v 1.2 2004/01/21 19:21:03 jaco Exp $
 */
 
#include <lufs/proto.h>
#include <lufs/fs.h>

#include "livecdfs.h"

#include "debug.h"

extern "C"{

void *
livecdfs_init(struct list_head *cfg, 
	      struct dir_cache *cache, 
	      struct credentials *cred, 
	      void **global_ctx)
{
	FUNC("cfg="        << cfg        << ", " <<
	     "cache="      << cache      << ", " <<
	     "cred="       << cred       << ", " <<
	     "global_ctx=" << global_ctx);
	
	TRACE_START();    
	void *fs = (void *)LiveCDFS::create(cfg, cache, cred);
	TRACE("create(...)=" << fs);
	TRACE_RET(fs);
}


void 
livecdfs_free(void *fs)
{
	FUNC("fs=" << fs);
	
	TRACE_START();
	LiveCDFS *p = (LiveCDFS*)fs;
	delete p;
	TRACE_END();
}


int 
livecdfs_mount(void *fs)
{
	FUNC("fs=" << fs);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doMount();
	TRACE("(" << "fs="        << fs << ")->"
		  << "doMount()=" << DEC(ret));
	TRACE_RET(ret);
}


void 
livecdfs_umount(void *fs)
{
	FUNC("fs=" << fs);
	
	TRACE_START();
	((LiveCDFS*)fs)->doUmount();
	TRACE_END();
}


int 
livecdfs_readdir(void *fs, 
		 char *name, 
		 struct directory *dir)
{
	FUNC("fs="   << fs   << ", " <<
	     "name='" << name << "', " <<
	     "dir="  << dir);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doReaddir(name, dir);
	TRACE("(" << "fs="             << fs << ")->"
		  << "doReaddir(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_stat(void *fs, 
	      char *name, 
	      struct lufs_fattr *attr)
{
	FUNC("fs="   << fs   << ", " <<
	     "name='" << name << "', " <<
	     "attr=" << attr);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doStat(name, attr);
	TRACE("(" << "fs="          << fs << ")->"
		  << "doStat(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_mkdir(void *fs, 
	       char *dir, 
	       int mode)
{
	FUNC("fs="   << fs   << ", " <<
	     "dir='"  << dir  << "', " <<
	     "mode=" << mode);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doMkdir(dir, mode);
	TRACE("(" << "fs="           << fs << ")->"
		  << "doMkdir(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_rmdir(void *fs, 
	       char *dir)
{
	FUNC("fs="  << fs  << ", " <<
	     "dir='" << dir << "'");
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRmdir(dir);
	TRACE("(" << "fs="           << fs << ")->"
		  << "doRmdir(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_create(void *fs, 
		char *file, 
		int mode)
{
	FUNC("fs="   << fs   << ", " <<
	     "file='" << file << "', " <<
	     "mode=" << mode);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doCreate(file, mode);
	TRACE("(" << "fs="            << fs << ")->"
		  << "doCreate(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_unlink(void *fs, 
		char *file)
{
	FUNC("fs="   << fs   << ", " <<
	     "file='" << file << "'");
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doUnlink(file);
	TRACE("(" << "fs="            << fs << ")->"
		  << "doUnlink(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_rename(void *fs, 
		char *oldname, 
		char *newname)
{
	FUNC("fs="  << fs      << ", " <<
	     "old='" << oldname << "', " <<
	     "new='" << newname << "'");
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRename(oldname, newname);
	TRACE("(" << "fs="            << fs << ")->"
		  << "doRename(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_open(void *fs, 
	      char *file, 
	      unsigned mode)
{
	FUNC("fs="   << fs   << ", " <<
	     "file='" << file << "', " <<
	     "mode=" << mode);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doOpen(file, mode);
	TRACE("(" << "fs="          << fs << ")->"
		  << "doOpen(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_release(void *fs, 
		 char *file)
{
	FUNC("fs="   << fs   << ", " <<
	     "file='" << file << "'");
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRelease(file);
	TRACE("(" << "fs="             << fs << ")->"
		  << "doRelease(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_read(void *fs, 
	      char *file, 
	      long long offset, 
	      unsigned long count, 
	      char *buf)
{
	FUNC("fs="     << fs          << ", " <<
	     "file='"  << file        << "', " <<
	     "offset=" << DEC(offset) << ", " <<
	     "count="  << DEC(count)  << ", " <<
	     "buf="    << PTR(buf));
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doRead(file, offset, count, buf);
	TRACE("(" << "fs="          << fs << ")->"
		  << "doRead(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_write(void *fs, 
	       char *file, 
	       long long offset, 
	       unsigned long count, 
	       char *buf)
{
	FUNC("fs="    << fs          << ", " <<
	     "file='"  << file       << "', " <<
	     "offset" << DEC(offset) << ", " <<
	     "count=" << DEC(count)  << ", " <<
	     "buf="   << PTR(buf));
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doWrite(file, offset, count, buf);
	TRACE("(" << "fs="           << fs << ")->"
		  << "doWrite(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_readlink(void *fs, 
		  char *link, 
		  char *buf, 
		  int buflen)
{
	FUNC("fs="     << fs          << ", " <<
	     "link='"  << link        << "', " <<
	     "buf="    << PTR(buf)    << ", " <<
	     "buflen=" << DEC(buflen));
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doReadlink(link, buf, buflen);
	TRACE("(" << "fs="              << fs << ")->"
		  << "doReadlink(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_link(void *fs, 
	      char *target, 
	      char *link)
{
	FUNC("fs="      << fs     << ", " <<
	     "target='" << target << "', " <<
	     "link='"   << link << "'");
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doLink(target, link);
	TRACE("(" << "fs="          << fs << ")->"
		  << "doLink(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_symlink(void *fs, 
		 char *target, 
		 char *link)
{
	FUNC("fs="      << fs     << ", " << 
	     "target='" << target << "', " <<
	     "link='"   << link << "'");
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doSymlink(target, link);
	TRACE("(" << "fs="             << fs << ")->"
		  << "doSymlink(...)=" << DEC(ret));
	TRACE_RET(ret);
}


int 
livecdfs_setattr(void *fs, 
		 char *file, 
		 struct lufs_fattr *attr)
{
	FUNC("fs="    << fs   << ", " <<
	     "file='" << file << "', " <<
	     "attr="  << attr);
	
	TRACE_START();
	int ret = ((LiveCDFS*)fs)->doSetattr(file, attr);
	TRACE("(" << "fs="             << fs << ")->"
		  << "doSetattr(...)=" << DEC(ret));
	TRACE_RET(ret);
}

}
