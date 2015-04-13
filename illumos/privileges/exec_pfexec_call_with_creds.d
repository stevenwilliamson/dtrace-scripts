#!/usr/sbin/dtrace -s

fbt::pfexec_call:entry
{
  /* cred_t struct passed to pfexec_call in exec system call in kernel */
  print(*args[0]);

  /* Path passed to pfexec_call */
  printf("\nPath: %s\n", stringof(args[1]->pn_buf));

}
