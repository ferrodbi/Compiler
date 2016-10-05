%{
#include <stdio.h>
extern int yylineno;
%}
%token ID_ CTE_ OPSUMA_ OPMULT_ 
%token ALLA_ CLLA_ APAR_ CPAR_ ACOR_ CCOR_
%token PCOMA_ PUNTO_ IGUAL_
%token TRUE_ FALSE_
%token BOOL_ INT_ STRUCT_
%token FOR_ IF_ ELSE_
%token READ_ PRINT_

%%

programa: ALLA_ secuenciaSentencias CLLA_
			;
secuenciaSentencias: sentencia
			| secuenciaSentencias sentencia
			;
sentencia: declaracion
			| instruccion
			;
declaracion: tipoSimple ID_ PCOMA_
			| tipoSimple ID_ ACOR_ CTE_ CCOR_
			| STRUCT_ ALLA_ listaCampos CLLA_ PCOMA_ ID_
			;
tipoSimple: INT_
			| BOOL_
			;
listaCampos: tipoSimple ID_ PCOMA_
			| listaCampos tipoSimple ID_ PCOMA_
			;
instruccion: ALLA_ listaInstrucciones CLLA_
			| instruccionAsignacion
			| instruccionEntradaSalID_a
			| instruccionSeleccion
			| instruccionIteracion
			;
listaInstrucciones: 
			| listaInstrucciones instruccion
			;
instruccionAsignacion: ID_ IGUAL_ expresion PCOMA_
			| ID_ ACOR_ expresion CCOR_ IGUAL_ expresion PCOMA_
			| ID_ PUNTO_ ID_ IGUAL_ expresion
			;
instruccionEntradaSalID_a: READ_ APAR_ ID_ CPAR_ PCOMA_
			| PRINT_ APAR_ ID_ CPAR_ PCOMA_
			;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ instruccion ELSE_ instruccion;
instruccionIteracion: FOR_ APAR_ expresionOpcional PCOMA_ expresion PCOMA_ expresionOpcional CPAR_ instruccion ;
expresionOpcional: expresionOpcional
			| ID_ IGUAL_ expresion
			|
			;
expresion: expresionIgualdad
			| expresion operadorLogico expresionIgualdad
			;
expresionIgualdad: expresionRelacional
			| expresionIgualdad operadorIgualdad expresionRelacional
			;
expresionRelacional: expresionAditiva
			| expresionRelacional operadorRelacional expresionAditiva
			;
expresionAditiva: expresionMultiplicativa
			| expresionAditiva operadorAditivo expresionMultiplicativa
			;
expresionMultiplicativa: expresionUnaria
			| expresionMultiplicativa operadorMultiplicativo expresionUnaria
			;
expresionUnaria: expresionSufija
			| operadorUnario expresionUnaria
			| operadorIncremento ID_
			;
expresionSufija: ID_
			| ID_ ACOR_ expresion CCOR_
			| ID_ PUNTO_ ID_
			| APAR_ expresion CPAR_
			| ID_ operadorIncremento
			| CTE_
			| TRUE_
			| FALSE_
			;
%%

/* Llamada por yyparse ante un error */
yyerror (char *s) {
	printf ("Linea %d: %s\n", yylineno, s);
}

/*
operadorLogico: &&
			| ||
			;
operadorIgualdad: ==
			| !=
			;
operadorRelacional: >
			| <
			| >=
			| <=
			;
operadorAditivo: + 
			| -
			;
operadorMultiplicativo: *
			| /
			;
operadorUnario: +
			| -
			|  !
			;
operadorIncremento: ++
			| --
			;
*/