%{
#include <stdio.h>
extern int yylineno;
%}
%token ID_ CTE_ OPMAS_ OPMULT_

%%

programa: { secuenciaSentencias };
secuenciaSentencias: sentencia
			| secuenciaSentencias sentencia;
sentencia: declaracion|instruccion;
declaracion: tipoSimple id PCOMA_
			| tipoSimple id ACOR_ cte CCOR_
			| struct ALLA_ listaCampos CLLA_ PCOMA_ id
			;
tipoSimple: int
			| bool
			;
listaCampos: tipoSimple id PCOMA_
			| listaCampos tipoSimple id PCOMA_
			;
instruccion: ALLA_ listaInstrucciones CLLA_
			| instruccionAsignacion
			| instruccionEntradaSalida
			| instruccionSeleccion
			| instruccionIteracion
			;
listaInstrucciones: 
			| listraInstrucciones instruccion
			;
instruccionAsignacion: id IGUAL_ expresion PCOMA_
			| id ACOR_ expresion CCOR_ IGUAL_ expresion PCOMA_
			| id PUNTO_ id IGUAL_ expresion
			;
instruccionEntradaSalida: read APAR_ id CPAR_ PCOMA_
			| print APAR_ id CPAR_ PCOMA_
			;
instruccionSeleccion: if APAR_ expresion CPAR_ instruccion else instruccion;
instruccionIteracion: for APAR_ expresionOpcional PCOMA_ expresion PCOMA_ expresionOpcional CPAR_ instruccion ;
expresionOpcional: expresionOpcional
			| id IGUAL_ expresion
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
			| operadorIncremento id
			;
expresionSufija:



expresion: expresion OPMAS_ termino | termino;
termino: termino OPMULT_ factor | factor;
factor: CTE_ | ID_;




%%

/* Llamada por yyparse ante un error */
yyerror (char *s) {
	printf ("Linea %d: %s\n", yylineno, s);
}