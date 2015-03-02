#!/usr/sbin/dtrace -s

/*
* Script for tracking down possible perf issue with mysql
* SHOW FULL FIELDS
*/

#pragma D option quiet

dtrace:::BEGIN
{
  printf("SHOW FULL FIELDS QUERIES all times in ns\n");
}

pid$target::*mysql_parse*:entry
/ strstr(copyinstr(arg1), "SHOW FULL") != NULL /
{
  self->query_start = timestamp;
}

pid$target::*mysql_parse*:return
/ self->query_start /
{
  @num = count();
  @query_time_dist = quantize( timestamp - self->query_start );
  @total_time = sum( timestamp - self->query_start);
}

tick-1s
{
  printf("Number of queries: ");
  printa(@num);
  printf("\n");
  printa(@query_time_dist);
  printf("Total time: ");
  printa(@total_time);
  printf("\n");
  clear(@num);
  clear(@query_time_dist);
  clear(@total_time);
}
