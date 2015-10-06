#!/usr/sbin/dtrace -s

#pragma D option quiet


/*
 * Reports query time in microseconds as a histogram as the average
 * is a poor indication of real performance.
 *
 * Aggregation is cumlative i.e not cleared between each output.
 */

dtrace:::BEGIN
{
  printf("Query time in microseconds\n");
}

pid$target::*mysql_parse*:entry {
  self->start = timestamp;
}

pid$target::*mysql_parse*:return
/ self->start /
{
  @queries = llquantize((timestamp - self->start) / 1000, 10, 0, 6, 20);
  self->start = 0;
}

tick-10s {
  printa(@queries);
}
