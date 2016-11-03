#!/usr/bin/dtrace -s

/* prints queries that use a hash index successfully */

pid$target::*mysql_parse*:entry
{
  self->follow = 1;
  self->query = copyinstr(arg1);
}

pid$target::btr_search_guess_on_hash:return
/ self->follow && arg1 != 0 /
{
  printf("%s", self->query);
}

pid$target::*mysql_parse*:return
{
  self->follow = 0;
}
