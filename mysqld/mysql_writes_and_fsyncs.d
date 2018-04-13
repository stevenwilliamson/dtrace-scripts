#!/usr/sbin/dtrace -s

/* See where the majority of writes and fsyncs are coming from
   for MySQL
*/

syscall::*write*:entry
/ execname == "mysqld" /
{
  @data[ustack(5)] = count();
}

syscall::fdsync:entry
/ execname == "mysqld" /
{
  @fsync[ustack(5)] = count();
}

tick-10s
{
  printa(@data);
  trunc(@data);
  printa(@fsync);
  trunc(@fsync);
}
