#!/usr/sbin/dtrace -s

/* Shows the path to a binary passed to pfexec_call in the kernel exec system call and the return code after the call
   Useful when configuring restrictive profiles to see what has been allowed/disallowed or debugging RBAC in general */

#pragma D option quiet

fbt::pfexec_call:entry
{
  /* Path passed to pfexec_call */
  printf("\nPath: %s ", stringof(args[1]->pn_buf));
}

fbt::pfexec_call:return
{
  /* Path passed to pfexec_call */
  printf("Returned %d", args[1]);
}
