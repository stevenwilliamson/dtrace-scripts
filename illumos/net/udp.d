dtrace -n 'udp:::send /args[1]->cs_zoneid == 0 && args[4]->udp_dport == 0x35 / { printf("%s %d udp send", execname, pid); print(*args[4]); ustack(); }'
