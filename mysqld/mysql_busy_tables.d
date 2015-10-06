#!/usr/sbin/dtrace -s


/* Reports aggregations of table access, though it is not 100% accurate.
 *
 * We hook in to the MySQL function check_table_name which is called to check a table
 * name is valid. This is done for each query so it does give us a good view of
 * which tables are been accessed often.
 * */

/*
 * usage:
 * mysql_busy_tables.d -p PID
 */

#pragma D option quiet
dtrace:::BEGIN
{
  printf("Queries per tabe\n");
}

pid$target::*check_table_name*:entry
{
  @tables[copyinstr(arg0, arg1)] = count();
}

tick-1s {
  printf("tables hit per second\n");
  printa(@tables);
  trunc(@tables);
}
