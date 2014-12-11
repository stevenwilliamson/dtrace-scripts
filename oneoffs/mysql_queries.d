#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option strsize=4096

/*Output mysql queries in slow query log format*/
pid$target::*mysql_parse*:entry /  strstr(copyinstr(arg1), "ledger_entries") != NULL / /* This probe is fired when the execution enters mysql_parse */
{
     printf("# Time: 141105 14:49:29.802590\n# Client: 127.0.0.1:48466\n# Thread_id: 4294967296\n# Query_time: 0.001029  Lock_time: 0.000000  Rows_sent: 0  Rows_examined: 0\n%s\n", copyinstr(arg1));
}
