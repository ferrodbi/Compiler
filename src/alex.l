/* Subseccion preambulo C */
%{
#include <stdio.h>
extern FILE *yyin;
void visualizar(int opcion, char* texto);
%}

/* Subseccion de definiciones */
%option yylineno
delimitador [ \t]+
tipo	"int"|"bool"
letra [a-zA-Z]
digito [0-9]
comentario "//".*
%%
{delimitador}     			{ECHO;}
"\n"                        {visualizar(0,"");}
{comentario}				{visualizar(1,"Comentario");}
if                          {visualizar(1,"P. Reservada: ");}
for                         {visualizar(1,"P. Reservada: ");}
{tipo}						{visualizar(1,"Tipo: ");}	
read 						{visualizar(1,"P. Reservada: ");}
print                 		{visualizar(1,"P. Reservada: ");}


"+"                         {return (OPSUMA_);}
"*"                         {return (OPMULT_);}
"&&"                        {return (OPLOG_);}
"=="                        {return (OPIGU_);}
"!="                        {return (OPIGU_);}
">"                         {return (OPREL_);}
"<"                         {return (OPREL_);}
"<="                        {return (OPREL_);}
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
