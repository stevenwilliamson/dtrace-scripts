#!/usr/sbin/dtrace -s

#pragma D option quiet

door_call:entry
{
        self->in = 1;
}

door_lookup:return
/self->in/
{
        self->called = stringof(args[1]->door_target->p_user.u_comm);
}

door_call:return
/self->in/
{
        @[execname, self->called] = count();
        self->in = 0;
        self->called = 0;
}

END
{
        printa("%s called door in %s %@d times\\n", @);
}
