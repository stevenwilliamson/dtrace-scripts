#!/usr/sbin/dtrace -s

/* An attempt to trace down a panic caused by a disk pull */

#pragma D option bufpolicy=ring
#pragma D option bufsize=64k

fbt::vdev_disk_off_notify:entry
{
  printf("timestamp %d vdev_disk_off_notifycalled from tid 0x%x\n", timestamp, (uint64_t)curthread->t_did);
  stack();
}

fbt::vdev_disk_close:entry
{
  printf("timestamp %d vdev_disk_close called from tid 0x%x vdev_guid 0x%x\n", timestamp, (uint64_t)curthread->t_did, args[0]->vdev_guid);
  print(*args[0]);
  stack();
}

fbt::vdev_disk_open:entry
{
  printf("timestamp %d vdev_disk_open called from tid 0x%x vdev_guid 0x%x\n", timestamp, (uint64_t)curthread->t_did, args[0]->vdev_guid);
  print(*args[0]);
  stack();
}

fbt::vdev_disk_free:entry
{
  printf("timestamp %d vdev_disk_free called from tid 0x%x\n", timestamp, (uint64_t)curthread->t_did);
  stack();
}
