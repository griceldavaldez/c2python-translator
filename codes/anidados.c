#include <stdio.h>

int main() {
    int x;
    x = 5;

    int y;
    y = 10;

    if (x > 0) {
        if (y > 0) {
            printf("Ambos números son positivos.\n");
        } else {
            printf("El primer número es positivo, pero el segundo no lo es.\n");
        }
    } else {
        printf("El primer número no es positivo.\n");
    }

    return 0;
}
