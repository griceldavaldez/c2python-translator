%{
    #define _GNU_SOURCE
    #define FALSE 0
    #define TRUE 1
	#define T_INT 2
	#define T_CHAR 3
	#define T_FLOAT 4
	#define T_DOUBLE 5
	#define T_FUNCTION 6
	#define T_CONST 7
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    /*Estructura de datos para anticipación de símbolos*/
    struct symrec{
        char *name;             //Nombre del simbolo
        int type;               //Tipo de simbolo
        double value;           //Valor anticipado de la variable
		int data_type;
        int function;           //Funcion
		int is_const;
        struct symrec *next;    //Puntero del siguiente registro
    };

    typedef struct symrec symrec;

    /*Tabla de simbolos*/
    extern symrec *sym_table;

    extern int yylex(void); // Declaración de la función generada por Lex
    extern FILE *yyin;      // Archivo de entrada para Lex
    FILE *yyout; // Archivo de salida para la traducción a Python
    extern char *yytext;    //Reconoce tokens de entrada
    extern int line_number; //Numero de linea
	extern char *get_type(int type);
	extern int is_var_constant(char *name);
	extern int is_valid_operation(char *name1, char *name2, char op);

    /*Variables para manipular la tabla de simbolos*/
    symrec *sym_table = (symrec *)0;
    symrec *s;
    symrec *symtable_set_type;

    /*Banderas para manejar ciertas acciones*/
    int is_function=0;          
	int is_switch = FALSE;
	int dimension = 0;
    int error=0;                
    int modifier = 0;             
    int ind = 0;                //Indentation
	int current_type;
	int current_operation;
	char type_aux[100];



    /*Declaracion de funciones*/
    int yyerror(char *s); //Funcion para manejar errores
    void add_indent(); //Funcion para manejar la indentacion
    void print(char *token); //Funcion para escribir en el archivo de salida .py
    /*Funciones para interactuar con la tabla de simbolos*/
    symrec *putsym ();
    symrec *getsym ();
    char* get_type(int type);
    int is_var_constant(char *name);
    int is_valid_operation(char *name1, char *name2, char op);


%}

%union
{
	int type;
	double value;
	char *name;
	int data_type;
	struct symrec *tptr;
}

/*Operadores y tokens*/
%token INC DEC LTE GTE EQ NEQ AND OR
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN 
%token CASE DEFAULT IF ELSE BREAK RETURN SWITCH WHILE DO FOR CONTINUE 

/*Tipos de tokens*/
%token <name> IDENTIFIER PRINTF STR CHARACTER CONSTANT 
%token <type> CHAR INT FLOAT DOUBLE CONST VOID SHORT LONG SIGNED UNSIGNED

/*Otros*/
%type <type> typeSpecifier declarationSpecifiers type_qualifier
%type <name> initDeclarator initDeclaratorList functionDefinition initDirectDeclarator directDeclarator declarator
%type <name> parameterTypeList arrayList arrayDeclaration parameterList parameterDeclaration 
%type <name> initializer initializerList
%type <tptr> declaration

%left INC DEC

/*%nonassoc IF_AUX*/
%nonassoc ELSE

%start c2python

%%

/*Traductor*/
c2python
	: externalDeclaration
	| c2python externalDeclaration
	;


/*Declaraciones*/
declaration
    : declarationSpecifiers initDeclaratorList ';' {print("\n"); add_indent();}
    {
        for(symtable_set_type=sym_table; symtable_set_type!=(symrec *)0; symtable_set_type=(symrec *)symtable_set_type->next)
			if(symtable_set_type->type==-1)
				symtable_set_type->type=$1;
	}
	| declarationSpecifiers initDeclaratorList error { yyerror("Falta un \";\""); yyerrok; }
	;

argumentExprList
	: assignmentExpr
	| argumentExprList ',' { fprintf(yyout, ", "); } assignmentExpr
	;


