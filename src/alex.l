/* Subseccion preambulo C */
%{
#include <stdio.h>
#include "header.h"
	#include "asin.h"

void visualizar(int opcion, char* texto);
%}

/* Subseccion de definiciones */
%option yylineno
delimitador [ \t]+
letra [a-zA-Z]
digito [0-9]
comentario "//"[^\n]*"\n"
%%
{delimitador}     			{ECHO;}
"\n"                        {ECHO; }
{comentario}				{ECHO; }
if                          {ECHO;return (IF_);}
else						{ECHO;return(ELSE_);}
for                         {ECHO;return (FOR_);}
read 						{ECHO;return (READ_);}
print                 		{ECHO;return (PRINT_);}

"int"						{ECHO;return (INT_);}
"bool"						{ECHO;return (BOOL_);}
"struct"					{ECHO;return (STRUCT_);}
"."							{ECHO;return (PUNTO_);}
";"							{ECHO;return (PCOMA_);}

"+"                         {ECHO;return(OPSUMA_);}
"-"                         {ECHO;return (OPSUMA_);}

"*"                         {ECHO;return (OPMULT_);}
"/"                         {ECHO;return (OPMULT_);}

"++"                        {ECHO;return (OPINC_);}
"--"                        {ECHO;return (OPINC_);}
"!"                         {ECHO;return (OPUNA_);}

"&&"                        {ECHO;return (OPLOG_);}
"||"                        {ECHO;return (OPLOG_);}

"="							{ECHO;return (IGU_);}
"=="                        {ECHO;return (OPIGU_);}
"!="                        {ECHO;return (OPIGU_);}

">"                         {ECHO;return (OPREL_);}
"<"                         {ECHO;return (OPREL_);}
"<="                        {ECHO;return (OPREL_);}
">="                        {ECHO;return (OPREL_);}

"{"							{ECHO;return (ALLA_);}
"("							{ECHO;return (APAR_);}
"["							{ECHO;return (ACOR_);}
"}"							{ECHO;return (CLLA_);}
")"							{ECHO;return (CPAR_);}
"]"							{ECHO;return (CCOR_);}
{digito}+                   {ECHO;return (CTE_);}
{letra}({letra}|{digito})*  {ECHO;return (ID_);}
.                           {ECHO;}
%%
