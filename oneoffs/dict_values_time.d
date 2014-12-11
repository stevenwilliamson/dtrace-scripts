
pid$target::dict_values:entry
{
  self->time = timestamp;
}

pid$target::dict_values:return
/ self->time /
{
  @data["dict_values"] = quantize((timestamp - self->time) / 1000);
}
