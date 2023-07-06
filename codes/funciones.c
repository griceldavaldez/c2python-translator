#include <stdio.h>

// Procedimiento
void imprimirMensaje() {
    printf("¡Llamada a procedimiento!\n");
}

//Funcion
int pow2 (int n, int m) {
    int i = 1;
	int res = 1;

	while (i <= m) {
		res = res * n;
		i++;
	}
	printf("res = %d", res);
    return res;
}


int main() {

	int x;
    x = pow2(4,3);
    return 0;

    imprimirMensaje();
}