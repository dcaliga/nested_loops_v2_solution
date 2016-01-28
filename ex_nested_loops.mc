/* $Id: ex05.mc,v 2.1 2005/06/14 22:16:47 jls Exp $ */

/*
 * Copyright 2005 SRC Computers, Inc.  All Rights Reserved.
 *
 *	Manufactured in the United States of America.
 *
 * SRC Computers, Inc.
 * 4240 N Nevada Avenue
 * Colorado Springs, CO 80907
 * (v) (719) 262-0213
 * (f) (719) 262-0223
 *
 * No permission has been granted to distribute this software
 * without the express permission of SRC Computers, Inc.
 *
 * This program is distributed WITHOUT ANY WARRANTY OF ANY KIND.
 */

#include <libmap.h>
#include <limits.h>

#define VAL_LONG_MAX 0x7fffffff


void subr (int64_t I0[], int64_t Out[], int D0, int D1, int64_t *time, int mapnum) {
    OBM_BANK_A (AL, int64_t, MAX_OBM_SIZE)
    OBM_BANK_B (BL, int64_t, MAX_OBM_SIZE)
    int64_t t0, t1;
    
    Stream_64 SB;


    buffered_dma_cpu (CM2OBM, PATH_0, AL, MAP_OBM_stripe (1,"A"), I0, 1, D0*D1*8);


#pragma src parallel sections
{
#pragma src section
{
    int i,j,xs,nend,iput;
    int64_t accum;

    read_timer (&t0);

    nend = D0*D1-1;

    for (xs=0; xs<D0*D1; xs++) {
       cg_count_ceil_32 (1, 0, xs==0, D1-1, &j);
       cg_count_ceil_32 (j==0, 0, xs==0, VAL_LONG_MAX, &i);
       cg_accum_add_64 (AL[i*D1+j], 1, 0, j==0, &accum);

       iput = (j==D1-1) ? 1 : 0;
       put_stream_64 (&SB, accum, iput);
//    BL[i] = accum;
    }

    read_timer (&t1);
    *time = t1 - t0;
}
#pragma src section
{
    streamed_dma_cpu_64 (&SB, STREAM_TO_PORT, Out, D0*sizeof(int64_t));
}
}


    }
