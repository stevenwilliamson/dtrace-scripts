#!/usr/sbin/dtrace -s

/* Number of IOPS per process, printed every 10 seconds */
syscall::read:entry /fds[arg0].fi_fs == "zfs"/
{
    @read[execname] = count();
}

syscall::write:entry /fds[arg0].fi_fs == "zfs"/
{
    @write[execname] = count();
}

tick-10s
{
  printa(@read);
  printa(@write);
  clear(@read);
  clear(@write);
}
