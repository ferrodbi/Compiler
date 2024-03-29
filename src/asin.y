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
      {
        emite(FIN, crArgNul(), crArgNul(), crArgNul());
      }
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
        else
          $$.talla = $1.talla + TALLA_TIPO_SIMPLE;
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

        emite(EASIG, crArgPos($3.pos * TALLA_TIPO_SIMPLE), crArgNul(), crArgPos($3.pos));
        //emite(EASIG, crArgPos($3.pos), crArgNul(), crArgEnt($3.pos * TALLA_TIPO_SIMPLE));
        emite(EVA, crArgPos(sim.desp), crArgPos($3.pos), crArgPos($6.pos));

        // MILLAN
        //$$.pos = creaVarTemp();
        //emite(EASIG, crArgPos($6.pos), crArgNul(), crArgPos($$.pos));
        //emite(EVA, crArgPos(sim.desp), crArgPos($3.pos), crArgPos($$.pos));
      }
      | ID_ PUNTO_ ID_ IGU_ expresion PCOMA_
      {
        SIMB sim = obtenerTDS($1);
        REG reg;
        if(sim.tipo == T_ERROR) yyerror("Objeto no declarado");
        else {
          reg = obtenerInfoCampo(sim.ref, $3);
          if(reg.tipo == T_ERROR) yyerror("Campo no encontrado");
          else if(reg.tipo != $5.tipo) yyerror("Error de tipos en la asginacion");
        }

        $<exp>$.pos = sim.desp + reg.desp;
        emite(EASIG, crArgPos($5.pos), crArgNul(), crArgPos($<exp>$.pos));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
instruccionEntradaSalida: READ_ APAR_ ID_ CPAR_ PCOMA_
      {
        SIMB simb = obtenerTDS($3);
        if(simb.tipo == T_ERROR) yyerror("Objeto no declarado");
        else if(simb.tipo != T_ENTERO) yyerror("Argumento de read debe ser entero");
        
        emite(EREAD, crArgNul(), crArgNul(), crArgPos(simb.desp));
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
        $<exp>$.lf = creaLans(si);
        emite(EIGUAL, crArgPos($3.pos), crArgEnt(0), crArgEtq($<exp>$.lf));

        // MILLAN
        //$<cte>$ = creaLans(si);
        //emite(EIGUAL, crArgPos($3.pos), crArgEnt(0), crArgNul());
      }
      instruccion
      {
        $<exp>$.fin = creaLans(si);
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<exp>$.fin));
        completaLans($<exp>5.lf, crArgEtq(si));

        // MILLAN
        //$<cte>$ = creaLans(si);
        //emite(GOTOS, crArgNul(), crArgNul(), crArgNul());
        //completaLans($<cte>5, crArgEtq(si));
      }
      ELSE_ instruccion
      {
        completaLans($<exp>7.fin, crArgEtq(si));

        // MILLAN
        //completaLans($<cte>7, crArgEtq(si));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
instruccionIteracion: FOR_ APAR_ expresionOpcional PCOMA_ 
      {
        $<exp>$.ini = si;
      }
      expresion PCOMA_ 
      {
        if($6.tipo != T_LOGICO) yyerror("Condicion del for debe ser logica");
        $<exp>$.lv = creaLans(si);
        emite(EIGUAL, crArgPos($6.pos), crArgEnt(1), crArgEtq($<exp>$.lv));
        $<exp>$.lf = creaLans(si);
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<exp>$.lf));
        $<exp>$.aux = si;
      }
      expresionOpcional CPAR_
      {
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<exp>5.ini));
        completaLans($<exp>8.lv, crArgEtq(si));
      }
      instruccion
      {
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<exp>8.aux));
        completaLans($<exp>8.lf, crArgEtq(si));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresionOpcional: expresion
      {
        $$.tipo = $1.tipo;
        if($1.tipo == T_ENTERO)
          $$.valor = $1.valor;
      }
      | ID_ IGU_ expresion
      {
        SIMB simb;
        $$.tipo = $3.tipo;
        if($3.tipo == T_ENTERO) {
          //$$.valor = $3.valor;
          simb = obtenerTDS($1);
        }

        // ERROR?????? LA INSTRUCCION DE ABAJO SOLO ES LA QUE ESTABA EN EL ULTIMO COMMIT
        //emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos(simb.desp));
        //emite(EASIG, crArgPos(simb.desp), crArgNul(), crArgPos($3.pos));  // ESTA CREO QUE NO ES. ESTABA COMENTADA EN EL ULTIMO COMMIT
        // CREO QUE ES LA DE ABAJO, PORQUE LAS EXPRESIONES SIEMPRE PASAN SU RESULTADO A LA EXPRESION DE LA IZQUIERDA.
        // DE TODAS MANERAS, UNA SOLUCION ES LA DE MILLAN, HACER LAS DOS Y YA ESTA
        //emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));

        // MILLAN
        $$.pos = creaVarTemp();
        emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));
        emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos(simb.desp));
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

        $$.pos = creaVarTemp();
        if($2 == OPANDAND) {
           emite(EMULT, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));

           //emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
           //emite(EIGUAL, crArgPos($1.pos), crArgEnt(0), crArgEtq(si+3));
           //emite(EIGUAL, crArgPos($3.pos), crArgEnt(0), crArgEtq(si+2));
           //emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
        }
        else {
          emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
          emite(EIGUAL, crArgPos($1.pos), crArgEnt(1), crArgEtq(si+3));
          emite(EIGUAL, crArgPos($3.pos), crArgEnt(1), crArgEtq(si+2));
          emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));

          // ALTERNATIVA NO PROBADA. MEJOR NO PROBARLA, PERO AHI QUEDA
          //emite(ESUM, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
          //emite(EMENEQ, crArgPos($$.pos), crArgEnt(1), crArgEtq(si+2));
          //emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
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

        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
        if($2 == OPIGIG)
          emite(EIGUAL, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
        else
          emite(EDIST, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
        emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresionRelacional: expresionAditiva
      {
        // DIFERENTE A LAS DEMAS, PERO ES UNA ALTERNATIVA CORRECTA (ES DEL PROPIO PROFESOR Y ESTA DE EJEMPLO)
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
        emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
        if($2 == OPMAYOR)
          emite(EMAY, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
        else if($2 == OPMENOR)
          emite(EMEN, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
        else if($2 == OPMAYIG)
          emite(EMAYEQ, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
        else
          emite(EMENEQ, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
        emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
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

        $$.pos = creaVarTemp();
        if($2 == OPSUMA)
          emite(ESUM, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
        else
          emite(EDIF, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
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

        $$.pos = creaVarTemp();
        if($2 == OPMULT)
          emite(EMULT, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
        else
          emite(EDIVI, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
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

        $$.pos = creaVarTemp();
        if($1 == OPPOS)
          emite(EASIG, crArgPos($2.pos), crArgNul(), crArgPos($$.pos));
        else if($1 == OPNEG)
          emite(EDIF, crArgEnt(0), crArgPos($2.pos), crArgPos($$.pos));
        else { //operador !
          emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
          emite(EIGUAL, crArgPos($2.pos), crArgEnt(1), crArgEtq(si+2));
          emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));

          // MILLAN
          //emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
          //emite(EIGUAL, crArgPos($2.pos), crArgEnt(0), crArgEtq(si+2));
          //emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
        }
      }
      | operadorIncremento ID_
      {
        SIMB sim = obtenerTDS($2);
        if(sim.tipo == T_LOGICO)
          yyerror("Tipo incorrecto en expresion unaria");
        $$.tipo = T_ENTERO;

        $$.pos = creaVarTemp();
        if($1 == OPMASMAS)
          emite(ESUM, crArgPos(sim.desp), crArgEnt(1), crArgPos($$.pos));
        else
          emite(EDIF, crArgPos(sim.desp), crArgEnt(1), crArgPos($$.pos));
        emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos(sim.desp));
      }
      ;
/*****************************************************************************/



/*****************************************************************************/
expresionSufija: ID_
      {
        SIMB sim = obtenerTDS($1);
        $$.tipo = sim.tipo;

        $$.pos = creaVarTemp();
        emite(EASIG, crArgPos(sim.desp), crArgNul(), crArgPos($$.pos));
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
          else
            $$.tipo = dim.telem;

        // MAL, MAL, MAL, MUY MAL!!!!!!!!!!! ESTO ESTABA EN EL ULTIMO COMMIT
        //emite(EASIG, crArgPos($3.pos), crArgNul(), crArgEnt($3.pos * TALLA_TIPO_SIMPLE));
        //$$.pos = creaVarTemp();
        //emite(EVA, crArgPos($$.pos), crArgPos(sim.desp), crArgPos($3.pos));

        // COMO CREO QUE DEBERIA ESTAR
        emite(EASIG, crArgPos($3.pos * TALLA_TIPO_SIMPLE), crArgNul(), crArgEnt($3.pos));
        $$.pos = creaVarTemp();
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

        int aux_pos = sim.desp + reg.desp;
        $$.pos = creaVarTemp();
        emite(EASIG, crArgPos(aux_pos), crArgNul(), crArgPos($$.pos));
      }
      | APAR_ expresion CPAR_
      {
        $$.tipo = $2.tipo;
        $$.pos = $2.pos;
      }
      | ID_ operadorIncremento
      {
        SIMB sim = obtenerTDS($1);
        $$.tipo = (sim.tipo == T_ENTERO) ? T_ENTERO : T_ERROR;

        $$.pos = creaVarTemp();
        emite(EASIG, crArgPos(sim.desp), crArgNul(), crArgPos($$.pos));
        if($2 == OPMASMAS)
          emite(ESUM, crArgPos(sim.desp), crArgEnt(1), crArgPos(sim.desp));
        else
          emite(EDIF, crArgPos(sim.desp), crArgEnt(1), crArgPos(sim.desp));
      }
      | CTE_
      {
        $$.tipo = T_ENTERO;
        //$$.valor = $1;

        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(yylval.cent), crArgNul(), crArgPos($$.pos));
      }
      | TRUE_
      {
        $$.tipo = T_LOGICO;

        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
      }
      | FALSE_
      {
        $$.tipo = T_LOGICO;

        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
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
        $$ = OPPOS; //+
      }
      | MENOS_
      {
        $$ = OPNEG; //-
      }
      | EXCL_
      {
        $$ = OPNOT; //!
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