/*Operaciones de suma y resta*/
additiveExpr
	: multiplicativeExpr
	| additiveExpr '+' { print("+"); current_operation=TRUE; } multiplicativeExpr {current_operation=FALSE; if (is_valid_operation(yyval.name, type_aux, '+')) yyerrok; }
	| additiveExpr '-' { print("-"); current_operation=TRUE; } multiplicativeExpr {current_operation=FALSE; if (is_valid_operation(yyval.name, type_aux, '-')) yyerrok; }
    | additiveExpr '+' { print("+"); } error { yyerrok;}
	| additiveExpr '-' { print("-"); } error { yyerrok;}
	;

/*Operaciones de multiplicacion, division y modulo*/
multiplicativeExpr
    : postfixExpr
	| multiplicativeExpr '*' { print("*"); current_operation=TRUE; } postfixExpr {current_operation=FALSE; if (is_valid_operation(yyval.name, type_aux, '*')) yyerrok; }
    | multiplicativeExpr '*' { print("*"); } error { yyerrok;}
    | multiplicativeExpr '/' { print("/"); current_operation=TRUE;} postfixExpr {current_operation=FALSE; if (is_valid_operation(yyval.name, type_aux, '/')) yyerrok; }
    | multiplicativeExpr '/' { print("/"); } error { yyerrok;}
    | multiplicativeExpr '%' { print(" %% "); } postfixExpr
    | multiplicativeExpr '%' { print(" %% "); } error { yyerrok;}
    ;

/*Operadores de igualdad*/
equality_expr
	: relationalExpr
    | equality_expr EQ { print("=="); } relationalExpr
	| equality_expr NEQ { print("!="); } relationalExpr
	| equality_expr EQ { print("=="); } error {yyerrok;}
	| equality_expr NEQ { print("!="); } error {yyerrok;}
    ;


/*Operadores de relacion*/
relationalExpr
	: additiveExpr
    | relationalExpr '<' { print("<"); } additiveExpr
	| relationalExpr '>' { print(">"); } additiveExpr
	| relationalExpr '<' { print("<"); } error {yyerrok;}
	| relationalExpr '>' { print(">"); } error {yyerrok;}
	| relationalExpr LTE { print("<="); } additiveExpr
	| relationalExpr GTE { print(">="); } additiveExpr
	;

/*Operador logico and*/
logicalAndExpr
	: equality_expr
	| logicalAndExpr AND { fprintf(yyout, " and "); } equality_expr
	| logicalAndExpr AND { fprintf(yyout, " and "); } error {yyerrok;}
    ;

/*'Operador logico or*/
logicalOrExpr
	: logicalAndExpr
	| logicalOrExpr OR { fprintf(yyout, " or "); } logicalAndExpr
    | logicalOrExpr OR { fprintf(yyout, " or "); } error {yyerrok;}
    ;


primaryExpr
	: IDENTIFIER { fprintf(yyout, "%s", yytext); if(current_operation) strcpy(type_aux,$1);}
	| CHARACTER { fprintf(yyout, "%s", yytext); }
	| STR { fprintf(yyout, "%s", yytext); }
	| CONSTANT { fprintf(yyout, "%s", yytext); }
	| '(' { print("("); } expr ')' { print(")"); }
	;

/*Expresion condicional*/
conditional_expr
	: logicalOrExpr
	| logicalOrExpr '?' { fprintf(yyout, " ? "); } expr ':' { fprintf(yyout, " : "); } conditional_expr
	;


postfixExpr
	: primaryExpr
	| postfixExpr '[' { print("["); }  expr ']' { print("]"); }
	| postfixExpr '(' { print("("); } ')' { print(")"); }
	| postfixExpr '(' { print("("); } argumentExprList ')' { print(")"); }
	| postfixExpr INC { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, "+=1"); } //var++
	| postfixExpr DEC { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, "-=1"); } //var--
	| INC IDENTIFIER { if(is_var_constant($2)) yyerrok; fprintf(yyout, "%s+=1", $2); } //++var
	| DEC IDENTIFIER { if(is_var_constant($2)) yyerrok; fprintf(yyout, "%s-=1", $2); } //--var
	;


