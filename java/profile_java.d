#!/usr/sbin/dtrace -s

/* Quickly gague where a java is spending CPU be profiling at set rate
   and seeing where inthe call stack is it */

profile-997
/ pid == $target /
{
  @data[jstack()] = count();
}
