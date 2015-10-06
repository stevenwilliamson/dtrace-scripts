#!/usr/sbin/dtrace -s


/* Reports aggregation of query time by tables accessed
 * The aggregation is reported as the total query time for a particular combination
 * of tables accessed. The tables accessed or separated by ":".
 *
 * A summary of data collected so far is printed every 10 seconds with time in nanoseconds
 * The program is configured to run for 60 seconds then the aggregation data will be output
 * with time in microseconds.
 * */

/*
 * usage:
 * mysql_busy_tables_with_time.d -p PID
 */

#pragma D option quiet
dtrace:::BEGIN
{
  printf("Query Time per table combination\n");
}

pid$target::*mysql_parse*:entry
{
  self->query_start = timestamp;
  self->tables = " ";
}

pid$target::*check_table_name*:entry
/ self->query_start /
{
  self->tables = strjoin(self->tables, strjoin(":", copyinstr(arg0, arg1)));
}

pid$target::*mysql_parse*:return
/ self->query_start /
{
  @tables[self->tables] = sum(timestamp - self->query_start);
  self->query_start = 0;
}

tick-10s {
  printa(@tables);
}

tick-1m
{
  /* normalize the data to microseconds */
  normalize(@tables, 1000);
  printa(@tables);
  exit(0);
}
