%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int lineCount = 1;

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
"."             { return '.'; }
"!"             { return '!'; }
"="             { return ASSIGN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
"<="            { return LTE; }
">"             { return GT; }
">="            { return GTE; }
"+="            { return ADD_ASSIGN; }
"-="            { return SUB_ASSIGN; }
"*="            { return MUL_ASSIGN; }
"/="            { return DIV_ASSIGN; }
"%="            { return MOD_ASSIGN; }
"++"            { return INC; }
"--"            { return DEC; }
"&&"            { return AND; }

[ \t\r]+        { /* Ignorar espacios en blanco, tabulaciones y retorno de carro */ }
\n              { lineCount++; }
.               { printf("Error léxico en la línea %d: Carácter no reconocido '%c'\n", lineCount, yytext[0]); }

%%

void return_id(void) {
    yylval.strVal = strdup(yytext);
    yylval.intVal = 0;
    yylval.floatVal = 0.0;
    yylval.charVal = '\0';
    yylval.name = NULL;
    yylval.type = -1;
    yylval.scope = -1;
    return ID;
}

int yywrap(void) {
    return 1;
}