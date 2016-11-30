%{
#include <stdio.h>
#include "header.h"
#include "libtds.h"
%}
%union{
	int cent;
	int tipouna;
	char *ident;
	structCampos campos;
	structExpresion exp;
}
%token MASMAS_ MENOSMENOS_ PROD_ DIV_ 
%token MAY_ MENOR_ MAYIGU_ MENIGU_ IGU_ IGUIGU_ NOTIGU_ EXCL_ 
%token ANDAND_ OROR_
%token ALLA_ CLLA_ APAR_ CPAR_ ACOR_ CCOR_
%token PCOMA_ PUNTO_
%token TRUE_ FALSE_
%token BOOL_ INT_ STRUCT_
%token FOR_ IF_ ELSE_
%token READ_ PRINT_
<<<<<<< HEAD

%token<cent> CTE_
%token<ident> ID_
%token<tipouna> MAS_ MENOS_ 
%type<campos> listaCampos
%type<cent> tipoSimple
%type<exp> expresion expresionIgualdad expresionRelacional expresionAditiva expresionMultiplicativa expresionUnaria expresionSufija
%type<tipouna> operadorUnario
=======
%error-verbose
%union{ //atributos
	char *ident;
	int cent;
}
%type <cent> name
%type <campos> listaCampos
%token <*ident> id
>>>>>>> ec0829ac464843dacac45ece0e6d83c74ab8dcf4
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
<<<<<<< HEAD
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
					insetarTDS($2,T_ERROR,0,-1)	
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
			{
				if(!insertarTDS($5,T_RECORD,dvar,$3.talla)) yyerror("..");
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
				if(!$$.refe){
					yyerror("Nombre de campo repetido en el registro");
				} else {
					$$.talla = TALLA_TIPO_SIMPLE;
				}
			}
			| listaCampos tipoSimple ID_ PCOMA_
			{
				$$.refe = insertaCampo($1.refe,$3,$2,$1.talla); 
				if(!$$.refe){
					yyerror("Nombre repetido en el registro");
				}
				else  $$.talla = $1.talla + TALLA_TIPO_SIMPLE;
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
				if (sim.tipo == T_ERROR) yyerror("Objeto no declarado");
				else if(! ((sim.tipo == $3.tipo == T_ENTERO) || (sim.tipo == $3.tipo == T_LOGICO)))
					yyerror("Error de tipos en la instrucion de asginacion");
			}
			| ID_ ACOR_ expresion CCOR_ IGU_ expresion PCOMA_
			{	SIMB sim = obtenerTDS($1);
				DIM di = obtenerInfoArray(sim.ref);
				if(sim.tipo == T_ERROR) yyerror("Objeto no declarado");
				else if (sim.tipo != T_ARRAY) yyerror("Tipo incorrecto");
				else if ($3.tipo != T_ENTERO) yyerror("Indice no entero");
				else if (atoi($3) <  1) yyerror("Indice del array incorrecto");
				else if (di.telem == T_ERROR) yyerror("Array no declarado");
				else if (di.telem != $6.tipo) yyerror("Tipo del array no coincide");
			}
			| ID_ PUNTO_ ID_ IGU_ expresion PCOMA_
			{	SIMB sim = obtenerTDS($1);
				REG re = obtenerInfoCampo(sim.ref,$3);
				if (sim.tipo == T_ERROR) yyerror("Objeto no declarado");
				else if (re.tipo == T_ERROR) yyerror("Campo no encontrado");
				else if (re.tipo == $5.tipo) yyerror("Tipo del campo no coincidente");
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