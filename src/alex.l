/* Subseccion preambulo C */
%{
#include <stdio.h>
#include "header.h"
#include "asin.h"
%}

/* Subseccion de definiciones TERMINALES_*/
%option yylineno 
delimitador [ \t]+
letra [a-zA-Z]
digito [0-9]
comentario "//"[^\n]*"\n"
%%
{delimitador}     			{ECHO;}
"\n"                        {ECHO;}
{comentario}				{ECHO;}
if                          {ECHO;return (IF_);}
else						{ECHO;return (ELSE_);}
for                         {ECHO;return (FOR_);}
read 						{ECHO;return (READ_);}
print                 		{ECHO;return (PRINT_);}
true						{ECHO;return (TRUE_);}
false						{ECHO;return (FALSE_);}

"int"						{ECHO;return (INT_);}
"bool"						{ECHO;return (BOOL_);}
"struct"					{ECHO;return (STRUCT_);}
"."							{ECHO;return (PUNTO_);}
";"							{ECHO;return (PCOMA_);}

"+"                         {ECHO;return (MAS_);}
"-"                         {ECHO;return (MENOS_);}

"*"                         {ECHO;return (PROD_);}
"/"                         {ECHO;return (DIV_);}

"++"                        {ECHO;return (MASMAS_);}
"--"                        {ECHO;return (MENOSMENOS_);}
"!"                         {ECHO;return (EXCL_);}

"&&"                        {ECHO;return (ANDAND_);}
"||"                        {ECHO;return (OROR_);}

"="							{ECHO;return (IGU_);}
"=="                        {ECHO;return (IGUIGU_);}
"!="                        {ECHO;return (NOTIGU_);}

">"                         {ECHO;return (MAY_);} 
"<"                         {ECHO;return (MENOR_);}
">="                        {ECHO;return (MAYIGU_);}
"<="                        {ECHO;return (MENIGU_);}

"{"							{ECHO;return (ALLA_);}
"("							{ECHO;return (APAR_);}
"["							{ECHO;return (ACOR_);}
"}"							{ECHO;return (CLLA_);}
")"							{ECHO;return (CPAR_);}
"]"							{ECHO;return (CCOR_);}
{digito}+                  	{ECHO;yylval.cent = atoi(yytext); return (CTE_);}
{letra}({letra}|{digito})*  {ECHO;yylval.ident = strdup(yytext); return (ID_);}
.                           {ECHO;}
%%
