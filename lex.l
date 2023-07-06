/*Expresiones regulares para simplificar la representacion de tokens*/
DIGIT       [0-9]
LETTER      [a-zA-Z_]
EXPONENTIAL [Ee][+-]?{DIGIT}+
FS          (f|F|l|LETTER)
IS          (u|U|l|LETTER)*

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
    void multiline_comments();         //Comentarios de varias lineas
    void oneline_comment();    //Comentarios de una linea
    void count();               //Contador
%}

/*Definicion de los tokens*/
%%

"/*"                                            { multiline_comments(); }
"//"                                            { oneline_comment(); }
"#include ""<"((_|{LETTER}*)"."{LETTER}*)">"    { }
"const"                                         { return(CONST); }
"printf"                                        { yylval.name = strdup(yytext); return(PRINTF); }
"char"                                          { yylval.type = CHAR; return(CHAR); }
"double"                                        { yylval.type = DOUBLE; return(DOUBLE); }
"float"                                         { yylval.type = FLOAT; return(FLOAT); }
"int"                                           { yylval.type = INT; return(INT); }
"signed"                                        { yylval.type = SIGNED; return(SIGNED); }
"unsigned"                                      { yylval.type = UNSIGNED; return(UNSIGNED); }
"void"                                          { yylval.type = VOID; return(VOID); }
"short"                                          { yylval.type = SHORT; return(SHORT); }
"long"                                          { yylval.type = LONG; return(LONG); }
"continue"                                      { return CONTINUE; }
"default"                                       { return DEFAULT; }
"do"                                            { return DO; }
"if"                                            { return IF; }
"else"                                          { return ELSE; }
"switch"                                        { return SWITCH; }
"case"                                          { return CASE; }
"for"                                           { return FOR; }
"while"                                         { return WHILE; }
"return"                                        { return RETURN; }
"break"                                         { return BREAK; }
{LETTER}({LETTER}|{DIGIT})*                     { yylval.name = strdup(yytext); return(IDENTIFIER); }
("-")?{DIGIT}+("."{DIGIT}+)?                    { yylval.name = strdup(yytext); return(CONSTANT);}
0{DIGIT}+{IS}?                                  { yylval.name = strdup(yytext); return(CONSTANT); }
{DIGIT}+{IS}?                                   { yylval.name = strdup(yytext); return(CONSTANT); }
LETTER?'(\\.|[^\\'])+'                          { yylval.name = strdup(yytext); return(CONSTANT); }
('-')?{DIGIT}+{EXPONENTIAL}{FS}?                { yylval.name = strdup(yytext); return(CONSTANT); }
('-')?{DIGIT}*"."{DIGIT}+({EXPONENTIAL})?{FS}?  { yylval.name = strdup(yytext); return(CONSTANT); }
('-')?{DIGIT}+"."{DIGIT}*({EXPONENTIAL})?{FS}?  { yylval.name = strdup(yytext); return(CONSTANT); }
"+="                                            { return(ADD_ASSIGN); }
"-="                                            { return(SUB_ASSIGN); }
"*="                                            { return(MUL_ASSIGN); }
"/="                                            { return(DIV_ASSIGN); }
"%="                                            { return(MOD_ASSIGN); }
"++"                                            { return(INC); }
"--"                                            { return(DEC); }
"&&"                                            { return(AND); }
"||"                                            { return(OR); }
"<="                                            { return(LTE); }
">="                                            { return(GTE); }
"=="                                            { return(EQ); }
"!="                                            { return(NEQ); }
";"                                             { return(';'); }
","                                             { return(','); }
("{"|"<%")                                      { return('{'); }
"-"                                             { return('-'); }
"+"                                             { return('+'); }
"*"                                             { return('*'); }
"/"                                             { return('/'); }
"%"                                             { return('%'); }
"<"                                             { return('<'); }
">"                                             { return('>'); }
"?"                                             { return('?'); }
("}"|"%>")                                      { return('}'); }
":"                                             { return(':'); }
"="                                             { return('='); }
"("                                             { return('('); }
")"                                             { return(')'); }
("["|"<:")                                      { return('['); }
("]"|":>")                                      { return(']'); }
"."                                             { return('.'); }
"!"                                             { return('!'); }
["].*["]                                        { yylval.name = strdup(yytext); return(STR); }
['].[']                                         { yylval.name = strdup(yytext); return(CHARACTER); }                                        
[ \t\v\f]                                       { count(); }
\n                                              { ++line_number; }
.                                               { /*Unkown chars*/ }

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
void multiline_comments(){
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