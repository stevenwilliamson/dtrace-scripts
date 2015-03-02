#!/usr/sbin/dtrace -s

#
# Logs queries that create on disk MyISAM tmp tables
#

#pragma D option quiet
dtrace:::BEGIN
{
  printf("Queries creating on disk tmp tables\n");
}

pid$target::*mysql_parse*:entry
{
  self->query = copyinstr(arg1);
}

pid$target::*create_myisam_tmp_table*:return
{
   printf("%Y %s\n", walltimestamp, self->query);
}
