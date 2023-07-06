#include <stdio.h>

int main() {
    char operator = '+';
    int operand1 = 10;
    int operand2 = 5;
    int result;

    switch (operator) {
        case '+':
            result = operand1 + operand2;
            printf("La suma es: %d\n", result);
            break;
        case '-':
            result = operand1 - operand2;
            printf("La resta es: %d\n", result);
            break;
        case '*':
            result = operand1 * operand2;
            printf("La multiplicación es: %d\n", result);
            break;
        case '/':
            result = operand1 / operand2;
            printf("La división es: %d\n", result);
            break;
        default:
            printf("Operador no válido.\n");
            break;
    }

    return 0;
}
