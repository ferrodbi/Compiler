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
/********************************************* Identificadores de operadores */
#define OPANDAND 0
#define OPOROR   1
#define OPIGIG   2
#define OPNOTIG  3
#define OPMAYOR  4
#define OPMENOR  5
#define OPMAYIG  6
#define OPMENIG  7
#define OPSUMA   8
#define OPRESTA  9
#define OPMULT   10
#define OPDIV    11
#define OPPOS    12
#define OPNEG    13
#define OPNOT    14
#define OPMASMAS 15
#define OPMENMEN 16
#define OPSUMIGU 17
#define OPRESIGU 18
#define OPIGU    19
#define OPMOD    20
/******************************** Constantes para el tipo de instrucciones 3D*/
#define ARG_ENTERO 0
#define ARG_POSICION 1
#define ARG_ETIQUIETA 2
#define ARG_NULO 3

typedef struct c {
  int refe;
  int talla;
} structCampos;

typedef struct d {
  int tipo;
  int pos;
} structExpresion;

typedef struct e {
  int ini;
  int fin;
  int lv;
  int lf;
  int aux;
} struct3D;

// Declaracion de funciones para eliminar warnings
int yylex();
void yyerror();
int yyparse();
void mostrarTDS();
void volcarCodigo();

/************************** Variables externas definidas en las librerias ***/
extern int si;
 /* Desplazamiento relativo en el Segmento de Codigo */
#endif  /* _HEADER_H */
/*****************************************************************************/
