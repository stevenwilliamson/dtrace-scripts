#!/usr/sbin/dtrace -s

syscall::*read*:entry
/pid == $target && fds[arg0].fi_fs == "zfs"/
{
  @read[fds[arg0].fi_name, arg2] = count();
}

syscall::*write*:entry
/pid == $target && fds[arg0].fi_fs == "zfs"/
{
  @write[fds[arg0].fi_name, arg2] = count();
}

END
{
  printa(@read);
  printa(@write);
}
