%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
%}

%union {
	int type;
	double number;
    char* strVal;
    char* reserved;


}

%token INT FLOAT CHAR DOUBLE
%token SHORT LONG UNSIGNED SIGNED
%token VOID IF ELSE WHILE FOR DO SWITCH CASE RETURN BREAK CONTINUE DEFAULT PRINTF
%token LBRACE RBRACE LPAREN RPAREN SEMICOLON COMMA
%token ASSIGN PLUS MINUS TIMES DIVIDE 
%token EQ NEQ LT LTE GT GTE
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN INC DEC AND
%token CHARACTER STRING NUMBER FLOAT_NUMBER

%token <type> CHAR INT SIGNED UNSIGNED FLOAT DOUBLE CONST VOID
%token <number> NUMBER FLOAT_NUMBER
%token <strVal> IDENTIFIER STRING CHARACTER
%token <reserved>  IF ELSE WHILE FOR DO SWITCH CASE RETURN BREAK CONTINUE DEFAULT PRINTF

%left ASSIGN PLUS MINUS TIMES DIVIDE 
%%

program:
    INSTRUCTIONS
;

/*Types*/
type: 
    CHAR        { if(!global) global=-FALSE; current_type = T_CHAR;   }
	| INT       { if(!global) global=-FALSE; current_type = T_INT;    }
	| FLOAT     { if(!global) global=-FALSE; current_type = T_FLOAT;  }
	| DOUBLE    { if(!global) global=-FALSE; current_type = T_DOUBLE; }
	| SIGNED
	| UNSIGNED
	| VOID
;


%%
