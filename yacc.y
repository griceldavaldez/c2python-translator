%{
#include <stdio.h>
#include <string.h>

extern char* yytext;
extern int yylex(); // Declaración de la función generada por Lex
extern FILE* yyin; // Archivo de entrada para Lex
FILE* yyout; // Archivo de salida para la traducción a Python
char copySentence[200];
void yyerror(const char* s); // Declaración de la función de error

%}

%union {
    char* strVal;
    int intVal;
    float floatVal;
    char charVal;
    char* name;
    int type;
    int scope;
} 

%token LCLASP RCLASP SEMICOLON ASSIGN  RETURN  COMMA  MAIN LPAREN RPAREN LBRACE RBRACE IF ELSE WHILE FOR DO SWITCH CASE BREAK CONTINUE DEFAULT PRINTF  
%token PLUS MINUS TIMES DIVIDE EQ NEQ LT LTE GT GTE ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN INC DEC AND OR   
%token <strVal> INT IDENTIFIER CONSTANT  FLOAT CHAR DOUBLE VOID SHORT LONG UNSIGNED SIGNED  STRING CONST
%token <type> CHARACTER 

%type <strVal> constantDeclaration compoundStatement basicExpression conditionalStatement declarationList declaration expression conditionalExpression statement statementList functionDeclaration variableDeclarationList
%type <strVal> typeSpecifier initializer variableDeclaration forLoop arraySpecifier assignmentStatement  assignmentExpression functionSignature functionCallStatement 
%type <strVal> logicalOrExpression logicalAndExpression equalityExpression relationalExpression additiveExpression multiplicativeExpression unaryExpression postfixExpression argumentList parameterList parameterDeclaration
%left INC DEC
%left AND OR
%left TIMES DIVIDE
%start program
%%

program :  mainFunction     
        | declarationList   {printf("entro en declarationList\n");}
        ;

mainFunction:   typeSpecifier MAIN LPAREN RPAREN LBRACE compoundStatement RETURN CONSTANT SEMICOLON RBRACE      
                {
                    fprintf(yyout,"if __name__ == '__main__':\n");
                    fprintf(yyout,"\t%s\n",$6);
                }
            ;

declarationList : /* empty */   {printf("entro en declarationList null\n");}
                 | declaration  {printf("imprime: %s\n",$1);}
                 | declarationList declaration {printf("entro en declarationList declaration\n");}
                 ;

declaration : typeSpecifier variableDeclarationList     { strcat(copySentence,$1); strcat(copySentence," "); strcat(copySentence,$2); printf("copysentence = %s\n",copySentence); strcpy($$, copySentence); strcpy(copySentence, "");}
            | CONST typeSpecifier constantDeclaration   { $$ = $3;}
            | typeSpecifier functionDeclaration         { printf("en typeSpecifier functionDeclaration\n");}
            ;

typeSpecifier :  CHARACTER       {}
	           | INT             { $$ = $1; printf("yacc: typeSpecifier: %s\n",yytext);}
	           | FLOAT           {}
	           | DOUBLE          {}
	           | SIGNED          {}
	           | UNSIGNED        {}
	           | VOID            {}
               ;
                
variableDeclarationList : variableDeclaration
                        | variableDeclaration SEMICOLON     { $$ = $1; }
                        | variableDeclarationList ASSIGN initializer SEMICOLON
                        | variableDeclarationList COMMA variableDeclaration SEMICOLON   { strcat(copySentence,$1); strcat(copySentence,", "); strcat(copySentence,$3); strcpy($$, copySentence); strcpy(copySentence, ""); }
                          ;

variableDeclaration : IDENTIFIER arraySpecifier     { strcat(copySentence,$1); strcat(copySentence,$2); strcpy($$, copySentence); strcpy(copySentence, ""); }
                     | IDENTIFIER   {printf("Desde yacc %s\n",$1);}
                     ;

initializer: IDENTIFIER     {$$ = $1 ;} 
	        | CONSTANT      {$$ = $1 ;}
	        | STRING        {$$ = $1 ;}
	        | CHAR          {$$ = $1 ;}
	        ;

