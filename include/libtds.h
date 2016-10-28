/*****************************************************************************/
/**  Definiciones de las constantes y estructuras auxiliares usadas en      **/
/**  la librería <<libtds>>, asi como el perfil de las funciones de         **/
/**  manipulación de la  TDS.                                               **/
/**                     Jose Miguel Benedi, 2016-2017 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
/*****************************************************************************/
#ifndef _LIBTDS_H
#define _LIBTDS_H

/************************* Constantes para los tipos en la Tabla de Simbolos */
#define T_VACIO       0
#define T_ENTERO      1
#define T_LOGICO      2
#define T_ARRAY       3
#define T_RECORD      4
#define T_ERROR       5
typedef struct simb /******************************** Estructura para la TDS */
{
  int   tipo;            /* Tipo del objeto                                  */
  int   desp;            /* Desplazamiento relativo en el segmento variables */
  int   ref;             /* Campo de referencia de usos multiples            */
} SIMB;
typedef struct dim  /* Estructura para la informacion obtenida de la TDArray */
{
  int   telem;                                      /* Tipo de los elementos */
  int   nelem;                                      /* Numero de elementos   */
} DIM;
typedef struct reg  /* Estructura para los campos de un registro             */
{
  int   tipo;                          /* Tipo del campo                     */
  int   desp;                          /* Desplazamiento relativo en memoria */
}REG;
/*************************** Variables globales de uso en todo el compilador */
int dvar;                     /* Desplazamiento en el Segmento de Variables  */

/************************************* Operaciones para la gestion de la TDS */
int insertarTDS(char *nom, int tipo, int desp, int ref) ;
/* Inserta en la TDS toda la informacion asociada con un simbolo de: nombre 
   "nom"; tipo "tipo"; desplazamiento relativo en el segmento de variables
   "desp" y referencia a posibles subtablas "ref" de vectores o  registros 
   (-1 si no referencia a  otras subtablas). Si el identificador ya existe 
   devuelve el valor "FALSE=0" ("TRUE=1" en caso contrario).                 */
int insertaTDArray (int telem, int nelem) ;
/* Inserta en la Tabla de Arrays la informacion de un array cuyos elementos 
   son de tipo "telem" y el numero de elementos es "nelem". Devuelve su 
   referencia en la Tabla de Arrays.                                         */
int insertaCampo (int refe, char *nom, int tipo, int desp) ;
/* Inserta en la Tabla de Registros, referenciada por "refe", la información 
   de un determinado campo: nombre de campo "nom", tipo de campo "tipo" y 
   desplazamiento del campo "desp". Si "ref = -1" entonces crea una nueva 
   entrada en la Tabla de Registros para este campo y devuelve su referencia.
   Comprueba además que el nombre del campo no este repetido en el registro, 
   devolviendo "-1" en caso de algun error.                                  */
SIMB obtenerTDS (char *nom) ;
/* Obtiene toda la informacion asociada con un objeto de nombre "nom" y la
   devuelve en una estructura de tipo "SIMB" (ver "libtds.h"). Si el objeto 
   no está declarado, en el campo "tipo" devuelve "T_ERROR".                 */
DIM obtenerInfoArray (int ref) ;
/* Devuelve toda la informacion asociada con un array referenciado por "ref" 
   en la Tabla de Arrays.                                                    */
REG obtenerInfoCampo (int ref, char *nom) ;
/* Obtiene toda la información asociada con un campo, de nombre "nom",
   referenciado por el índice "ref" de un registro en la Tabla de
   Registros. En caso de error devuelve "T_ERROR" en el campo "tipo".        */
void mostrarTDS () ;
/* Muestra toda la informacion de la TDS.                                    */

#endif  /* _LIBTDS_H */
/*****************************************************************************/
