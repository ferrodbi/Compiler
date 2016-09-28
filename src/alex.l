/* Subseccion preambulo C */
%{
#include <stdio.h>
extern FILE *yyin;
void visualizar(int opcion, char* texto);
%}

/* Subseccion de definiciones */
%option yylineno
comentario [//.]
delimitador [ \t]+
letra [a-zA-Z]
digito [0-9]
%%
{delimitador}     {ECHO;}
{comentario}				{visualizar(1,"Comentario");}
"\n"                        {visualizar(0,"");}
if                          {visualizar(1,"P. Reservada: ");}
for                         {visualizar(1,"P. Reservada: ");}
"+"                         {visualizar(1,"Op. suma: ");}
"*"                         {visualizar(1,"Op. mult: ");}
{digito}+                   {visualizar(1,"Cte.: ");}
{letra}({letra}|{digito})*  {visualizar(1,"Identificador: ");}
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