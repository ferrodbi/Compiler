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
	char opuna;
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
%type<opuna> operadorUnario
//%type<cent> operadorIncremento
%type<campos> listaCampos
%type<tsimple> tipoSimple
%type<exp> expresionOpcional expresion expresionIgualdad expresionRelacional expresionAditiva expresionMultiplicativa expresionUnaria expresionSufija
//%token<una> MAS_ MENOS_ EXCL_
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
				
				/*
				if(expresion.tipo != T_ERROR)
					printf("\nWarning!! expresion es error\n");
				
					//$$.tipo = T_ERROR;
				else {
				*/
					if (sim.tipo != T_ARRAY) {
						yyerror("Identificador debe ser tipo array");
					} else {
						DIM dim = obtenerInfoArray(sim.ref);
						if(sim.tipo == T_ERROR) yyerror("Objeto no declarado");
						else if (sim.tipo != T_ARRAY) yyerror("Tipo incorrecto");
						else if ($3.tipo != T_ENTERO) yyerror("Indice no entero");
						else if ($3.valor <  0) yyerror("Indice del array incorrecto");
						else if ($3.valor >= dim.nelem) yyerror("Out of bounds exception");
						else if (dim.telem == T_ERROR) yyerror("Array no declarado");
						else if (dim.telem != $6.tipo) yyerror("Tipo del array no coincide");
					}
				//}
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
			{
				SIMB simb = obtenerTDS($3);
				if (simb.tipo == T_ERROR) yyerror("Objeto no declarado");
				else if (simb.tipo != T_ENTERO) yyerror("Argumento de read debe ser entero");

			}
			| PRINT_ APAR_ expresion CPAR_ PCOMA_
			{
				if ($3.tipo != T_ENTERO) yyerror("Argumento de print debe ser entero");
			}
			;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ instruccion ELSE_ instruccion
			{ 	//printf("\n%d\n",$3.tipo);
				if($3.tipo != T_LOGICO && $3.tipo == T_VACIO) yyerror("Expresion no es tipo logico");

			}
			;
instruccionIteracion: FOR_ APAR_ expresionOpcional PCOMA_ expresion PCOMA_ expresionOpcional 
			{
				if($5.tipo != T_LOGICO) yyerror("Condicion del for debe ser logica");
			}CPAR_ instruccion
			{

			}
			;
expresionOpcional: expresion
			{
				$$.tipo = $1.tipo;
				if ($1.tipo == T_ENTERO)
					$$.valor = $1.valor;
			}
			| ID_ IGU_ expresion
			{
				$$.tipo = $3.tipo;
				if ($3.tipo == T_ENTERO)
					$$.valor = $3.valor;

			}
			|
			{
				$$.tipo = T_VACIO;
			}
			;
expresion: expresionIgualdad
			{
				$$.tipo = $1.tipo;
				if ($1.tipo == T_ENTERO)
					$$.valor = $1.valor;
			}
			| expresion operadorLogico expresionIgualdad
			{
				if($1.tipo == T_LOGICO && $3.tipo == T_LOGICO)
					$$.tipo = T_LOGICO;
				else{
					yyerror("Error en expresion");
					$$.tipo = T_ERROR;
				}
			}
			;
expresionIgualdad: expresionRelacional
			{
				$$.tipo = $1.tipo;
				if ($1.tipo == T_ENTERO)
					$$.valor = $1.valor;
			}
			| expresionIgualdad operadorIgualdad expresionRelacional
			{
				if($1.tipo != $3.tipo) {
					yyerror("Error en expresion igualdad (tipos no equivalentes)");
				}
				$$.tipo = T_LOGICO;
			}
			;
expresionRelacional: expresionAditiva
			{
				$$.tipo = $1.tipo;
				if ($1.tipo == T_ENTERO)
					$$.valor = $1.valor;
			}
			| expresionRelacional operadorRelacional expresionAditiva
			{
				if ( ($1.tipo != T_ENTERO) || ($3.tipo != T_ENTERO) )
				{
					//printf("\n%d %d\n",$1.tipo, $3.tipo);
					yyerror("Error en expresion relacional. Argumentos no enteros.");
					$$.tipo = T_ERROR;
				} else $$.tipo = T_LOGICO;
			}
			;
