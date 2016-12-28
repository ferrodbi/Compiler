PROGRESO : ID[ exp ] 
(terminado)

%{
#include <stdio.h>
#include "header.h"
#include "libtds.h"
#include "libgci.h"
%}


%union {
  int cent;
  int tsimple;
  char *ident;
  int opuna;
  //char opuna;
  structCampos campos;
  structExpresion exp;
}


%token MASMAS_ MENOSMENOS_ PROD_ DIV_
%token MAY_ MENOR_ MAYIGU_ MENIGU_ IGU_ IGUIGU_ NOTIGU_ MAS_ MENOS_ EXCL_
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
%type<opuna> operadorIncremento
%type<opuna> operadorLogico
%type<opuna> operadorIgualdad
%type<opuna> operadorRelacional
%type<opuna> operadorAditivo
%type<opuna> operadorMultiplicativo
%type<campos> listaCampos
%type<tsimple> tipoSimple
%type<exp> expresionOpcional
%type<exp> expresion
%type<exp> expresionIgualdad
%type<exp> expresionRelacional
%type<exp> expresionAditiva
%type<exp> expresionMultiplicativa
%type<exp> expresionUnaria
%type<exp> expresionSufija



%%
/*****************************************************************************/
programa: ALLA_ secuenciaSentencias CLLA_
      ;
/*****************************************************************************/



/*****************************************************************************/
secuenciaSentencias: sentencia
      | secuenciaSentencias sentencia
      ;
/*****************************************************************************/



/*****************************************************************************/
sentencia: declaracion
      | instruccion
/*****************************************************************************/



