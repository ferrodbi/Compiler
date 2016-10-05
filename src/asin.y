%{
#include <stdio.h>
extern int yylineno;
%}
%token ID_ CTE_ OPSUMA_ OPMULT_ OPINC_ OPUNA_ OPLOG_ OPIGU_ OPREL_
%token ALLA_ CLLA_ APAR_ CPAR_ ACOR_ CCOR_
%token PCOMA_ PUNTO_
%token TRUE_ FALSE_
%token BOOL_ INT_ STRUCT_
%token FOR_ IF_ ELSE_
%token READ_ PRINT_
%error-verbose
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
			| instruccionEntradaSalid_a
			| instruccionSeleccion
			| instruccionIteracion
			;
listaInstrucciones: 
			| listaInstrucciones instruccion
			;
instruccionAsignacion: ID_ OPIGU_ expresion PCOMA_
			| ID_ ACOR_ expresion CCOR_ OPIGU_ expresion PCOMA_
			| ID_ PUNTO_ ID_ OPIGU_ expresion
			;
instruccionEntradaSalid_a: READ_ APAR_ ID_ CPAR_ PCOMA_
			| PRINT_ APAR_ ID_ CPAR_ PCOMA_
			;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ instruccion ELSE_ instruccion;
instruccionIteracion: FOR_ APAR_ expresionOpcional PCOMA_ expresion PCOMA_ expresionOpcional CPAR_ instruccion ;
expresionOpcional: expresion
			| ID_ OPIGU_ expresion
			|
			;
expresion: expresionIgualdad
			| expresion OPLOG_ expresionIgualdad
			;
expresionIgualdad: expresionRelacional
			| expresionIgualdad OPIGU_ expresionRelacional
			;
expresionRelacional: expresionAditiva
			| expresionRelacional OPREL_ expresionAditiva
			;
expresionAditiva: expresionMultiplicativa
			| expresionAditiva OPSUMA_ expresionMultiplicativa
			;
expresionMultiplicativa: expresionUnaria
			| expresionMultiplicativa OPMULT_ expresionUnaria
			;
expresionUnaria: expresionSufija
			| OPUNA_ expresionUnaria
			| OPINC_ ID_
			;
expresionSufija: ID_
			| ID_ ACOR_ expresion CCOR_
			| ID_ PUNTO_ ID_
			| APAR_ expresion CPAR_
			| ID_ OPINC_
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