/*Expresiones de asigancion*/
assignmentExpr
	: conditional_expr 
	| postfixExpr assignmentOperator assignmentExpr
    | error assignmentOperator assignmentExpr {yyerrok;}
	;

/*Operadores de asignacion*/
assignmentOperator
	: '=' { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, " = "); } 
	| MUL_ASSIGN { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, " *= "); }
	| DIV_ASSIGN { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, " /= "); }
	| MOD_ASSIGN { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, " %%= "); }
	| ADD_ASSIGN { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, " += "); }
	| SUB_ASSIGN { if(is_var_constant(yyval.name)) yyerrok; fprintf(yyout, " -= "); }
	;

/*expresiones*/
expr
	: assignmentExpr
	| expr ',' { fprintf(yyout, ", "); } assignmentExpr
	;


constantExpr
	: conditional_expr
	;


initDeclaratorList
	: initDeclarator
    {
        s = getsym($1);
    	if(s==(symrec *)0) s = putsym($1);
        else {
    		yyerror("Variable previamente declarada");
    		yyerrok;
    	}
    }
	| initDeclaratorList ',' initDeclarator { add_indent(); }
    {
        s = getsym($3);
        if(s==(symrec *)0) s = putsym($3);
        else {
            yyerror("Variable previamente declarada");
            yyerrok;
        }
    }
    | initDeclaratorList ',' error { yyerror("Error. Se recibe un ',' extra"); }
	;

initDeclarator
	: declarator
	| initDirectDeclarator '=' initializer { fprintf(yyout, "%s", $3); }
	;

/*Declaracion de parametros*/
parameterDeclaration
	: { is_function = 1; } declarationSpecifiers declarator { $$ = $3; }
	;

/*Inicializacion de parametros*/
initializerList
	: initializer
	| initializerList ',' initializer { asprintf(&$$, "%s, %s", $1, $3); }
	;

initializer
	: IDENTIFIER
	| CONSTANT
	| STR
	| CHARACTER
	| '{' initializerList '}' { asprintf(&$$, "[%s]", $2); }
	;


/*Tipos de datos*/
typeSpecifier
	: CHAR   { if(!modifier) modifier=-FALSE; current_type = T_CHAR;   }
	| INT    { if(!modifier) modifier=-FALSE; current_type = T_INT;    }
	| FLOAT  { if(!modifier) modifier=-FALSE; current_type = T_FLOAT;  }
	| DOUBLE { if(!modifier) modifier=-FALSE; current_type = T_DOUBLE; }
	| SIGNED
	| UNSIGNED
	| VOID
    | SHORT
    | LONG
	;

declarationSpecifiers
	: typeSpecifier
	| typeSpecifier declarationSpecifiers
	| type_qualifier
	| type_qualifier declarationSpecifiers
	;

type_qualifier
	: CONST {modifier = TRUE;}
	;

declarator
	: directDeclarator
	;

/*Funciones y arrays*/
directDeclarator
    : IDENTIFIER { if (is_function)is_function = 0; }
    | IDENTIFIER '[' ']' { if (!is_function) fprintf(yyout, " %s = [] \n", $1); else is_function = 0; }
	| IDENTIFIER arrayList { 
		if (!is_function) fprintf(yyout, "%s = [%s] \n", $1, $2); 
		else is_function = 0; add_indent();}
    | IDENTIFIER '[' CONSTANT ']' {fprintf(yyout, "%s = [None] * %s\n",$1,$3);	add_indent();}
    | IDENTIFIER '(' ')' { if (!is_function)fprintf(yyout, "def %s():", $1); else is_function = 0; }
	| IDENTIFIER '(' parameterTypeList ')' { 
		if (!is_function) fprintf(yyout, "def %s(%s):", $1, $3); 
		else is_function = 0; }
    ;

