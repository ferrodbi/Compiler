/* Subseccion preambulo C */
%{
#include <stdio.h>
#include "header.h"
#include "asin.h"

#define devolver(x) {if(verbosidad) ECHO; return x;}
%}

/* Subseccion de definiciones TERMINALES */
%option yylineno
/* Nombre variables */
id              {letra}({letra}|{digito})*
letra           {letraMay}|{letraMin}|"_"
letraMay        [A-Z]
letraMin        [a-z]
/* Numeros */
digito          [0-9]
cte             {digito}+
ctr             ({digito}*"."{digito}+)|({digito}+"."{digito}*)
/* Otros */
comentario      "//"[^\n]*"\n"
delimitador     [ \t]+
nuevalinea      \n


%%
{comentario}    {if(verbosidad) fprintf(stdout, "\n%3d.- ", yylineno);}
{delimitador}   {if(verbosidad) ECHO;}
{nuevalinea}    {if(verbosidad) {ECHO; fprintf("%3d.- ", yylineno);}}

"if"            {procesar(IF_);}
"else"          {procesar(ELSE_);}
"for"           {procesar(FOR_);}
"read"          {procesar(READ_);}
"print"         {procesar(PRINT_);}
"true"          {procesar(TRUE_);}
"false"         {procesar(FALSE_);}

"int"           {procesar(INT_);}
"bool"          {procesar(BOOL_);}
"struct"        {procesar(STRUCT_);}
"."             {procesar(PUNTO_);}
";"             {procesar(PCOMA_);}

"+"             {procesar(MAS_);}
"-"             {procesar(MENOS_);}

"*"             {procesar(PROD_);}
"/"             {procesar(DIV_);}

"++"            {procesar(MASMAS_);}
"--"            {procesar(MENOSMENOS_);}
"!"             {procesar(EXCL_);}

"&&"            {procesar(ANDAND_);}
"||"            {procesar(OROR_);}

"="             {procesar(IGU_);}
"=="            {procesar(IGUIGU_);}
"!="            {procesar(NOTIGU_);}

">"             {procesar(MAY_);} 
"<"             {procesar(MENOR_);}
">="            {procesar(MAYIGU_);}
"<="            {procesar(MENIGU_);}

"{"             {procesar(ALLA_);}
"("             {procesar(APAR_);}
"["             {procesar(ACOR_);}
"}"             {procesar(CLLA_);}
")"             {procesar(CPAR_);}
"]"             {procesar(CCOR_);}

{id}            {yylval.ident = strdup(yytext); procesar(ID_);}
{cte}           {yylval.cent = atoi(yytext); procesar(CTE_);}
{ctr}           {yylval.cent = atoi(yytext); procesar(CTE_);}

.               {yyerror("Caracter desconocido"); ECHO;}
%%