expresionAditiva: expresionMultiplicativa
			{
				$$.tipo = $1.tipo;
				if ($1.tipo == T_ENTERO)
					$$.valor = $1.valor;
			}
			| expresionAditiva operadorAditivo expresionMultiplicativa
			{
				if ( ($1.tipo != T_ENTERO) || ($3.tipo != T_ENTERO) )
				{
					yyerror("Error en expresion aditiva. Argumentos no enteros.");
					$$.tipo = T_ERROR;
				} else $$.tipo = T_ENTERO;
			}
			;
expresionMultiplicativa: expresionUnaria
			{
				$$.tipo = $1.tipo;
				if ($1.tipo == T_ENTERO)
					$$.valor = $1.valor;
			}
			| expresionMultiplicativa operadorMultiplicativo expresionUnaria
			{
				if ( ($1.tipo != T_ENTERO) || ($3.tipo != T_ENTERO) )
				{
					yyerror("Error en expresion multiplicativa. Argumentos no enteros");
					$$.tipo = T_ERROR;
				} else $$.tipo = T_ENTERO;
			}
			;
expresionUnaria: expresionSufija
			{	
				$$.tipo = $1.tipo;
				if ($1.tipo == T_ENTERO)
					$$.valor = $1.valor;
			}

			| operadorUnario expresionUnaria
			{	
				if($1 == "!" && $2.tipo == T_LOGICO)
					$$.tipo = T_LOGICO;
				else if( ( ($1 == '+') || ($1 == '-') ) && $2.tipo == T_ENTERO)
					$$.tipo = T_ENTERO;
				else {
					yyerror("Error en expresion unaria");
					$$.tipo = T_ERROR;
				}
			}
			| operadorIncremento ID_
			{
				SIMB sim = obtenerTDS($2);
				if (sim.tipo == T_LOGICO) yyerror("Tipo incorrecto en expresion unaria");
				//$$.tipo = sim.tipo;
				$$.tipo = T_ENTERO;
			}
			;
expresionSufija: ID_
			{
				SIMB sim = obtenerTDS($1);
				$$.tipo = sim.tipo;
			}
			| ID_ ACOR_ expresion CCOR_
			{
				SIMB sim = obtenerTDS($1);
				DIM dim;
				//$$.tipo = T_ERROR;
				if (sim.tipo == T_ERROR) { yyerror("Objeto no declarado"); $$.tipo == T_ERROR;}
				else if (sim.tipo != T_ARRAY){ yyerror("Tipo incorrecto"); $$.tipo == T_ERROR;}
				if ($3.tipo != T_ENTERO) { yyerror("Indice no entero"); $$.tipo == T_ERROR;}
				else{
					if ($3.valor <  0) {yyerror("Indice del array incorrecto (negativo)"); $$.tipo == T_ERROR;}
					dim = obtenerInfoArray(sim.ref);
					if ($3.valor >= dim.nelem) {yyerror("Indice del array incorrecto (excesivo)"); $$.tipo == T_ERROR;}
					else if (dim.telem == T_ERROR) {yyerror("Array no declarado"); $$.tipo == T_ERROR;}
					else $$.tipo = dim.telem;
				}
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
					yyerror("El identificador debe ser struct");
					}
				//$$.tipo = T_RECORD;
			}
			| APAR_ expresion CPAR_
			{
				$$.tipo = $2.tipo;
			}
			| ID_ operadorIncremento
			{
				SIMB sim = obtenerTDS($1);
				$$.tipo = (sim.tipo == T_ENTERO) ? T_ENTERO : T_ERROR;

			}
			| CTE_
			{
				$$.tipo = T_ENTERO;
				$$.valor = $1;
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
			{
				$$ = '+';
			}
			| MENOS_
			{
				$$ = '-';
			}
			| EXCL_
			{
				$$ = '!';
			}
			;
operadorIncremento: MASMAS_

			| MENOSMENOS_
			;
%%