arraySpecifier : LCLASP RCLASP   { strcat(copySentence, "[]"); strcpy($$, copySentence); strcpy(copySentence, ""); }
               | LCLASP CONSTANT RCLASP        { strcat(copySentence, "["); strcat(copySentence, $2); strcat(copySentence, "]"); strcpy($$, copySentence); strcpy(copySentence, ""); }

constantDeclaration :  IDENTIFIER ASSIGN CONSTANT SEMICOLON     {fprintf(yyout,"%s = %s\n", $1, $3);}
                     ;

functionDeclaration : functionSignature LBRACE compoundStatement RBRACE   {fprintf(yyout,"def %s:\n\t%s", $1, $3);}
                     ;


functionSignature : IDENTIFIER LPAREN parameterList RPAREN           {fprintf(yyout,"def %s(%s): \n", $1, $3);}
                   ;

parameterList : /* empty */     {}
               | parameterDeclaration
               | parameterList COMMA parameterDeclaration
               ;

parameterDeclaration : typeSpecifier IDENTIFIER     {$$ = $2 ;}
                      ;

compoundStatement :  declarationList statementList     { strcat(copySentence, $1); strcat(copySentence, "\n\t"); strcat(copySentence, $2); strcpy($$, copySentence); strcpy(copySentence, ""); }
                  ;

statementList :  statement    
               | statementList statement    
               ;

statement : /* empty */     {}
          | assignmentStatement
          | loopStatement
          | conditionalStatement
          | nestedStatement
          | functionCallStatement
          ;

