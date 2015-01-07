#!/usr/sbin/dtrace -s
/*
 * mysqld_pid_fslatency_slowlog.d  Print slow filesystem I/O events.
 *
 * USAGE: ./mysql_pid_fslatency_slowlog.d mysqld_PID
 *
 * This traces mysqld filesystem I/O during queries, and prints output when
 * the total I/O time during a query was longer than the MIN_FS_LATENCY_MS
 * tunable.  This requires tracing every query, whether it performs FS I/O
 * or not, which may add a noticable overhead.
 *
 * TESTED: these pid-provider probes may only work on some mysqld versions.
 *	5.0.51a: ok
 *
 * 27-Mar-2011	brendan.gregg@joyent.com
 */

#pragma D option quiet

inline int MIN_FS_LATENCY_MS = 300;

dtrace:::BEGIN
{
	min_ns = MIN_FS_LATENCY_MS * 1000000;
}

pid$1::*dispatch_command*:entry
{
	self->q_start = timestamp;
	self->io_count = 0;
	self->total_ns = 0;
}

pid$1::os_file_read:entry,
pid$1::os_file_write:entry,
pid$1::my_read:entry,
pid$1::my_write:entry
/self->q_start/
{
	self->fs_start = timestamp;
}

pid$1::os_file_read:return,
pid$1::os_file_write:return,
pid$1::my_read:return,
pid$1::my_write:return
/self->fs_start/
{
	self->total_ns += timestamp - self->fs_start;
	self->io_count++;
	self->fs_start = 0;
}

pid$1::*dispatch_command*:return
/self->q_start && (self->total_ns > min_ns)/
{
	this->query = timestamp - self->q_start;
	printf("%Y filesystem I/O during query > %d ms: ", walltimestamp,
	    MIN_FS_LATENCY_MS);
	printf("query %d ms, fs %d ms, %d I/O\n", this->query / 1000000,
	    self->total_ns / 1000000, self->io_count);
}

pid$1::*dispatch_command*:return
/self->q_start/
{
	self->q_start = 0;
	self->io_count = 0;
	self->total_ns = 0;
}
