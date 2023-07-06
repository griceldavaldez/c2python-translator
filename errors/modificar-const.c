#include <stdio.h>

int main(){
    const int CONSTANTE = 5;
    printf("%d", CONSTANTE);
    if(CONSTANTE >= 0){
        printf("Constante positiva");
    }else{
        printf("Constante negativa");
    }

    CONSTANTE = CONSTANTE + 1;
    printf("%d", CONSTANTE);
    return 0;
}