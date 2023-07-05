#include <stdio.h>

int main() {
    int num;
    num = 6;

    if (num >= 0) {
        printf("El número es positivo.\n");
    } else {
        printf("El número es negativo.\n");
    }

    //opcional
    if(num >= 0 && num <= 9) {
		printf("El valor tiene un digito.\n");
	} else {
		printf("El valor tiene mas de un digito.\n");
	}

    return 0;
}
