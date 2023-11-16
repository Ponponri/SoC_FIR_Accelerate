#include <stdlib.h>
#include <stdio.h>

#define N 11
#define DATALEN 64

void firmwareFir(FILE *file, int *taps, int *inputsignal) {
    int num = 0;

    for(int i = 0; i < N; ++i) {
        num = 0;
        for(int j = 0; j <= i; ++j) {
            num += taps[j] * inputsignal[i-j];
        }
        fprintf(file, "%x\n", num);
    }
}

void hardwareFir(FILE *file, int *taps) {
    int bound = 0, num = 0;
    int data[N];

    for(int i = 0; i < DATALEN; ++i) {
        bound = (i > N) ? N-1 : i;
        num = 0;
        for(int j = bound; j >= 0; --j) {
            if(j != 0) {
                data[j] = data[j-1];
            } else {
                data[j] = i;
            }
            num += data[j] * taps[j];
        }
        fprintf(file, "%x\n", num);
    }
}

int main(void) {
    int taps[N] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
    int inputsignal[N] = {1,2,3,4,5,6,7,8,9,10,11};
    FILE *fp;

    //4-1
    fp = fopen("lab4_1_golden.dat", "w");
    firmwareFir(fp, taps, inputsignal);
    fclose(fp);
    //4-2
    fp = fopen("lab4_2_golden.dat", "w");
    hardwareFir(fp, taps);
    fclose(fp);

}

