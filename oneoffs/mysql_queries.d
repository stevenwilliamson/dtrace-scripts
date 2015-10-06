#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option strsize=4096

/*Output mysql queries in slow query log format*/
pid$target::*mysql_parse*:entry /  strstr(copyinstr(arg1), "SELECT") != NULL / /* This probe is fired when the execution enters mysql_parse */
{
     printf("%s;\n", copyinstr(arg1));
}
