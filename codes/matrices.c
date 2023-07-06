#include <stdio.h>

int main() {
    int mat_1 [][3] = {
        {1,4,6},
        {2,0,5},
        {8,3,3}
    };
    int mat_2 [3][3], i, j, total;
    
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            mat_2 [i][j] = i+j;
        }
    }

    total = 0;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) { 
            total += mat_1 [i][j] + mat_2 [i][j];
        }
    }
    printf("Total: %d\n", total);

    return 0;
}
