#!/usr/sbin/dtrace -s

/* What is calling nscd in the global zones */

#pragma D option quiet

door_call:entry
/ execname != "nscd" && curpsinfo->pr_zoneid == 0/
{
          self->in = 1;
}

door_lookup:return
/self->in && stringof(args[1]->door_target->p_user.u_comm) == "nscd" /
{
          self->called = stringof(args[1]->door_target->p_user.u_comm);
}

door_call:return
/self->in/
{
          printf("%d %s called nscd\n", pid, execname);
                  self->in = 0;
                          self->called = 0;
}
