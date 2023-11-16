#include "fir.h"

// LAB4-1
int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){
	//write down your fir
	for(int i = 0; i < N; ++i) {
		for(int j = 0; j <= i; ++j) {
			outputsignal[i] += taps[j] * inputsignal[i-j];
		}
	}
	return outputsignal;
}

// LAB4-2
void __attribute__ ( ( section ( ".mprjram" ) ) ) fir_tap() {
	ptr = (volatile uint32_t*)base_addr;
	for(int i = 0; i < N; ++i) {
		*ptr = taps[i];
	}
	*ptr = (volatile uint32_t)AP_START;
}

void __attribute__ ( ( section ( ".mprjram" ) ) ) fir_data() {
	ptr = (volatile uint32_t*)base_addr;
	for(int i = 0; i < DATALEN-1; ++i) {
		*ptr = i;
	}
	ptr += 1;
	*ptr = (volatile uint32_t)(DATALEN-1);
	*ptr = (volatile uint32_t)FIR_DATA_DONE;
}