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

// Declaracion de funciones para eliminar warnings
int yylex();
void yyerror();
int yyparse();
void mostrarTDS();

#endif  /* _HEADER_H */
/*****************************************************************************/
