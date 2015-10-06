#!/usr/sbin/dtrace -s

/*
   This script shows the number of read operations issued by MySQL
   and the files that were read from.

   It also reports how many of those reads triggered actual Disk IO
   and whether they were from MySQL/MyISAM or InnoDB.

   Needs to be run in the global zone so it can access the io provider.
 */


/* MySQL reads from MyISAM storage engine and MySQL housekeeping functions
   such ash bin log etc */
pid$target::*my_read*:entry
/ fds[arg0].fi_fs == "zfs" /
{
  @mysql_reads[fds[arg0].fi_pathname] = count();
  self->in_mysql_read = 1;
}

/* InnoDB engine reads */
pid$target::*os_file_read*:entry
{
  @mysql_reads[fds[arg0].fi_pathname] = count();
  self->in_innodb_read = 1;
}

/* Disk IO */
io:::start
/ self->in_mysql_read /
{
  @disk_reads["mysql_disk_reads"] = count();
  self->in_mysql_read = 0;
}

io:::start
/ self->in_innodb_read /
{
  @disk_reads["innodb_disk_reads"] = count();
  self->in_innodb_read = 0;
}

END
{
  printa(@mysql_reads);
  printa(@disk_reads);
}
