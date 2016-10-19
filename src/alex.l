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
/*comentario "//".\n* */
comentario "//"[^\n]*"\n"
%%
{delimitador}     			{ECHO;}
"\n"                        {visualizar(0,"");}
{comentario}				{visualizar(1,"Comentario");}
if                          {ECHO; return (IF_);}
for                         {ECHO; return (FOR_);}
read 						{ECHO; return (READ_);}
print                 		{ECHO; return (PRINT_);}

"int"						{return (INT_);}
"bool"						{return (BOOL_);}

"+"                         {return(OPSUMA_);}
"-"                         {return (OPSUMA_);}

"*"                         {return (OPMULT_);}
"/"                         {return (OPMULT_);}

"++"                        {return (OPINC_);}
"--"                        {return (OPINC_);}
"!"                         {return (OPUNA_);}

"&&"                        {return (OPLOG_);}
"||"                        {return (OPLOG_);}

"=="                        {return (OPIGU_);}
"!="                        {return (OPIGU_);}

">"                         {return (OPREL_);}
"<"                         {return (OPREL_);}
"<="                        {return (OPREL_);}
">="                        {return (OPREL_);}

"{"							{return (ALLA_);}
"("							{return (APAR_);}
"["							{return (ACOR_);}
"}"							{return (CLLA_);}
")"							{return (CPAR_);}
"]"							{return (CCOR_);}
{digito}+                   {return (CTE_);}
{letra}({letra}|{digito})*  {return (ID_);}
.                           {visualizar(1,"Caracter no Valido:");}
%%
void visualizar(int opcion, char* texto)
{
	switch(opcion){
		case 0: printf("%3d- Nueva Linea\n",yylineno);
				break;
		case 1: printf("%3d- \%s \%s\n",yylineno,texto, yytext);
				break;
	}
}
int main (int argc, char **argv)
{
	if ((yyin = fopen (argv[1], "r")) == NULL)
		fprintf (stderr, "Fichero no valido \%s", argv[1]);
	yylex();
}
