#!/usr/sbin/dtrace -s
sched:::enqueue
{
	self->ts = timestamp;
}

sched:::dequeue
/self->ts/
{
	@["queue_time"] = quantize(timestamp - self->ts);
	self->ts = 0;
}

tick-10s
{
  exit(0);
}
