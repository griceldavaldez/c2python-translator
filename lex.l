%{
#include "y.tab.h" // Archivo de encabezado generado por YACC/BISON
#include <stdio.h>    // Para funciones de entrada/salida estándar
#include <stdlib.h>   // Para funciones de gestión de memoria dinámica
#include <string.h>   // Para funciones de manipulación de cadenas de caracteres
#include <ctype.h>    // Para funciones de manipulación de caracteres

int lineCount = 1; // Variable para contar las líneas

extern int yyparse(); // Declaración de la función yyparse() definida en yacc.y

typedef struct {
    char* name;
    int type;
} Symbol;

typedef struct {
    Symbol* entries;
    int size;
} SymbolTable;

SymbolTable symTable;

%}

%option noyywrap

%%

"int"           { yylval.strVal = strdup(yytext); return INT; }
"float"         { return FLOAT; }
"char"          { return CHAR; }
"double"        { return DOUBLE; }
"void"          { return VOID; }

"const"         { return CONST; }
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
"return"        { printf("lex: %s\n",yytext); return RETURN; }
"break"         { return BREAK; }
"continue"      { return CONTINUE; }
"default"       { return DEFAULT; }
"printf"        { return PRINTF; }


"{"             { return LBRACE; }
"}"             { return RBRACE; }
"["             { return LCLASP; }
"]"             { return RCLASP; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMICOLON; }
","             { return COMMA; }
"."             { return('.'); }
"#"             { return('#'); }
"!"             { return ('!'); }
"="             { return (ASSIGN); }
"+"             { return (PLUS); }
"-"             { return (MINUS); }
"*"             { return (TIMES); }
"/"             { printf("lex: %s\n",yytext); return (DIVIDE); }
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

"main"          { printf("lex: %s\n",yytext); return MAIN; }
"#include".*    { printf("lex: %s\n",yytext); /* Ignorar líneas que comiencen con "#include" */ }
[ \t\r]+        { /* Ignorar espacios en blanco, tabulaciones y retorno de carro */ }
\n              { lineCount++; /* Incrementar número de línea */}
'.'             { yylval.type = yytext[0]; return CHARACTER; }


\"[^\"]*\"                              { yylval.strVal = strdup(yytext); return STRING; }
[-]?[0-9]+                              { printf("lex: %s\n",yytext); yylval.strVal = strdup(yytext); return CONSTANT; }
[-]?[0-9]+"."[0-9]+([eE][-+]?[0-9]+)?   { printf("lex: %s\n",yytext); yylval.strVal = strdup(yytext); return CONSTANT; }
[-+]?[0-9]+"."[eE][-+]?[0-9]+           { printf("lex: %s\n",yytext); yylval.strVal = strdup(yytext); return CONSTANT; }
[a-zA-Z][a-zA-Z0-9]*                    { printf("lex: %s\n",yytext); yylval.strVal = strdup(yytext); return(IDENTIFIER);}      /* No esta contemplado id_3 */

\"([^\"\\]|\\[^\n\\]|\\.)*\n            { // Regla para reconocer cadenas no cerradas
                                            printf("Error léxico en la línea %d: Cadena no cerrada\n", lineCount);
                                        }
\/\*([^*]|(\*+[^*/]))*\n                { // Regla para reconocer comentarios no cerrados
                                            printf("Error léxico en la línea %d: Comentario no cerrado\n", lineCount);
                                        }
.                                       { printf("Error léxico en la línea %d: Carácter no reconocido '%c'\n", lineCount, yytext[0]); /* Ignorar otros caracteres */ }

%%
