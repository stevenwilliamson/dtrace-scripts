#!/usr/sbin/dtrace -s

/*
 * Output queries in order of most disk IO's issued during query execution.
 * Due to volume of queries only consider queries with > 10 IO's by default
 */

#pragma D option quiet

dtrace:::BEGIN
{
  printf("Tracing queries by Disk IO <Ctrl-C> to end and output results\n");
}

pid$target::*mysql_parse*:entry
{
  self->follow = 1;
  self->io_count = 0;
  self->query = copyinstr(arg1);
}

io:::start
/ self->follow /
{
  self->io_count++;
}

pid$target::*mysql_parse*:return
/ self->follow && self->io_count > 10 /
{
  @data[self->query] = sum(self->io_count);
}
