/*****************************************************************************/
/**   Ejemplo de un posible fichero de cabeceras ("header.h") donde situar  **/
/** las definiciones de constantes, variables y estructuras para MenosC.17  **/
/** Los alumnos deberan adaptarlo al desarrollo de su propio compilador.    **/ 
/*****************************************************************************/
#ifndef _HEADER_H
#define _HEADER_H
/****************************************************** Constantes generales */
#define TRUE  1
#define FALSE 0
/************************************* Variables externas definidas en el AL */
extern FILE *yyin;
extern int   yylineno;
extern char *yytext;
/********************* Variables externas definidas en el Programa Principal */
extern int verbosidad;              /* Flag para saber si se desea una traza */
extern int numErrores;              /* Contador del numero de errores        */
/*************************************************** Constantes tallas tipos */
#define TALLA_TIPO_SIMPLE 1

typedef struct c {
	int refe;
	int talla;
} structCampos;

typedef struct d {
	int tipo;
	int valor;
} structExpresion;

typedef struct e {
	int tipo;
} structTipoUnario;

// Identificadores de operadores
#define OPIGUAL  0
#define OPANDAND 1
#define OPOROR   2
#define OPIGIG   3
#define OPNOTIG  4
#define OPMAYOR  5
#define OPMENOR  6
#define OPMAYIG  7
#define OPMENIG  8
#define OPSUMA   9
#define OPRESTA  10
#define OPMULT   11
#define OPDIV    12
#define OPPOS    13
#define OPNOT    14
#define OPMASMAS 15
#define OPMENMEN 16

// Declaracion de funciones para eliminar warnings
int yylex();
void yyerror();
int yyparse();
void mostrarTDS();

#endif  /* _HEADER_H */
/*****************************************************************************/
