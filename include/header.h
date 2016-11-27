/*****************************************************************************/
/**   Ejemplo de un posible fichero de cabeceras ("header.h") donde situar  **/
/** las definiciones de constantes, variables y estructuras para MenosC.17  **/
/** Los alumos deberan adaptarlo al desarrollo de su propio compilador.     **/ 
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
struct {
	int num_campo;
	int talla;
}campos;
#endif  /* _HEADER_H */
/*****************************************************************************/
