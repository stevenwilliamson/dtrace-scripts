#!/usr/sbin/dtrace -s

/*
* Records total time spent in userland function calls in ms
* Includes all time even if process is moved off cpu run queue.
* start with dtrace -s <scriptname> -p <pid>
*/
pid$target:mysqld::entry {
    self->time = timestamp;

}

pid$target:::return
/ self->time /
{
    @data[probefunc] = sum((timestamp - self->time) / 1000);

}