/*Arrays*/
initDirectDeclarator
	: IDENTIFIER { if (!is_function) fprintf(yyout, "%s = ", $1); else is_function = 0; }
	| IDENTIFIER arrayDeclaration { if (!is_function) fprintf(yyout, "%s = ", $1); else is_function = 0; } //@todo add_indent()
	| IDENTIFIER arrayList { if (!is_function) fprintf(yyout, "%s = ", $1); else is_function = 0; }
	;

/*Lista de rrays*/
arrayList
	: arrayDeclaration
	| arrayList arrayDeclaration { asprintf(&$$, "[None] * %s for i in range(%s)", $2, $1); }
	;

/*Declaracion de Arrays*/
arrayDeclaration
	: '[' ']' { asprintf(&$$, "[] "); } //@todo add_indent()
	| '[' CONSTANT ']' { asprintf(&$$, "%s",$2); } //@todo add_indent()
	;

/*Tipo de parametro*/
parameterTypeList
	: parameterList
	;

/*Lista de parametros*/
parameterList
	: parameterDeclaration
	| parameterList ',' parameterDeclaration { asprintf(&$$, "%s, %s", $1, $3); }
	;


output
	: PRINTF '(' STR ')' ';' {fprintf(yyout, "print(%s)\n", $3); add_indent();}
	| PRINTF '(' STR ',' {fprintf(yyout, "print(%s %% (", $3);} outputList ')' ';' {print("))\n"); add_indent();}


outputList
	: IDENTIFIER {fprintf(yyout, "%s", $1);}
	| outputList ',' IDENTIFIER {fprintf(yyout, ",%s", $3);}

/*Inicio y fin de los bloques*/
openBrace
    : '{'
    {
  		fprintf(yyout,"\n");
  		ind++; 
		add_indent();
  	}
  	;

closeBrace
    : '}'
    {
  		fprintf(yyout,"\n");
  		ind--; 
		add_indent();
  	}
  	;

/*Lista de sentencias*/
statementList
	: statement
	| statementList statement
	;

/*Declaracion de sentencias*/
exprStatement
	: ';' { print("\n"); add_indent(); }
	| expr ';' { print("\n"); add_indent(); }
    | expr error { yyerror("Falta un \";\" en la sentencia");yyerrok; }
	;


/*Declaraciones compuestas*/
compoundStatement
    : openBrace closeBrace
    | openBrace statementList closeBrace
    | openBrace declarationList closeBrace
    | openBrace declarationList statementList closeBrace
    | '{' error { yyerror("Falta una \"}\""); yyerrok; }
    ;

/*Lista de declaraciones*/
declarationList
	: declaration
	| declarationList declaration
	;

/*Sentencias*/
statement
	: labeledStatement
	| output
	| compoundStatement
	| exprStatement
	| IF { print("if"); } '(' { print("("); } expr ')' { print("):"); } statement
	| ELSE IF{ print("elif"); } '(' { print("("); } expr ')' { print("):"); } statement
	| ELSE {print("else:"); } statement
	| SWITCH { fprintf(yyout, "match "); is_switch = TRUE;}'(' expr ')' { print(":"); } statement {is_switch = FALSE;}
	| iterationStatement
	| jumpStatement
	;

/*Declaraciones etiquetadas*/
labeledStatement
	: CASE { fprintf(yyout, "case "); } constantExpr ':' { fprintf(yyout, ":\n\t"); add_indent();} statement {print("\t");}
	| DEFAULT { fprintf(yyout, "case _ "); } ':' { fprintf(yyout, ":\n\t "); add_indent();} statement
	;


/*While*/
while
    : WHILE { print("while "); }
  	;

postfixFor
	: IDENTIFIER INC { fprintf(yyout, "):\t"); add_indent();}
	| IDENTIFIER DEC { fprintf(yyout, ",-1):\t"); add_indent();}
	| INC IDENTIFIER { fprintf(yyout, "):\t"); add_indent();}
	| DEC IDENTIFIER { fprintf(yyout, ",-1):\t"); add_indent();}
	;

