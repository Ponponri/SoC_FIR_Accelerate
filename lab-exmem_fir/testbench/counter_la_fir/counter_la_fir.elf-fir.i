# 0 "fir.c"
# 1 "/home/ponponri/Desktop/shared_folder/LAB4_2/lab-exmem_fir/testbench/counter_la_fir//"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "fir.c"
# 1 "fir.h" 1


# 1 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint.h" 1 3 4
# 11 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint.h" 3 4
# 1 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint-gcc.h" 1 3 4
# 34 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint-gcc.h" 3 4

# 34 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint-gcc.h" 3 4
typedef signed char int8_t;


typedef short int int16_t;


typedef long int int32_t;


typedef long long int int64_t;


typedef unsigned char uint8_t;


typedef short unsigned int uint16_t;


typedef long unsigned int uint32_t;


typedef long long unsigned int uint64_t;




typedef signed char int_least8_t;
typedef short int int_least16_t;
typedef long int int_least32_t;
typedef long long int int_least64_t;
typedef unsigned char uint_least8_t;
typedef short unsigned int uint_least16_t;
typedef long unsigned int uint_least32_t;
typedef long long unsigned int uint_least64_t;



typedef int int_fast8_t;
typedef int int_fast16_t;
typedef int int_fast32_t;
typedef long long int int_fast64_t;
typedef unsigned int uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned int uint_fast32_t;
typedef long long unsigned int uint_fast64_t;




typedef int intptr_t;


typedef unsigned int uintptr_t;




typedef long long int intmax_t;
typedef long long unsigned int uintmax_t;
# 12 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint.h" 2 3 4
# 4 "fir.h" 2






# 9 "fir.h"
const int AP_START = 0xF0000000;
const int FIR_DATA_DONE = 0xFF000000;
int taps[11] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
int inputsignal[11] = {1,2,3,4,5,6,7,8,9,10,11};
int outputsignal[11];
int o_taps[11];
volatile uint32_t *ptr;
volatile uint32_t base_addr = 0x30000000;
# 2 "fir.c" 2


int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){

 for(int i = 0; i < 11; ++i) {
  for(int j = 0; j <= i; ++j) {
   outputsignal[i] += taps[j] * inputsignal[i-j];
  }
 }
 return outputsignal;
}


void __attribute__ ( ( section ( ".mprjram" ) ) ) fir_tap() {
 ptr = (volatile uint32_t*)base_addr;
 for(int i = 0; i < 11; ++i) {
  *ptr = taps[i];
 }
 *ptr = (volatile uint32_t)AP_START;
}

void __attribute__ ( ( section ( ".mprjram" ) ) ) fir_data() {
 ptr = (volatile uint32_t*)base_addr;
 for(int i = 0; i < 64 -1; ++i) {
  *ptr = i;
 }
 ptr += 1;
 *ptr = (volatile uint32_t)(64 -1);
 *ptr = (volatile uint32_t)FIR_DATA_DONE;
}
