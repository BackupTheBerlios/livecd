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
 * $Id: whiteout.h,v 1.1 2004/01/21 19:19:11 jaco Exp $
 */
 
#ifndef _WHITEOUT_dot_H_
#define _WHITEOUT_dot_H_

using namespace std;

#include <string>
#include <vector>

#define WHITEOUT		string(".whiteout")

typedef struct s_whiteout
{
	string path;
} t_whiteout;
	
class Whiteout
{
private:
	vector<t_whiteout> entries;
	string tmp;
	
public:
	static Whiteout *create(const string &);
	
	Whiteout(const string &tmp);
	~Whiteout();
	
	bool isVisible(const string &);
	bool isVisible(const char *path) { return isVisible(string(path)); }
	
	void setVisible(const string &, bool);
	void setVisible(const char *path, bool visible) { setVisible(string(path), visible); };
	
private:
	t_whiteout *find(const string &);
	void add(const string &); 
	void erase(vector<t_whiteout>::iterator it);
	
	void load(const string &);
	void store(const string &);
};

#endif
