%{
#include <stdio.h>
#include <libtds.h>
#include "header.h"
%}
%token ID_ CTE_  
%token MAS_ MENOS_ MASMAS_ MENOSMENOS_ PROD_ DIV_ 
%token MAY_ MENOR_ MAYIGU_ MENIGU_ IGU_ IGUIGU_ NOTIGU_ EXCL_ 
%token ANDAND_ OROR_
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
			{if(!insertarTDS($2,$1,dvar,-1){
				yyerror("Identificador repetido");
				}
			}
			| tipoSimple ID_ ACOR_ CTE_ CCOR_  PCOMA_
			{ int numelem=$4; int refe;
				if($4 <=0) {
					yyerror("Talla inapropiada del array");
					numelem=0;
				}
				refe = insertaTDArray($1,numelem);
				if(!insertarTDS($2,T_ARRAY,dvar,refe))
					yyerror("Identificador repetido");
				else dvar += numelem * TALLA_TIPO_SIMPLE; /////////VERY IMPORTANT
			}
			| STRUCT_ ALLA_ listaCampos CLLA_  ID_ PCOMA_
			{
			
			}
			;
tipoSimple: INT_
			{$$ = T_ENTERO;}
			| BOOL_
			{$$ = T_LOGICO;}
			;
listaCampos: tipoSimple ID_ PCOMA_
			{ insertarCampo($$,$2,$1,dvar);
			}
			| listaCampos tipoSimple ID_ PCOMA_
			{ insertarCampo($$,$3,$2,dvar);
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
						{SIMB sim = obtenerTDS($1);
						if (sim.tipo == T_ERROR) yyerror("Objeto no declarado");
						else if(! ((sim.tipo == $3.tipo == T_ENTERO) ||
					   				(sim.tipo == $3.tipo == T_LOGICO)))
						yyerror("Error de tipos en la instrucion de asginacion");
			}
			| ID_ ACOR_ expresion CCOR_ IGU_ expresion PCOMA_
			{

			}
			| ID_ PUNTO_ ID_ IGU_ expresion PCOMA_
			{

			}
			;
instruccionEntradaSalida: READ_ APAR_ ID_ CPAR_ PCOMA_
			| PRINT_ APAR_ expresion CPAR_ PCOMA_
			;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ instruccion ELSE_ instruccion
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