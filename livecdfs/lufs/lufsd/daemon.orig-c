/*
 * daemon.c
 * Copyright (C) 2002 Florin Malita <mali@go.ro>
 *
 * This file is part of LUFS, a free userspace filesystem implementation.
 * See http://lufs.sourceforge.net/ for updates.
 *
 * LUFS is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * LUFS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <stdlib.h>
#include <stdio.h>
#include <syslog.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <pwd.h>
#include <errno.h>
#include <time.h>

#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <sys/mount.h>


#include <lufs/proto.h>
#include <lufs/fs.h>

#include "list.h"
#include "message.h"
#include "filesystem.h"
#include "fsctl.h"

#define CONFIG_FILE1	"/etc/lufsd.conf"
#define CONFIG_FILE2	"~/.lufs/lufsd.conf"

const char *exec_paths[]={
    "/usr/local/bin/lufsmnt",
    "/usr/bin/lufsmnt",
    "/sbin/lufsmnt",
    NULL
};

int
tempsock(char *base, char *name){
    struct sockaddr_un addr;
    unsigned long rnd;
    int sock, res;
    
    if((sock = socket(PF_UNIX, SOCK_STREAM, 0)) < 0){
	ERROR("socket error: %s", strerror(errno));
	return sock;
    }

    addr.sun_family = AF_UNIX;

    do{
	rnd = random();
	sprintf(addr.sun_path, "%s%lu", base, rnd);

	TRACE("trying address %s", addr.sun_path);

	res = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
    }while((res < 0) && (errno == EADDRINUSE));

    if(res < 0){
	ERROR("bind error: %s", strerror(errno));
	return res;
    }
    
    if((res = listen(sock, 10)) < 0){
	ERROR("listen error: %s", strerror(errno));
	return res;
    }
    
    if(name)
	strcpy(name, addr.sun_path);

    return sock;
}

int
main(int argc, char **argv){
    char *service, *mountpoint, *odata;
    struct list_head cfg;
    struct fs_ctl *ctl;
    char tmp[256], *nopts;
    int ssock, pid, mpid, res;

    INIT_LIST_HEAD(&cfg);

    srandom(time(NULL));

    if((argc < 5) || (strcmp(argv[3], "-o")) ){
	ERROR("Usage: %s none <mount-point> -o [options, ...]", argv[0]);
	exit(1);
    }

    if(argc > 5){
	TRACE("more options than expected...");
    }
    
    service = argv[1];
    mountpoint = argv[2];
    odata = argv[4];
    

    nopts = malloc(strlen(odata) + 100);
    if(!nopts){
	ERROR("out of memory!");
	exit(1);
    }

    strcpy(nopts, odata);

    if(lu_opt_parse(&cfg, "MOUNT", odata) < 0){
	ERROR("could not parse options!");
	exit(1);
    }

    if((lu_opt_loadcfg(&cfg, CONFIG_FILE1) < 0))
	lu_opt_loadcfg(&cfg, CONFIG_FILE2);

    if(!(ctl = lu_fsctl_create(&cfg))){
	WARN("could not create fs_ctl!");
	exit(1);
    }

    if(!lu_fsctl_mount(ctl)){
	ERROR("could not mount filesystem!");
	lu_fsctl_destroy(ctl);
	exit(1);
    }

    if((ssock = tempsock("/tmp/lufsd", tmp)) < 0)
	exit(1);

    TRACE("starting filesystem master at %s", tmp);

    chmod(tmp, S_IRWXU | S_IRWXG | S_IRWXO);

    /* detach & launch FSCtl */

    if((pid = fork()) < 0){
	ERROR("fork failed!");
	exit(1);
    }else
	if(pid == 0){
	    int fd;
	    const char *quiet;

	    quiet = lu_opt_getchar(&cfg, "MOUNT", "quiet");
	    
	    if((fd = open("/dev/tty", O_RDWR, 0)) < 0){
		WARN("couldn't open tty, assuming still ok...");
		fflush(stdout);
	    }else{
		ioctl(fd, TIOCNOTTY, 0);
		close(fd);
		setsid();
	    }

	    free(nopts);

	    if(quiet){
		int stdfd;

		TRACE("going dumb...");
		if((stdfd = open("/dev/null", O_RDWR, 0)) < 0){
		    WARN("couldn't open /dev/null!");
		}else{
		    dup2(stdfd, 0);
		    dup2(stdfd, 1);
		    dup2(stdfd, 2);
		    close(stdfd);
		}
	    }

	    /* launching FSCtl... */
	    lu_fsctl_run(ctl, ssock, tmp);
	    exit(1);
	}

    
    sprintf(nopts, "%s,server_socket=%s,server_pid=%d", nopts, tmp, pid);

    /* execute lufsmnt and wait for it. */
    
    if((mpid = fork()) < 0){
	ERROR("fork failed!");
	kill(pid, SIGUSR1);
	exit(1);
    }else 
	if(mpid == 0){
	    char *args[4];
	    const char *p;

	    args[0] = "lufsmnt";
	    args[1] = mountpoint;
	    args[2] = nopts;
	    args[3] = NULL;

	    TRACE("executing %s %s %s", args[0], args[1], args[2]);
	    execvp("lufsmnt", args);
	    WARN("execvp of lufsmnt failed: %s", strerror(errno));
	    WARN("you don't seem to have lufsmnt in your path. trying regular locations...");
	    
	    for(p = exec_paths[0]; p; p++){
		TRACE("trying %s %s %s", p, args[1], args[2]);
		execv(p, args);		
	    }

	    ERROR("could not launch lufsmnt!\n");
	    exit(1);
	}

    if(waitpid(mpid, &res, 0) < 0){
	ERROR("waitpid failed!");
	kill(pid, SIGUSR1);
	exit(1);
    }

    if(WIFEXITED(res) && WEXITSTATUS(res) != 0){
	kill(pid, SIGUSR1);
	exit(1);
    }

    TRACE("mount succeded");

    return 0;
}







