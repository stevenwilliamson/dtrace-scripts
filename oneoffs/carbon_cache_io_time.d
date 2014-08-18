syscall::write:entry /fds[arg0].fi_fs == "zfs" && execname == "carbon-cache.py"/
{
  self->writetime = timestamp
}

syscall::write:return /self->writetime/
{
  @data["time_performing_write_zfs_io"] = sum((timestamp - self->writetime) / 1000);
  @data_count["number_of_write_syscalls"] = count();
}

syscall::read:entry /fds[arg0].fi_fs == "zfs" && execname == "carbon-cache.py"/
{
  self->readtime = timestamp
}

syscall::read:return /self->readtime/
{
  @data["time_performing_read_zfs_io"] = sum((timestamp - self->readtime) / 1000);
  @data_count["number_of_read_syscalls"] = count();
}

tick-1s {
  printa(@data);
  printa(@data_count);
  trunc(@data);
  trunc(@data_count);
}
