#!/usr/sbin/dtrace -s
/*
 * mysql_pid_latency.d  Print query latency distribution every second.
 *
 * USAGE: ./mysql_pid_latency.d -p mysqld_PID
 *
 */

#pragma D option quiet

dtrace:::BEGIN
{
        printf("Tracing PID %d... Hit Ctrl-C to end.\n", $target);
}

pid$target::*mysql_parse*:entry
{
        self->start = timestamp;
}

pid$target::*mysql_parse*:return
/self->start/
{
        @time = quantize(timestamp - self->start);
        @num = count();
        self->start = 0;
}

profile:::tick-1s
{
        printa("\nMySQL queries/second: %@d; query latency (ns):", @num);
        printa(@time);
        clear(@time); clear(@num);
}

dtrace:::END
{
        trunc(@time); trunc(@num);
}
