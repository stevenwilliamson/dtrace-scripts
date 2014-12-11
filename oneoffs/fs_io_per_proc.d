syscall::read:entry /fds[arg0].fi_fs == "zfs"/
{
    @data[execname] = count();
}

tick-10s
{
  printa(@data);
  exit(0);
}