assignmentStatement : IDENTIFIER ASSIGN expression SEMICOLON  { strcat(copySentence, $1); strcat(copySentence, " = "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}
                     ;

loopStatement : whileLoop
               | forLoop
               | doWhileLoop
               ;

whileLoop : WHILE LPAREN expression RPAREN LBRACE compoundStatement RBRACE  {fprintf(yyout,"WHILE %s:\n %s\n",$3 ,$6);}
           ;

forLoop : FOR LPAREN assignmentStatement expression SEMICOLON assignmentStatement RPAREN LBRACE compoundStatement RBRACE {fprintf(yyout,"for %s in range(%s):\n\t%s",$3 ,$4, $9);}
         ;

doWhileLoop : DO LBRACE compoundStatement RBRACE WHILE LPAREN expression RPAREN SEMICOLON {fprintf(yyout,"While True:\n\t%s\n\tif not %s:\n\tbreak\n",$3 ,$7);}
              ;

conditionalStatement : IF LPAREN expression RPAREN LBRACE compoundStatement RBRACE {fprintf(yyout,"IF %s:\n %s", $3, $6);}
                      | IF LPAREN expression RPAREN LBRACE compoundStatement RBRACE ELSE LBRACE compoundStatement RBRACE {fprintf(yyout,"IF %s:\n %s\n ELSE \n %s", $3, $6, $10);}
                      ;

nestedStatement : LBRACE compoundStatement RBRACE
                 ;

functionCallStatement : functionSignature SEMICOLON          {$$ = $1;}
                        ;


expression : 
            CONSTANT
           | IDENTIFIER
           | assignmentExpression
           | conditionalExpression { printf("conditionalExpression: %s\n",$1);}
           ;

assignmentExpression : IDENTIFIER ASSIGN expression     { strcat(copySentence, $1); strcat(copySentence, " = "); strcat(copySentence, $3); strcpy($$, copySentence); strcpy(copySentence, ""); }
                      ;

conditionalExpression : logicalOrExpression
                       ;

logicalOrExpression : logicalAndExpression
                      | logicalOrExpression OR logicalAndExpression         { strcat(copySentence, $1); strcat(copySentence, " OR "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}
                      ;

logicalAndExpression : equalityExpression
                       | logicalAndExpression AND equalityExpression        { strcat(copySentence, $1); strcat(copySentence, " AND "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}
                       ;

equalityExpression : relationalExpression
                    | equalityExpression EQ relationalExpression            { strcat(copySentence, $1); strcat(copySentence, " == "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}   
                    | equalityExpression NEQ relationalExpression           { strcat(copySentence, $1); strcat(copySentence, " != "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}   
                    ;

relationalExpression : additiveExpression
                      | relationalExpression LT additiveExpression          { strcat(copySentence, $1); strcat(copySentence, " < "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}
                      | relationalExpression LTE additiveExpression         { strcat(copySentence, $1); strcat(copySentence, " <= "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}
                      | relationalExpression GT additiveExpression          { strcat(copySentence, $1); strcat(copySentence, " > "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}
                      | relationalExpression GTE additiveExpression         { strcat(copySentence, $1); strcat(copySentence, " >= "); strcat(copySentence, $3); strcpy($$, copySentence); printf("%s\n",copySentence); strcpy(copySentence, "");}
                      ;

additiveExpression : multiplicativeExpression
                    | additiveExpression PLUS multiplicativeExpression      { strcat(copySentence, $1); strcat(copySentence, " + "); strcat(copySentence, $3); strcpy($$, copySentence); strcpy(copySentence, ""); }
                    | additiveExpression MINUS multiplicativeExpression     { strcat(copySentence, $1); strcat(copySentence, " - "); strcat(copySentence, $3); strcpy($$, copySentence); strcpy(copySentence, ""); }
                    ;

multiplicativeExpression : unaryExpression              { strcat(copySentence, $1); strcpy($$, copySentence); strcpy(copySentence, ""); }   
                          | multiplicativeExpression TIMES unaryExpression      { strcat(copySentence, $1); strcat(copySentence, " * "); strcat(copySentence, $3); strcpy($$, copySentence); strcpy(copySentence, ""); }
                          | multiplicativeExpression DIVIDE MINUS multiplicativeExpression     { strcat(copySentence, $1); strcat(copySentence, " / -"); strcat(copySentence, $4); strcpy($$, copySentence); strcpy(copySentence, ""); }
                          | multiplicativeExpression DIVIDE  multiplicativeExpression     { strcat(copySentence, $1); strcat(copySentence, " / "); strcat(copySentence, $3); strcpy($$, copySentence); strcpy(copySentence, ""); }
                          ;

unaryExpression : postfixExpression
                 ;

postfixExpression : basicExpression    
                   | postfixExpression LPAREN argumentList RPAREN        { strcat(copySentence, $1); strcat(copySentence, "( "); strcat(copySentence, $3); strcat(copySentence, " )"); strcpy($$, copySentence); strcpy(copySentence, ""); }
                   | postfixExpression LPAREN RPAREN                     { strcat(copySentence, $1); strcat(copySentence, "( "); strcat(copySentence, " )"); strcpy($$, copySentence); strcpy(copySentence, ""); }
                   ;

basicExpression : IDENTIFIER    { printf("basicExpression: %s \n",$1) ;$$ = $1;}
                | CONSTANT      { $$ = $1;}
                | LPAREN expression RPAREN          { strcat(copySentence, "( "); strcat(copySentence, $2); strcat(copySentence, " )"); strcpy($$, copySentence); strcpy(copySentence, ""); }
                ;

argumentList : /* empty */          {}
              | argumentList COMMA expression       { strcat(copySentence, $1); strcat(copySentence, ", "); strcat(copySentence, $3); strcpy($$, copySentence); strcpy(copySentence, ""); }
              ;




%%

void yyerror(const char* s) {
    printf("Error: %s ", s);
    printf("en : %s\n", yytext);

}

int main(int argc, char** argv) {
    // Verificar que se hayan proporcionado los nombres de los archivos de entrada y salida
    if (argc < 3) {
        printf("Error. Faltan parametros\n");
        return 0;
    }

    // Abrir archivos de entrada y salida
    if (((yyin = fopen(argv[1], "r")) == NULL) || ((yyout = fopen(argv[2], "w")) == NULL)) {
        printf("No se pudo abrir el archivo.\n");
        return 0;
    }

    yyparse(); // Llamar al analizador sintáctico

    // Cerrar archivos de entrada y salida
    fclose(yyin);
    fclose(yyout);
    return 0;
}