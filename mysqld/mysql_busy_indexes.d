#!/usr/sbin/dtrace -s

/* Reports cumulative per second status of indexs used
 *
 * TESTED on mysql 5.0.96
 *
 * Other versions will require the structures below to be updated to obtain the
 * correct offsets
 * */

/*
 * usage:
 * mysql_busy_indexes.d -p PID
 */

typedef unsigned long int ulint;
typedef unsigned char byte;


struct mem_block_info_struct {
        ulint   magic_n;/* magic number for debugging */
        char    file_name[8];/* file name where the mem heap was created */
        ulint   line;   /* line number where the mem heap was created */
  ulint dummya;
  ulint dummyb;
  ulint dummyc;/* In the first block in the
                        the list this is the base node of the list of blocks;
                        in subsequent blocks this is undefined */
  ulint dummyd;
  ulint dummye;
        ulint   len;    /* physical length of this block in bytes */
        ulint   type;   /* type of heap: MEM_HEAP_DYNAMIC, or
                        MEM_HEAP_BUF possibly ORed to MEM_HEAP_BTR_SEARCH */
        /*ibool init_block;*/ /* TRUE if this is the first block used in fast
                        creation of a heap: the memory will be freed
                        by the creator, not by mem_heap_free */
  char init_block;
        ulint   free;   /* offset in bytes of the first free position for
                        user data in the block */
        ulint   start;  /* the value of the struct field 'free' at the
                        creation of the block */
        byte*   free_block;
                        /* if the MEM_HEAP_BTR_SEARCH bit is set in type,
                        and this is the heap root, this can contain an
                        allocated buffer frame, which can be appended as a
                        free block to the heap, if we need more space;
                        otherwise, this is NULL */

  /* This is if'defd not sure if it is in our build ???? */
  ulint dummyf;
  ulint dummyg;

};


/* The info structure stored at the beginning of a heap block */
typedef struct mem_block_info_struct mem_block_info_t;

/* A block of a memory heap consists of the info structure
followed by an area of memory */
typedef mem_block_info_t        mem_block_t;


/* A memory heap is a nonempty linear list of memory blocks */
typedef mem_block_t     mem_heap_t;



typedef struct dulint_struct    dulint;
struct dulint_struct{
        ulint   high;   /* most significant 32 bits */
        ulint   low;    /* least significant 32 bits */
};


struct dict_table_struct{
        dulint          id;     /* id of the table or cluster */
        ulint           type;   /* DICT_TABLE_ORDINARY, ... */
        mem_heap_t*     heap;   /* memory heap */
        const char*     name;   /* table name */
};

typedef struct dict_table_struct dict_table_t;


#pragma D option quiet
dtrace:::BEGIN
{
  printf("Indexes used per second\n");
}

pid$target::*change_active_index*:entry {
  self->index_change = 1;
}

pid$target::*dict_table_get_index_noninline*:entry
/ self->index_change == 1 /
{
  self->a_table = (dict_table_t *)copyin(arg0, sizeof(dict_table_t));
  self->table_name = copyinstr((uintptr_t)self->a_table->name);

  @indexes[self->table_name, copyinstr(arg1)] = count();
  self->index_change = 0;
}

tick-1s {
  printf("indexs used\n");
  printa(@indexes);
}