/*****************************************************************************/
declaracion: tipoSimple ID_ PCOMA_
      {
        if(insertarTDS($2, $1, dvar, -1)) {
          dvar += TALLA_TIPO_SIMPLE;
        }
        else {
          yyerror("Identificador repetido");
        }
      }
      | tipoSimple ID_ ACOR_ CTE_ CCOR_  PCOMA_
      { 
        int refe;
        if($4 < 1) {
          yyerror("Talla inapropiada del array");
          insertarTDS($2, T_ERROR, 0, -1);
        }
        else {
          refe = insertaTDArray($1, $4);
          if(insertarTDS($2, T_ARRAY, dvar, refe)) {
            dvar += $4 * TALLA_TIPO_SIMPLE;
          }
          else {
            yyerror("Identificador repetido");
          }
        }
      }
      | STRUCT_ ALLA_ listaCampos CLLA_ ID_ PCOMA_
      {
        int refe = insertarTDS($5, T_RECORD, dvar, $3.refe);
        if(!refe)
          yyerror("Error en struct");
        else {
          dvar += $3.talla;
        }
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
tipoSimple: INT_
      {
        $$ = T_ENTERO;
      }
      | BOOL_
      {
        $$ = T_LOGICO;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
listaCampos: tipoSimple ID_ PCOMA_
      {
        $$.refe = insertaCampo(-1, $2, $1, 0);
        if($$.refe < 0) {
          yyerror("Nombre de campo repetido en el registro");
        }
        else {
          $$.talla = TALLA_TIPO_SIMPLE;
        }
      }
      | listaCampos tipoSimple ID_ PCOMA_
      { 
        int ref = insertaCampo($1.refe, $3, $2, $1.talla);
        if(ref < 0) {
          yyerror("Nombre repetido en el registro");
        }
        else  $$.talla = $1.talla + TALLA_TIPO_SIMPLE;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
instruccion: ALLA_ listaInstrucciones CLLA_
      | instruccionAsignacion
      | instruccionEntradaSalida
      | instruccionSeleccion
      | instruccionIteracion
      ;
/*****************************************************************************/



/*****************************************************************************/
listaInstrucciones: 
      | listaInstrucciones instruccion
      ;
/*****************************************************************************/



/*****************************************************************************/
instruccionAsignacion: ID_ IGU_ expresion PCOMA_
      {
        SIMB sim = obtenerTDS($1);
        if(sim.tipo == T_ERROR) yyerror("Objeto no declarado");
        else if(!((sim.tipo == $3.tipo == T_ENTERO) || (sim.tipo == $3.tipo == T_LOGICO)))
          if($3.tipo != T_ERROR)
            yyerror("Error de tipos en la asignacion");
        emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos(sim.desp));
      }
      | ID_ ACOR_ expresion CCOR_ IGU_ expresion PCOMA_
      {
        SIMB sim = obtenerTDS($1);
        if(sim.tipo != T_ARRAY) {
          yyerror("Identificador debe ser tipo array");
        }

        else {
          DIM dim = obtenerInfoArray(sim.ref);
          if(sim.tipo == T_ERROR) yyerror("Objeto no declarado");
          else if(sim.tipo != T_ARRAY) yyerror("Tipo incorrecto");
          else if($3.tipo != T_ENTERO) yyerror("Indice no entero");
          else if($3.valor < 0 || $3.valor >= dim.nelem) {
            //yyerror("Indice del array incorrecto");
          }
          if($6.tipo != T_ERROR) {
            if(dim.telem == T_ERROR) yyerror("Array no declarado");
            else if(dim.telem != $6.tipo) yyerror("Tipo del array no coincide");
          }
        }
      }
      | ID_ PUNTO_ ID_ IGU_ expresion PCOMA_
      {
        SIMB sim = obtenerTDS($1);
        REG reg;
        if(sim.tipo == T_ERROR) yyerror("Objeto no declarado");
        else {
          reg = obtenerInfoCampo(sim.ref,$3);
          if(reg.tipo == T_ERROR) yyerror("Campo no encontrado");
          else if(reg.tipo != $5.tipo) yyerror("Error de tipos en la asginacion");
        }
        int aux_pos = sim.desp + reg.desp;
        //emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos(aux_pos));
    
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
instruccionEntradaSalida: READ_ APAR_ ID_ CPAR_ PCOMA_
      {
        SIMB simb = obtenerTDS($3);
        if(simb.tipo == T_ERROR) yyerror("Objeto no declarado");
        else if(simb.tipo != T_ENTERO) yyerror("Argumento de read debe ser entero");
        
        emite(EREAD, crArgNul(), crArgNul(), crArgPos(sim.desp));
      }
      | PRINT_ APAR_ expresion CPAR_ PCOMA_
      {
        if($3.tipo != T_ENTERO) yyerror("Argumento de print debe ser entero");
        
        emite(EWRITE, crArgNul(), crArgNul(), crArgPos($3.pos));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
instruccionSeleccion: IF_ APAR_ expresion CPAR_
      {
        if($3.tipo != T_LOGICO && $3.tipo == T_VACIO) yyerror("Expresion no es tipo logico");
        
        $<cte>$ = creaLans(si);
        emite(EIGUAL, crArgPos($3.pos), crArgEnt(0), crArgNul());
      }
      instruccion
      {
        $<cte>$ = creaLans(si);
        emite(GOTOS, crArgNul(), crArgNul(), crArgNul());
        completaLans($<cte>5, crArgEtq(si));
      }
      ELSE_ instruccion
      {
        completaLans($<cte>7, crArgEtq(si));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
instruccionIteracion: FOR_ APAR_ expresionOpcional PCOMA_ expresion PCOMA_ expresionOpcional
      {
        if($5.tipo != T_LOGICO) yyerror("Condicion del for debe ser logica");
      } CPAR_ instruccion
      {

      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresionOpcional: expresion
      {
        $$.tipo = $1.tipo;
        if($1.tipo == T_ENTERO)
          $$.valor = $1.valor;
        
        $$.pos = creaVarTemp();
        emite(EASIG, crArgPos($1.pos), crArgNul(), crArgPos($$.pos));
      }
      | ID_ IGU_ expresion
      {
        $$.tipo = $3.tipo;
        if($3.tipo == T_ENTERO)
          $$.valor = $3.valor;
      }
      |
      {
        $$.tipo = T_VACIO;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresion: expresionIgualdad
      {
        $$.tipo = $1.tipo;
        if($1.tipo == T_ENTERO)
          $$.valor = $1.valor;
      }
      | expresion operadorLogico expresionIgualdad
      {
        if($1.tipo == T_ENTERO || $3.tipo == T_ENTERO) {
          $$.tipo == T_ERROR;
          yyerror("Error en expresion");
        } else if($1.tipo == T_LOGICO && $3.tipo == T_LOGICO)
          $$.tipo = T_LOGICO;
        else {
          if($1.tipo == T_ERROR || $3.tipo != T_ERROR) {
            $$.tipo = T_ERROR;
            //yyerror("Error en expresion");
          }
          //$$.tipo = T_ERROR;
        }
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresionIgualdad: expresionRelacional
      {
        $$.tipo = $1.tipo;
        if($1.tipo == T_ENTERO)
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
/*****************************************************************************/



/*****************************************************************************/
expresionRelacional: expresionAditiva
      {
        $$ = $1;
      }
      | expresionRelacional operadorRelacional expresionAditiva
      {
        if($1.tipo == T_LOGICO || $3.tipo == T_LOGICO) {
          yyerror("Error en expresion relacional. Argumentos no enteros.");
          $$.tipo = T_ERROR;
        } 
        else if($1.tipo == T_ERROR || $3.tipo == T_ERROR)
        {
          $$.tipo = T_ERROR;
        } 
        else $$.tipo = T_LOGICO;
        $$.pos = creaVarTemp();
        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresionAditiva: expresionMultiplicativa
      {
        $$.tipo = $1.tipo;
        if($1.tipo == T_ENTERO)
          $$.valor = $1.valor;
      }
      | expresionAditiva operadorAditivo expresionMultiplicativa
      {
        if(($1.tipo != T_ENTERO) || ($3.tipo != T_ENTERO))
        {
          if($1.tipo != T_ERROR && $3.tipo != T_ERROR) { 
            yyerror("Error en expresion aditiva. Argumentos no enteros.");
            $$.tipo = T_ERROR;
          }
        }
        else
          $$.tipo = T_ENTERO;
      }
      ;
/*****************************************************************************/


/*****************************************************************************/
expresionMultiplicativa: expresionUnaria
      {
        $$.tipo = $1.tipo;
        if($1.tipo == T_ENTERO)
          $$.valor = $1.valor;
      }
      | expresionMultiplicativa operadorMultiplicativo expresionUnaria
      {
        if(($1.tipo != T_ENTERO) || ($3.tipo != T_ENTERO))
        {
          yyerror("Error en expresion multiplicativa. Argumentos no enteros");
          $$.tipo = T_ERROR;
        }
        else
          $$.tipo = T_ENTERO;
      }
      ;
/*****************************************************************************/


/*****************************************************************************/
expresionUnaria: expresionSufija
      { 
        $$.tipo = $1.tipo;
        if($1.tipo == T_ENTERO)
          $$.valor = $1.valor;
      }
      | operadorUnario expresionUnaria
      { 
        if($1 == OPNOT && $2.tipo == T_LOGICO)
          $$.tipo = T_LOGICO;
        else if((($1 == OPSUMA) || ($1 == OPRESTA)) && $2.tipo == T_ENTERO)
          $$.tipo = T_ENTERO;
        else {
          yyerror("Error en expresion unaria");
          $$.tipo = T_ERROR;
        }
      }
      | operadorIncremento ID_
      {
        SIMB sim = obtenerTDS($2);
        if(sim.tipo == T_LOGICO) yyerror("Tipo incorrecto en expresion unaria");
        $$.tipo = T_ENTERO;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresionSufija: ID_
      {
        SIMB sim = obtenerTDS($1);
        $$.tipo = sim.tipo;
        $$.pos = creaVarTemp();
        emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos($$.pos));
      }
      | ID_ ACOR_ expresion CCOR_
      {
        SIMB sim = obtenerTDS($1);
        DIM dim;
        if(sim.tipo == T_ERROR) {
          yyerror("Objeto no declarado");
          $$.tipo = T_ERROR;
        }
        else if(sim.tipo != T_ARRAY) {
          yyerror("Tipo incorrecto");
          $$.tipo = T_ERROR;
        }
        if($3.tipo != T_ENTERO) {
          yyerror("Indice no entero");
          $$.tipo = T_ERROR;
        }
        else {
          dim = obtenerInfoArray(sim.ref);
          if($3.valor < 0 || $3.valor >= dim.nelem) {
            $$.tipo = T_ERROR;
            //yyerror("Indice del array incorrecto");
          }
          else if(dim.telem == T_ERROR) {
            yyerror("Array no declarado");
            $$.tipo = T_ERROR;
          }
          else $$.tipo = dim.telem;
          emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($3.pos * dim.nelem));
          $$.pos = creaVarTemp();
          //emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos($1.pos[$3.pos]));
          emite(EAV, crArgPos(sim.desp), crArgPos($3.pos), crArgPos($$.pos));
        }
      }
      | ID_ PUNTO_ ID_
      {
        SIMB sim = obtenerTDS($1);
        REG reg;
        if(sim.tipo == T_RECORD) {
          reg = obtenerInfoCampo(sim.ref, $3);
          if(reg.tipo == T_ERROR) {
            $$.tipo = T_ERROR;
            yyerror("Campo no declarado");
          }
          $$.tipo = reg.tipo;
        }
        else {
          $$.tipo = T_ERROR;
          yyerror("El identificador debe ser struct");
        }
        $$.pos = creaVarTemp();
        int aux_pos = sim.desp + reg.desp;
        emite(EASIG, crArgPos(aux_pos), crArgNul(), crArgPos($$.pos));
      }
      | APAR_ expresion CPAR_
      {
        $$ = $2;
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
        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt($1), crArgNul(), crArgPos($$.pos));
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
/*****************************************************************************/



/*****************************************************************************/
operadorLogico: ANDAND_
      {
        $$ = OPANDAND;
      }
      | OROR_
      {
        $$ = OPOROR;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
operadorIgualdad: IGUIGU_
      {
        $$ = OPIGIG;
      }
      | NOTIGU_
      {
        $$ = OPNOTIG;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
operadorRelacional: MAY_
      {
        $$ = OPMAYOR;
      }
      | MENOR_
      {
        $$ = OPMENOR;
      }
      | MAYIGU_
      {
        $$ = OPMAYIG;
      }
      | MENIGU_
      {
        $$ = OPMENIG;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
operadorAditivo: MAS_
      {
        $$ = OPSUMA;
      }
      | MENOS_
      {
        $$ = OPRESTA;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
operadorMultiplicativo: PROD_
      {
        $$ = OPMULT;
      }
      | DIV_
      {
        $$ = OPDIV;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
operadorUnario: MAS_
      {
        //$$ = '+';
        $$ = OPSUMA;
      }
      | MENOS_
      {
        //$$ = '-';
        $$ = OPRESTA;
      }
      | EXCL_
      {
        //$$ = '!';
        $$ = OPNOT;
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
operadorIncremento: MASMAS_
      {
        $$ = OPMASMAS;
      }
      | MENOSMENOS_
      {
        $$ = OPMENMEN;
      }
      ;
/*****************************************************************************/
%%
