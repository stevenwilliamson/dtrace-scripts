#!/usr/sbin/dtrace -s
#pragma D option quiet

/* Scheduling of the code responsible for handling net ticks
 Used for debugging analysing net splits with rabbitmq apparently due to
 net tick timeout been reached, script tries to show if the net ticks are scheduled to run
  how long the net tick function ran and also displays info on blocked dist ports */

BEGIN
{
  self->lastrun = 0;
}

erlang$target:::process-scheduled
/ strstr(copyinstr(arg1), "ticker_loop") != NULL /
{
  self->scheduled = timestamp;
  if (self->lastrun > 0) {
    self->interval = timestamp - self->lastrun;
  } else {
    self->interval = timestamp;
  }
  printf("%Y %s %s interval %d seconds,", walltimestamp, copyinstr(arg0), copyinstr(arg1), self->interval / 1000 / 1000 / 1000)
}

erlang$target:::process-unscheduled
/ self->scheduled != 0 /
{
  self->delta = (timestamp - self->scheduled);
  printf(" ran for %d us\n", self->delta / 1000);
  self->scheduled = 0;
  self->lastrun = timestamp;
}

erlang$target:::dist-port_busy
{
  printf("%Y port blocked node: %s  port: %s remote_node: %s pid that got blocked: %s\n", walltimestamp, copyinstr(arg0), copyinstr(arg1),
   copyinstr(arg2), copyinstr(arg3));
}

erlang$target:::dist-port_not_busy
{
  printf("%Y prt unblocked node: %s port: %s remote_node: %s\n", walltimestamp, copyinstr(arg0), copyinstr(arg1), copyinstr(arg2));
}
