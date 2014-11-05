#!/usr/sbin/dtrace -q

pid$target::*mysql_parse*:entry /* This probe is fired when the execution enters mysql_parse */
{
     printf("%s\n", copyinstr(arg1));
}
