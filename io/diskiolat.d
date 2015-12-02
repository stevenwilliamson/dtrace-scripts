#!/usr/sbin/dtrace -s

/* Provides an overview of Disk IO latency to gague how individual disks are
 * handling Read and Write IO's */

#pragma D option bufsize=64k
#pragma D option aggsize=64k
#pragma D option dynvarsize=8m


io:::start
{
	iostart[args[0]->b_edev, args[0]->b_blkno] = timestamp;
}

io:::done
/ iostart[args[0]->b_edev, args[0]->b_blkno] /
{
  @stats[args[1]->dev_statname, args[0]->b_flags & B_READ ? "R" : "W"] = quantize((timestamp - iostart[args[0]->b_edev, args[0]->b_blkno]) / 1000);
  iostart[args[0]->b_edev, args[0]->b_blkno] = 0;
}

tick-60s
{
 printa(@stats);
 trunc(@stats);
}
