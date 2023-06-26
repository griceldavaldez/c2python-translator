%{
#include "y.tab.h" // Archivo de encabezado generado por YACC/BISON
#include <stdio.h>    // Para funciones de entrada/salida estándar
#include <stdlib.h>   // Para funciones de gestión de memoria dinámica
#include <string.h>   // Para funciones de manipulación de cadenas de caracteres
#include <ctype.h>    // Para funciones de manipulación de caracteres

int lineCount = 1; // Variable para contar las líneas

typedef union {
    char* strVal;
    int intVal;
    float floatVal;
    char charVal;
    char* name;
    int type;
    int scope;
} YYSTYPE;

extern YYSTYPE yylval;

typedef struct {
    char* name;
    int type;
} Symbol;

typedef struct {
    Symbol* entries;
    int size;
} SymbolTable;

SymbolTable symTable;

void return_id(void);
%}

%option noyywrap

%%

"int"           { return INT; }
"float"         { return FLOAT; }
"char"          { return CHAR; }
"double"        { return DOUBLE; }
"void"          { return VOID; }

"short"         { return SHORT; }
"long"          { return LONG; }
"unsigned"      { return UNSIGNED; }
"signed"        { return SIGNED; }

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
"printf"        { return PRINTF; }

"{"             { return LBRACE; }
"}"             { return RBRACE; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMICOLON; }
","             { return COMMA; }
"."             { return('.'); }
"!"             { return ('!'); }
"="             { return (ASSIGN); }
"+"             { return (PLUS); }
"-"             { return (MINUS); }
"*"             { return (TIMES); }
"/"             { return (DIVIDE); }
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

[ \t\r]+        { /* Ignorar espacios en blanco, tabulaciones y retorno de carro */ }
\n              { lineCount++; /* Incrementar número de línea */}
'.'             { yylval.charVal = yytext[0]; return CHARACTER; }


\"[^\"]*\"                              { yylval.strVal = strdup(yytext); return STRING; }
[-]?[0-9]+                              { yylval.strVal = strdup(yytext); return CONSTANT; }
[-]?[0-9]+"."[0-9]+([eE][-+]?[0-9]+)?   { yylval.strVal = strdup(yytext); return CONSTANT; }
[-+]?[0-9]+"."[eE][-+]?[0-9]+           { yylval.strVal = strdup(yytext); return CONSTANT; }
[a-zA-Z][a-zA-Z0-9]*                    { return_id(); }
\"([^\"\\]|\\[^\n\\]|\\.)*\n            { // Regla para reconocer cadenas no cerradas
                                            printf("Error léxico en la línea %d: Cadena no cerrada\n", lineCount);
                                        }
\/\*([^*]|(\*+[^*/]))*\n                { // Regla para reconocer comentarios no cerrados
                                            printf("Error léxico en la línea %d: Comentario no cerrado\n", lineCount);
                                        }
.                                       { printf("Error léxico en la línea %d: Carácter no reconocido '%c'\n", lineCount, yytext[0]); /* Ignorar otros caracteres */ }

%%

int main() {
    yyparse();
    printf("Cantidad de líneas: %d\n", lineCount); // Imprime la cantidad de líneas
    return 1;
}

void return_id(){
    // Verificar si el identificador es válido
    if (strcmp(yytext, "int") == 0 || strcmp(yytext, "float") == 0 || strcmp(yytext, "char") == 0 || strcmp(yytext, "double") == 0 || strcmp(yytext, "void") == 0 || strcmp(yytext, "short") == 0 || strcmp(yytext, "long") == 0 || strcmp(yytext, "unsigned") == 0 || strcmp(yytext, "signed") == 0) {
        // Palabra clave válida, asignar el token correspondiente
        yylval.strVal = strdup(yytext);
        return IDENTIFIER;
    } else {
        // Identificador no válido, mostrar mensaje de error
        printf("Error léxico en la línea %d: Identificador no válido '%s'\n", lineCount, yytext);
    }
}