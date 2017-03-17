#!/usr/sbin/dtrace -s

/* Microseconds of time a process has spend
 * on and off CPU, useful in comparing performance difference across hosts
 * for the same task when looking at hypervisor load etc */

sched:::on-cpu
/ pid == $target && !self->off /
{
      self->ts = timestamp;
}

sched:::off-cpu
/ self->ts /
{
      @["on_cpu"] = sum((timestamp - self->ts) / 1000);
          self->ts = 0;
              self->off = timestamp;
}

sched:::on-cpu
/ pid == $target && self->off /
{
      @["off_cpu"] = sum((timestamp - self->off) / 1000);
          self->off = 0;
              self->ts = timestamp;
}

tick-10sec
{
      exit(0);
}
