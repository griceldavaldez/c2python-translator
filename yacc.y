%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

extern int yylex();
extern char* yytext;

void yyerror(const char* s);

struct SymbolTableEntry {
    char* identifier;
    char* type;
    struct SymbolTableEntry* next;
};

struct SymbolTable {
    struct SymbolTableEntry* entries[100];
};

struct SymbolTable symbolTable;

void initializeSymbolTable() {
    int i;
    for (i = 0; i < 100; i++) {
        symbolTable.entries[i] = NULL;
    }
}

void insertSymbol(char* identifier, char* type) {
    int index = (int)identifier[0] % 100;
    struct SymbolTableEntry* newEntry = (struct SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
    newEntry->identifier = strdup(identifier);
    newEntry->type = strdup(type);
    newEntry->next = NULL;

    if (symbolTable.entries[index] == NULL) {
        symbolTable.entries[index] = newEntry;
    } else {
        struct SymbolTableEntry* current = symbolTable.entries[index];
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = newEntry;
    }
}

bool symbolExists(char* identifier) {
    int index = (int)identifier[0] % 100;
    struct SymbolTableEntry* current = symbolTable.entries[index];
    while (current != NULL) {
        if (strcmp(current->identifier, identifier) == 0) {
            return true;
        }
        current = current->next;
    }
    return false;
}

void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

%}

%union {
    int type;
    double number;
    char* strVal;
}

%token INT FLOAT CHAR DOUBLE
%token SHORT LONG UNSIGNED SIGNED
%token VOID IF ELSE WHILE FOR DO SWITCH CASE RETURN BREAK CONTINUE DEFAULT PRINTF
%token LBRACE RBRACE LPAREN RPAREN SEMICOLON COMMA
%token ASSIGN PLUS MINUS TIMES DIVIDE 
%token EQ NEQ LT LTE GT GTE
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN INC DEC AND
%token CHARACTER STRING NUMBER FLOAT_NUMBER

%token <type> CHAR INT SIGNED UNSIGNED FLOAT DOUBLE VOID
%token <number> NUMBER FLOAT_NUMBER
%token <strVal> IDENTIFIER STRING CHARACTER
%token <reserved> IF ELSE WHILE FOR DO SWITCH CASE RETURN BREAK CONTINUE DEFAULT PRINTF

%type <strVal> typeSpecifier
%type <strVal> assignmentExpression
%type <strVal> additiveExpression
%type <strVal> multiplicativeExpression
%type <strVal> relationalExpression
%type <strVal> logicalAndExpression
%type <strVal> logicalOrExpression
%type <strVal> expression
%type <strVal> statement
%type <strVal> compoundStatement
%type <strVal> selectionStatement
%type <strVal> iterationStatement
%type <strVal> functionDefinition
%type <strVal> parameterList
%type <strVal> parameterDeclaration
%type <strVal> declarator
%type <strVal> initializer
%type <strVal> arraySpecifier

%%

program:
    declarationList
    {
        printf("Traducción exitosa de C a Python\n");
    }
    ;

declarationList:
    declaration
    |
    declarationList declaration
    ;

declaration:
    typeSpecifier declarator ';'
    {
        printf("Declaración en C: %s %s;\n", $1, $2);
        printf("Traducción a Python: %s = None\n", $2);
        
        if (symbolExists($2)) {
            yyerror("Error: El identificador ya ha sido declarado");
        } else {
            insertSymbol($2, $1);
        }
    }
    | functionDefinition
    ;

typeSpecifier:
    INT { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    | CHAR { $$ = "char"; }
    | DOUBLE { $$ = "double"; }
    | VOID { $$ = "void"; }
    ;

declarator:
    IDENTIFIER
    {
        $$ = $1;
    }
    | IDENTIFIER arraySpecifier
    {
        $$ = $1;
    }
    ;

arraySpecifier:
    '[' NUMBER ']'
    ;

functionDefinition:
    typeSpecifier declarator '(' parameterList ')' compoundStatement
    {
        printf("Definición de función en C: %s %s(%s)\n", $1, $2, $4);
        printf("Traducción a Python: def %s(%s):\n", $2, $4);
        printf("    %s\n", $6);
        
        if (symbolExists($2)) {
            yyerror("Error: El identificador ya ha sido declarado");
        } else {
            insertSymbol($2, $1);
        }
    }
    ;

parameterList:
    /* Empty */
    | parameterDeclaration
    | parameterList ',' parameterDeclaration
    ;

parameterDeclaration:
    typeSpecifier declarator
    ;

compoundStatement:
    '{' '}'
    | '{' statementList '}'
    ;

statementList:
    statement
    | statementList statement
    ;

statement:
    compoundStatement
    | selectionStatement
    | iterationStatement
    | expression ';'
    ;

selectionStatement:
    IF '(' expression ')' statement
    | IF '(' expression ')' statement ELSE statement
    ;

iterationStatement:
    WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')' ';'
    | FOR '(' expression ';' expression ';' expression ')' statement
    ;

expression:
    assignmentExpression
    ;

assignmentExpression:
    logicalOrExpression
    | IDENTIFIER ASSIGN assignmentExpression
    {
        printf("Asignación en C: %s = %s\n", $1, $3);
        printf("Traducción a Python: %s = %s\n", $1, $3);
        
        if (!symbolExists($1)) {
            yyerror("Error: El identificador no ha sido declarado");
        }
    }
    ;

logicalOrExpression:
    logicalAndExpression
    | logicalOrExpression "||" logicalAndExpression
    ;

logicalAndExpression:
    relationalExpression
    | logicalAndExpression "&&" relationalExpression
    ;

relationalExpression:
    additiveExpression
    | relationalExpression '<' additiveExpression
    | relationalExpression '>' additiveExpression
    | relationalExpression LTE additiveExpression
    | relationalExpression GTE additiveExpression
    | relationalExpression EQ additiveExpression
    | relationalExpression NEQ additiveExpression
    ;

additiveExpression:
    multiplicativeExpression
    | additiveExpression '+' multiplicativeExpression
    | additiveExpression '-' multiplicativeExpression
    ;

multiplicativeExpression:
    expression
    | multiplicativeExpression '*' expression
    | multiplicativeExpression '/' expression
    ;

%%

int main() {
    initializeSymbolTable();
    yyparse();
    return 0;
}