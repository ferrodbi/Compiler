%{
#include <stdio.h>
#include "header.h"
#include "libtds.h"
%}
%union{
	int cent;
	int tsimple;
	//int tipouna;
	char *ident;
	structCampos campos;
	structExpresion exp;
	//structTipoUnario una;
}
%token MASMAS_ MENOSMENOS_ PROD_ DIV_ 
%token MAY_ MENOR_ MAYIGU_ MENIGU_ IGU_ IGUIGU_ NOTIGU_  MAS_ MENOS_ EXCL_
%token ANDAND_ OROR_
%token ALLA_ CLLA_ APAR_ CPAR_ ACOR_ CCOR_
%token PCOMA_ PUNTO_
%token TRUE_ FALSE_
%token BOOL_ INT_ STRUCT_
%token FOR_ IF_ ELSE_
%token READ_ PRINT_

%token<cent> CTE_
%token<ident> ID_
//%token<una> MAS_ MENOS_ EXCL_
%type<cent> operadorIncremento
%type<campos> listaCampos
%type<tsimple> tipoSimple
%type<exp> expresion expresionIgualdad expresionRelacional expresionAditiva expresionMultiplicativa expresionUnaria expresionSufija
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
			{
				if(insertarTDS($2,$1,dvar,-1)){
					dvar += TALLA_TIPO_SIMPLE;
				} else {
					yyerror("Identificador repetido");
				}
			}
			| tipoSimple ID_ ACOR_ CTE_ CCOR_  PCOMA_
			{	
				int refe;
				if($4 < 1) {
					yyerror("Talla inapropiada del array");
					insertarTDS($2,T_ERROR,0,-1);
				} else {
					refe = insertaTDArray($1,$4);
					if( insertarTDS($2,T_ARRAY,dvar,refe) ){
						dvar += $4 * TALLA_TIPO_SIMPLE; 
					} else {
						yyerror("Identificador repetido");
					}
				}
			}
			| STRUCT_ ALLA_ listaCampos CLLA_  ID_ PCOMA_
			{	int refe = insertarTDS($5,T_RECORD,dvar,$3.refe);
				//printf("\nInsertar struct devuelve: %d\n",refe); 
				if(!refe) 
					yyerror("Error en struct");
				else{
					dvar+=$3.talla;
				}
				
			}
			;
tipoSimple: INT_
			{
				$$ = T_ENTERO;
			}
			| BOOL_
			{
				$$ = T_LOGICO;
			}
			;
listaCampos: tipoSimple ID_ PCOMA_
			{
				$$.refe = insertaCampo(-1,$2,$1,0);
				//insertarTDS($2,$1,dvar,$$.refe);
				//insertarTDS(char *nom, int tipo, int desp, int ref) ;
				//printf("\n campo unico: %d\n",$$.refe);
				if($$.refe < 0){
					yyerror("Nombre de campo repetido en el registro");
				} else {
					$$.talla = TALLA_TIPO_SIMPLE;
					//dvar += TALLA_TIPO_SIMPLE;
				}

				//mostrarTDS();
			}
			| listaCampos tipoSimple ID_ PCOMA_
			{
				//printf("\n$$,$1: %d %d , %d %d\n",$$.refe,$$.talla,$1.refe,$1.talla);
				int ref = insertaCampo($1.refe,$3,$2,$1.talla); 
				//printf("\nOtros campos: %d\n",$$.refe);
				if(ref < 0){
					yyerror("Nombre repetido en el registro");
				}
				else  $$.talla = $1.talla + TALLA_TIPO_SIMPLE;
				//mostrarTDS();

			}
			;
instruccion: ALLA_ listaInstrucciones CLLA_
			| instruccionAsignacion
			| instruccionEntradaSalida
			| instruccionSeleccion
			| instruccionIteracion
			;
listaInstrucciones: 
			| listaInstrucciones instruccion
			;
