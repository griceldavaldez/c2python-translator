/*Encabezado*/
%{
    #include "y.tab.h"      // Archivo de encabezado generado por YACC/BISON
    #include <stdio.h>      // Para funciones de entrada/salida estándar
    #include <stdlib.h>     // Para funciones de gestión de memoria dinámica
    #include <string.h>     // Para funciones de manipulación de cadenas de caracteres
    #include <ctype.h>      // Para funciones de manipulación de caracteres


    /*Estructura de datos para anticipación de símbolos*/
    struct symrec{
        char *name;             //Nombre del simbolo
        int type;               //Tipo de simbolo
        double value;           //Valor anticipado de la variable
        int function;           //Funcion
        struct symrec *next;    //Puntero del siguiente registro
    };

    typedef struct symrec symrec;

    /*Tabla de simbolos*/
    extern symrec *sym_table;

    /*Funciones para interactuar con la tabla de simbolos*/
    symrec *putsym ();
    symrec *getsym ();

    int line_number;            //Numero de lineas
    void multiline_comments(void);         //Comentarios de varias lineas
    void oneline_comment(void);    //Comentarios de una linea
    void count();               //Contador


/*int lineCount = 1; // Variable para contar las líneas

extern int yyparse(); // Declaración de la función yyparse() definida en yacc.y

typedef struct {
    char* name;
    int type;
} Symbol;

typedef struct {
    Symbol* entries;
    int size;
} SymbolTable;

SymbolTable symTable;*/

%}

/*Definicion de Tokens*/
%%

"//"            { oneline_comment(); }
"/*"            { multiline_comment(); }
\n              { ++line_number}
[ \t\v\f]       { count(); }
"#include".*    { /* Ignorar líneas que comiencen con "#include" */ }
"const"         { return CONST; }
"printf"        { yylval.name = strdup(yytext); return PRINTF; }
.               { printf("Lexema no reconocido: '%c' en la linea %d\n", yytext, line_number);}

"int"           { yylval.type = INT; return INT; }
"float"         { yylval.type = FLOAT; return FLOAT; }
"char"          { yylval.type = CHAR; return CHAR; }
"double"        { yylval.type = DOUBLE; return DOUBLE; }
"void"          { yylval.type = VOID; return VOID; }
"unsigned"      { yylval.type = UNSIGNED; return UNSIGNED; }
"signed"        { yylval.type = SIGNED; return SIGNED; }
"short"         { yylval.type = SHORT; return SHORT; }
"long"          { yylval.type = LONG; return LONG; }

"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"do"            { return DO; }
"switch"        { return SWITCH; }
"case"          { return CASE; }
"return"        { return RETURN; }
"break"         { return BREAK; }
"continue"      { return CONTINUE; }
"default"       { return DEFAULT; }

"{"             { return('{'); }
"}"             { return('}'); }
"["             { return('['); }
"]"             { return(']'); }
"("             { return('('); }
")"             { return(')'); }
";"             { return(';'); }
","             { return(','); }
"."             { return('.'); }
"!"             { return ('!'); }
"="             { return('='); }
"+"             { return('+'); }
"-"             { return('-'); }
"*"             { return('*'); }
"/"             { return('/'); }
"%"             { return('%'); }
"?"             { return('?'); }
("{"|"<%")      { return('{'); }
("}"|"%>")      { return('}'); }
("["|"<:")      { return('['); }
("]"|":>")      { return(']'); }

"=="            { return (EQ); }
"!="            { return (NEQ); }
"<"             { return (LT); }
"<="            { return (LTE); }
">"             { return (GT); }
">="            { return (GTE); }
"+="            { return (ADD_ASSIGN); }
"-="            { return (SUB_ASSIGN); }
"*="            { return (MUL_ASSIGN); }
"/="            { return (DIV_ASSIGN); }
"%="            { return (MOD_ASSIGN); }
"++"            { return (INC); }
"--"            { return (DEC); }
"&&"            { return (AND); }
"||"            { return (OR); }

    ///"main"          { printf("TOKEN: main\n"); printf("lex: %s\n",yytext); return MAIN; }

    //[ \t\r]+        { /* Ignorar espacios en blanco, tabulaciones y retorno de carro */ }

["].*["]                                { yylval.name = strdup(yytext); return STR; }
['].[']                                 { yylval.name = strdup(yytext); return CHARACTER; } 

[-]?[0-9]+                              { yylval.name = strdup(yytext); return CONSTANT; }
[-]?[0-9]+"."[0-9]+([eE][-+]?[0-9]+)?   { yylval.name = strdup(yytext); return CONSTANT; }
[-+]?[0-9]+"."[eE][-+]?[0-9]+           { yylval.name = strdup(yytext); return CONSTANT; }
[a-zA-Z_]?'(\\.|[^\\'])+'               { yylval.name = strdup(yytext); return CONSTANT; }
    //[a-zA-Z][a-zA-Z0-9]*                    { yylval.name = strdup(yytext) return IDENTIFIER;}      /* No esta contemplado id_3 */
[a-zA-Z_][a-zA-Z0-9_]*                  { yylval.name = strdup(yytext) return IDENTIFIER;} 


%%

int yywrap(){
    return(1);
}

int column = 0;

/*Cuenta el final de la entrada, espacios y tabuladores*/
void count(){
    int i;
    for(i = 0; yytext[i] != '\0'; i++){
        //se utiliza para contar las columnas de cada línea en el análisis léxico
        if(yytext[i] == '\n'){
            column = 0; 

        //se ajusta la variable column para que se alinee a la siguiente posición de tabulación
        }else if (yytext[i] == '\t'){
            column += 8 - (column % 8); 

        //se utiliza para contar los caracteres de la línea actual, excluyendo los espacios y tabuladores
        }else{
            column++; 
        }
    }
}

/*Avanza el cursor al final de un comentario de varias lineas*/
void multiline_comment(void){
    
    //Guarda el caracter actual y el lookahead
    int cursor = input();
    int lookahead = input();

    while (lookahead != EOF && !(cursor == '*' && lookahead == '/')){
        
       //Aumenta el contador de linea
        if (cursor == '\n'){
            ++line_number;
        }
        
        //Avanza la posición del cursor y el lookahead
        cursor = lookahead;
        lookahead = input();
    }

    //Se asegura de que el comentario se haya cerrado
    if(lookahead == EOF){
        printf("The comment has not been closed.\n");
    }
    
}

/*Avanza el cursor al final de un comentario de una línea*/
void oneline_comment(){
   
    //Cursor
    int cursor = input();

    //Pasa por el lookahead hasta que se encuentre la nueva línea
    while (cursor != '\n' && cursor != EOF){ 
        cursor = input();
    }

    //Aumenta el contador de línea si se encuentra una nueva línea
    if(cursor == '\n'){
        line_number += 1;
    }
    
}
