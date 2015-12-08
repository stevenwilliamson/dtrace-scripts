#!/usr/sbin/dtrace -s


sched:::off-cpu
/curlwpsinfo->pr_state == SSLEEP && pid == $target /
{
	/*
	 * We're sleeping.  Track our sobj type.
	 */
	self->sobj = curlwpsinfo->pr_stype;
	self->bedtime = timestamp;
}

sched:::off-cpu
/curlwpsinfo->pr_state == SRUN && pid == $target /
{
	self->bedtime = timestamp;
}

sched:::on-cpu
/self->bedtime && !self->sobj && pid == $target /
{
	@["preempted"] = quantize(timestamp - self->bedtime);
        @total["preempted"] = sum(timestamp - self->bedtime);
	self->bedtime = 0;
}

sched:::on-cpu
/self->sobj && pid == $target /
{
	@[self->sobj == SOBJ_MUTEX ? "kernel-level lock" :
	    self->sobj == SOBJ_RWLOCK ? "rwlock" :
	    self->sobj == SOBJ_CV ? "condition variable" :
	    self->sobj == SOBJ_SEMA ? "semaphore" :
	    self->sobj == SOBJ_USER ? "user-level lock" :
	    self->sobj == SOBJ_USER_PI ? "user-level prio-inheriting lock" :
	    self->sobj == SOBJ_SHUTTLE ? "shuttle" : "unknown"] =
	    quantize(timestamp - self->bedtime);

	@total[self->sobj == SOBJ_MUTEX ? "kernel-level lock" :
	    self->sobj == SOBJ_RWLOCK ? "rwlock" :
	    self->sobj == SOBJ_CV ? "condition variable" :
	    self->sobj == SOBJ_SEMA ? "semaphore" :
	    self->sobj == SOBJ_USER ? "user-level lock" :
	    self->sobj == SOBJ_USER_PI ? "user-level prio-inheriting lock" :
	    self->sobj == SOBJ_SHUTTLE ? "shuttle" : "unknown"] =
	    sum(timestamp - self->bedtime);


	self->sobj = 0;
	self->bedtime = 0;
}

tick-30s
{
 printa(@);
 printa(@total);
 exit(0);
}
