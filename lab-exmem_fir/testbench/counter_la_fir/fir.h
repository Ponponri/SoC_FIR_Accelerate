#ifndef __FIR_H__
#define __FIR_H__
#include <stdint.h>


#define N 11
#define DATALEN 64

const int AP_START = 0xF0000000;
const int FIR_DATA_DONE = 0xFF000000;
int taps[N] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
int inputsignal[N] = {1,2,3,4,5,6,7,8,9,10,11};
int outputsignal[N];
int o_taps[N];
volatile uint32_t *ptr;
volatile uint32_t base_addr = 0x30000000;

#endif
