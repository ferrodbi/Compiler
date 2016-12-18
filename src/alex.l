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
{nuevalinea}    {if(verbosidad) {ECHO; fprintf(stdout, "%3d.- ", yylineno);}}

"if"            {devolver(IF_);}
"else"          {devolver(ELSE_);}
"for"           {devolver(FOR_);}
"read"          {devolver(READ_);}
"print"         {devolver(PRINT_);}
"true"          {devolver(TRUE_);}
"false"         {devolver(FALSE_);}

"int"           {devolver(INT_);}
"bool"          {devolver(BOOL_);}
"struct"        {devolver(STRUCT_);}
"."             {devolver(PUNTO_);}
";"             {devolver(PCOMA_);}

"+"             {devolver(MAS_);}
"-"             {devolver(MENOS_);}

"*"             {devolver(PROD_);}
"/"             {devolver(DIV_);}

"++"            {devolver(MASMAS_);}
"--"            {devolver(MENOSMENOS_);}
"!"             {devolver(EXCL_);}

"&&"            {devolver(ANDAND_);}
"||"            {devolver(OROR_);}

"="             {devolver(IGU_);}
"=="            {devolver(IGUIGU_);}
"!="            {devolver(NOTIGU_);}

">"             {devolver(MAY_);} 
"<"             {devolver(MENOR_);}
">="            {devolver(MAYIGU_);}
"<="            {devolver(MENIGU_);}

"{"             {devolver(ALLA_);}
"("             {devolver(APAR_);}
"["             {devolver(ACOR_);}
"}"             {devolver(CLLA_);}
")"             {devolver(CPAR_);}
"]"             {devolver(CCOR_);}

{id}            {yylval.ident = strdup(yytext); devolver(ID_);}
{cte}           {yylval.cent = atoi(yytext); devolver(CTE_);}
{ctr}           {yylval.cent = atoi(yytext); devolver(CTE_);}

.               {yyerror("Caracter desconocido"); ECHO;}
%%
