#!/usr/sbin/dtrace -s

/*
   Return errno and unserland stack for socket syscalls
*/

syscall::so_socket:return
{
 printf("%d", errno);
 ustack();
}