/*Saltos*/
jumpStatement
	: CONTINUE { print("continue");} ';' { print("\n"); add_indent(); }
	| BREAK    { if(!is_switch) print("break"); } ';' { print("\n"); add_indent(); }
	| RETURN   { print("return");  } ';' { print("\n"); add_indent(); }
	| RETURN   { print("return "); } expr ';' { print("\n"); add_indent(); }
	| CONTINUE error { yyerror("Falta un \";\" despues de 'continue'"); yyerrok; }
	| BREAK error { yyerror("Falta un \";\" despues de 'break'"); yyerrok;}
	;

/* Condiciones de loops */
loopsRelational
    : IDENTIFIER '<' CONSTANT ';' { fprintf(yyout, "%s", $3);} postfixFor ')'
    | IDENTIFIER LTE CONSTANT ';' { int n = atoi($3)+1; fprintf(yyout, "%d", n);} postfixFor ')'
	| IDENTIFIER '<' IDENTIFIER ';' { fprintf(yyout, "%s", $3);} postfixFor ')'
    | IDENTIFIER LTE IDENTIFIER ';' { int n = atoi($3)+1; fprintf(yyout, "%d", n);} postfixFor ')'
	| IDENTIFIER '>' CONSTANT ';' { fprintf(yyout, "%s", $3);} postfixFor ')'
    | IDENTIFIER GTE CONSTANT ';' { int n = atoi($3)+1; fprintf(yyout, "%d", n);} postfixFor ')'
	| IDENTIFIER '>' IDENTIFIER ';' { fprintf(yyout, "%s", $3);} postfixFor ')'
    | IDENTIFIER GTE IDENTIFIER ';' { int n = atoi($3)+1; fprintf(yyout, "%d", n);} postfixFor ')'


iterationStatement
    : while '(' {print("(");} expr ')' {print("):");} statement
    | while error expr ')' statement { yyerror("Falta un \"(\"");yyerrok; }
    | DO { print("while(1):"); add_indent();} statement WHILE '(' { print("\tif not ("); } expr ')' { print("):\n\t"); add_indent(); print("\tbreak\n"); } ';' {add_indent();}
    | FOR '(' IDENTIFIER '=' CONSTANT ';' { fprintf(yyout, "for %s in range(%s,", $3, $5); } loopsRelational
	| FOR '(' IDENTIFIER '=' IDENTIFIER ';' { fprintf(yyout, "for %s in range(%s,", $3, $5); } loopsRelational
	;


/*Declarations*/
externalDeclaration
	: functionDefinition
	| declaration
	;

/*Funciones*/
functionDefinition
	: declarationSpecifiers declarator compoundStatement
	{
		s = getsym($2);
		if(s==(symrec *)0) s = putsym($2,$1,1);
		else {
			printf("Function already declared.");
			yyerrok;
		}
	}
	| declarator declarationList compoundStatement
  	| declarator compoundStatement
	;

%%

#include <stdio.h>

/*Funcion de error*/
int yyerror(char *s) {
	error=1;
	printf("Error en la linea %d cerca de  \"%s\": (%s)\n", line_number, yylval.name, s);
}


/*Agrega indentacion al archivo de salida*/
void add_indent(){
    int temp_ind = ind;
    while (temp_ind > 0){
        fprintf(yyout, "\t");
        temp_ind -= 1;
    }
}

void print(char *token) {
    fprintf(yyout,"%s", token);
}

/*Crea un nuevo símbolo con la información proporcionada y lo agrega a la tabla de símbolos*/
symrec * putsym(char *sym_name, int sym_type, int b_function) {
	symrec *ptr;
	ptr = (symrec *) malloc(sizeof(symrec));
	ptr->name = (char *) malloc(strlen(sym_name) + 1);
	strcpy(ptr->name, sym_name);
	ptr->type = sym_type;
	ptr->value = 0;
	ptr->function = b_function;
	ptr->data_type = current_type;
	ptr->is_const = modifier;
	ptr->next =(struct symrec *) sym_table;
	sym_table = ptr;
	return ptr;
	
}

