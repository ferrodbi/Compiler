%{
#include <stdio.h>
extern int yylineno;
%}
%token ID_ CTE_ OPMAS_ OPMULT_

%%

programa: { secuenciaSentencias };
secuenciaSentencias: sentencia|secuenciaSentencias sentencia;
sentencia: declaracion|instruccion;
declaracion: tipoSimple id PUNTOCOMA_
			| tipoSimple id [cte]


expresion: expresion OPMAS_ termino | termino;
termino: termino OPMULT_ factor | factor;
factor: CTE_ | ID_;




%%

/* Llamada por yyparse ante un error */
yyerror (char *s) {
	printf ("Linea %d: %s\n", yylineno, s);
}