instruccionAsignacion: ID_ IGU_ expresion PCOMA_
			{	SIMB sim = obtenerTDS($1);
				//printf("\n%d == %d\n",sim.tipo, $3.tipo);
				if (sim.tipo == T_ERROR) yyerror("Objeto no declarado");
				else if(! ((sim.tipo == $3.tipo == T_ENTERO) || (sim.tipo == $3.tipo == T_LOGICO)))
				//{
				//else if(sim.tipo != $3.tipo){
				//if($3.tipo == T_ERROR){
				//		printf("\nWarning, propagando un T_ERROR\n");
				//	}
				//	else 
				if($3.tipo != T_ERROR)
				yyerror("Error de tipos en la asignacion");
				//}
			}
			| ID_ ACOR_ expresion CCOR_ IGU_ expresion PCOMA_
			{	SIMB sim = obtenerTDS($1);
				if (sim.tipo != T_ARRAY) {
					yyerror("Identificador debe ser tipo array");
				} else {
					DIM dim = obtenerInfoArray(sim.ref);
					if(sim.tipo == T_ERROR) yyerror("Objeto no declarado");
					else if (sim.tipo != T_ARRAY) yyerror("Tipo incorrecto");
					else if ($3.tipo != T_ENTERO) yyerror("Indice no entero");
					else if (atoi($3) <  1) yyerror("Indice del array incorrecto");
					else if (atoi($3) >= dim.telem) yyerror("Out of bounds exception");
					else if (dim.telem == T_ERROR) yyerror("Array no declarado");
					else if (dim.telem != $6.tipo) yyerror("Tipo del array no coincide");
				}
			}
			| ID_ PUNTO_ ID_ IGU_ expresion PCOMA_
			{	SIMB sim = obtenerTDS($1);
				if (sim.tipo == T_ERROR) yyerror("Objeto no declarado");
				else {
					REG reg;
					//printf("\nSim.ref: %d\n",sim.ref);
					reg = obtenerInfoCampo(sim.ref,$3);
					//printf("\nReg.tipo: %d\n",reg.tipo);
					if (reg.tipo == T_ERROR) yyerror("Campo no encontrado");
					else if (reg.tipo != $5.tipo) yyerror("Tipo del campo no coincidente");
				}
			}
			;
instruccionEntradaSalida: READ_ APAR_ ID_ CPAR_ PCOMA_
			| PRINT_ APAR_ expresion CPAR_ PCOMA_
			;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ instruccion ELSE_ instruccion
			{ if($3.tipo != T_LOGICO) yyerror("Expresion no es tipo logico");

			}
			;
instruccionIteracion: FOR_ APAR_ expresionOpcional PCOMA_ expresion PCOMA_ expresionOpcional CPAR_ instruccion 
			;
expresionOpcional: expresion
			| ID_ IGU_ expresion
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
			{	
				$$.tipo = $1.tipo;
			}

			| operadorUnario expresionUnaria
			{	
				$$.tipo = $2.tipo;
			}
			| operadorIncremento ID_
			{
				SIMB sim = obtenerTDS($2);
				$$.tipo = sim.tipo;
			}
			;
expresionSufija: ID_
			{
				SIMB sim = obtenerTDS($1);
				$$.tipo = sim.tipo;
			}
			| ID_ ACOR_ expresion CCOR_
			{
				$$.tipo = T_ARRAY;
			}
			| ID_ PUNTO_ ID_
			{
				SIMB sim = obtenerTDS($1);
				if(sim.tipo == T_RECORD){
					REG reg = obtenerInfoCampo(sim.ref,$3);
					if (reg.tipo == T_ERROR)
						yyerror("Campo no declarado");
					//else 
					$$.tipo = reg.tipo;
				} else {
					$$.tipo = T_ERROR;
					yyerror("El identificador debe ser \"struct\"");
					}
				//$$.tipo = T_RECORD;
			}
			| APAR_ expresion CPAR_
			{
				$$.tipo = $2.tipo;
			}
			| ID_ operadorIncremento
			{
				$$.tipo = T_ENTERO;
			}
			| CTE_
			{
				$$.tipo = T_ENTERO;

			}
			| TRUE_
			{
				$$.tipo = T_LOGICO;
			}
			| FALSE_
			{
				$$.tipo = T_LOGICO;
			}
			;
operadorLogico: ANDAND_
			| OROR_
			;
operadorIgualdad: IGUIGU_
			| NOTIGU_
			;
operadorRelacional: MAY_ 
			| MENOR_
			| MAYIGU_
			| MENIGU_
			;
operadorAditivo: MAS_
			| MENOS_
			;
operadorMultiplicativo: PROD_
			| DIV_
			;
operadorUnario: MAS_
			| MENOS_
			| EXCL_
			;
operadorIncremento: MASMAS_

			| MENOSMENOS_
			;
%%