/*Busca un símbolo en la tabla de símbolos comparando el nombre del símbolo con el nombre buscado y 
devuelve un puntero al símbolo encontrado, o 0 si el símbolo no se encuentra en la tabla.*/
symrec * getsym(char *sym_name) {
	symrec *ptr;
	for(ptr = sym_table; ptr != (symrec*)0; ptr = (symrec *)ptr->next){
		if(strcmp(ptr->name, sym_name) == 0){
            return ptr;
        }
    }
	return 0;
}

/*Devuelve una cadena de caracteres que representa a un tipo de dato dado*/
char* get_type(int type) {
	switch(type) {
		case T_INT:
			return "int";
		case T_CHAR:
			return "char";
		case T_FLOAT:
			return "float";
		case T_DOUBLE:
			return "double";
		default:
			return NULL;
	}
}

/*Busca el símbolo correspondiente a una variable en la tabla de símbolos y verifica si es una constante*/
int is_var_constant(char *name) {
	symrec *ptr = getsym(name);
	if(ptr->is_const){
		char msg[200];
		sprintf(msg, "No se puede modificar el valor de la variable. La variable %s se declaró como constante", name);
		yyerror(msg);
		return TRUE;
	}
	return FALSE;
}

/*Verifica el tipo de datos de dos operandos en una operación aritmética y muestra mensajes de error si se 
encuentran tipos no permitidos o incompatibles*/
int is_valid_operation(char *name1, char *name2, char op) {
	symrec* sym1 = getsym(name1);
	symrec* sym2 = getsym(name2);
	if(sym1 == NULL || sym2 == NULL){
        return FALSE;
    }
		
	int name1_type = sym1->data_type;
	int name2_type = sym2->data_type;

	int ban = FALSE;
	if(op == '+' || op == '-' || op == '*' || op == '/' || op == '%') {
		//Si no es ninguno de los tipos de datos permitidos
		if(name1_type != T_INT && name1_type != T_FLOAT && name1_type != T_DOUBLE) {
			char msg[250];
			ban = TRUE;
			sprintf(msg,"El operando %s en la operación %c tiene un tipo ilegal (%d)\n", name1, op, name1_type);
			yyerror(msg);
		}
		//Si no es ninguno de los tipos de datos permitidos
		if(name2_type != T_INT && name2_type != T_FLOAT && name2_type != T_DOUBLE) {
			char msg[250];
			ban = TRUE;
			sprintf(msg, "El operando %s en la operación %c tiene un tipo ilegal (%d)\n", name1, op, name2_type);
			yyerror(msg);
		}
		
		if (name1_type != name2_type) {
			char msg[250];
			ban = TRUE;
			char *str1_type = get_type(name1_type);
			char *str2_type = get_type(name2_type);
			sprintf(msg, "Operador %c realiza una operación con los tipos (%s)%s y (%s)%s sin conversión",op,str1_type,name1,str2_type,name2);
			yyerror(msg);
		}
	}
	
	return ban;
}

/*Programa principal*/
int main(int argc,char **argv){
    // Verificar que se hayan proporcionado los nombres de los archivos de entrada y salida
    if (argc < 3) {
        printf("Faltan parámetros\n Ejemplo de uso: %s code.c code.py\n", argv[0]);
        return -1;
    }

    // Abrir archivos de entrada y salida
    if (((yyin = fopen(argv[1], "rt")) == NULL) || ((yyout = fopen(argv[2], "w")) == NULL)) {
        printf("No se pudo abrir el archivo.\n");
        return -2;
    }

    // Llamar al analizador sintáctico
    yyparse(); 

    //Cerrar archivos de entrada y salida agregando 'main' al final
    print("if __name__ == '__main__':\n");
    print("\tmain()\n");
    fclose(yyin);
    fclose(yyout);

    //Mensaje de traducción finalizada
	if(error){
        printf("ERROR EN LA TRADUCCION: %s\n", argv[1]);
    }else{
        printf("TRADUCCION EXITOSA d %s\nArchivo traducido: %s\n", argv[1], argv[2]);
    }

	return 0;
}