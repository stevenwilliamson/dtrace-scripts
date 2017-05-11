#!/usr/sbin/dtrace -s

/* Who sent signals where

   This script should be run from the GZ and provided an integer zoneid as shown by
   zoneadm list -v. All signals sent in that zone will then be instrumented
*/

#pragma D option quiet

BEGIN {
      printf("SENDER PID, SENDER, RECIPIENT, RECIPIENT PID, SIG\n");
}
proc:::signal-send
/ curpsinfo->pr_zoneid == $1 /
{
      printf("%d, %s, %s, %d, %d\n", pid, execname, stringof(args[1]->pr_fname), args[1]->pr_pid, args[2]);
}
