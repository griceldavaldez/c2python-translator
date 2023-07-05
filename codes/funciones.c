#include <stdio.h>

// Procedimiento
void imprimirMensaje() {
    printf("¡Hola, mundo!\n");
}

// Función
int sumar(int num1, int num2) {
    return num1 + num2;
}

int main() {
    imprimirMensaje();

    int resultado = sumar(5, 3);
    printf("El resultado de la suma es: %d\n", resultado);

    return 0;
}
