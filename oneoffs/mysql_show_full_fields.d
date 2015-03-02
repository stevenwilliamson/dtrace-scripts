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

syscall::read:entry
/ self->query_start && fds[arg0].fi_fs =="zfs" /
{
  self->io_start = timestamp;
}

syscall::read:return
/ self->io_start /
{
  @io_num = count();
  @io_dist = quantize( timestamp - self->io_start );
  @total_io_time = sum( timestamp - self->io_start);
}

syscall::write:entry
/ self->query_start && fds[arg0].fi_fs =="zfs" /
{
  self->io_start = timestamp;
}

syscall::write:return
/ self->io_start /
{
  @io_num = count();
  @io_dist = quantize( timestamp - self->io_start );
  @total_io_time = sum( timestamp - self->io_start);
}

syscall::write:entry, syscall::read:entry
/ pid == $target && fds[arg0].fi_fs =="zfs" /
{
  self->t_io_start = timestamp;
}

syscall::write:return, syscall::read:return
/ pid == $target && self->t_io_start /
{

  @t_io_num = count();
  /* @t_io_dist = quantize( timestamp - self->t_io_start );
  @t_total_io_time = sum( timestamp - self->t_io_start); */
}



pid$target::*mysql_parse*:return
/ self->query_start /
{
  @num = count();
  @query_time_dist = quantize( timestamp - self->query_start );
  @total_time = sum( timestamp - self->query_start);
}

tick-10s
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

  printf("Filesystem IO Stats: ");
  printf("Number of FS read/write calls: ");
  printa(@io_num);
  printf("\n");
  printa(@io_dist);
  printf("Total IO time: ");
  printa(@total_io_time);
  printf("IOs from SHOW FULL.. and Total MySQL FS IOs:");
  printa(@io_num);
  printa(@t_io_num);

  clear(@io_num);
  clear(@io_dist);
  clear(@total_time);
  clear(@t_io_num);
}
