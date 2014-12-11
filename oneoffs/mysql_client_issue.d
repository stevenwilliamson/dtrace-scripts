#!/usr/sbin/dtrace -C -I/opt/local/include -s

/*Debug puppet storedconfigs issue*/


/*#pragma D option quiet*/

#include <mysql/mysql.h>


pid$target::mysql_real_query:entry
{
     self->handle = arg0;
     self->query = copyinstr(arg1);
     self->st_mysql = (MYSQL *)copyin(arg0, sizeof(MYSQL));
}

pid$target::mysql_real_query:return /self->handle/ {
  printf("pid:%d OS_tid:%d handle:%p return_code:%d thread_id:%d server_status:%d mysql_status:%d  query:%s\n", pid, tid, self->handle, arg0, self->st_mysql->thread_id, self->st_mysql->server_status, self->st_mysql->status, self->query);
  printf("error: %s", self->st_mysql->net.last_error);
}
