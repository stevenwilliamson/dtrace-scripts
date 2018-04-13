#!/usr/sbin/dtrace -s

int writes = 0;

syscall::write:entry
/ pid == $target /
{
	self->write_start = timestamp;
}

syscall::read:entry
/ pid == $target /
{
	self->read_start = timestamp;
}

syscall::write:return
/ self->write_start /
{
	@write["write"] = quantize((timestamp - self->write_start) / 1000)
  writes += 1;
}

syscall::read:return
/ self->read_start /
{
	@read["read"] = quantize((timestamp - self->read_start) / 1000)
  this->read += 1
}

END
{
  printf("IO Lat in microseconds\n");
	printa(@write);
  printf("%d writes", writes);
  printa(@read);
}
