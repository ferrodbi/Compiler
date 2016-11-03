/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_ASIN_H_INCLUDED
# define YY_YY_ASIN_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ID_ = 258,
    CTE_ = 259,
    MAS_ = 260,
    MENOS_ = 261,
    MASMAS_ = 262,
    MENOSMENOS_ = 263,
    PROD_ = 264,
    DIV_ = 265,
    MAY_ = 266,
    MENOR_ = 267,
    MAYIGU_ = 268,
    MENIGU_ = 269,
    IGU_ = 270,
    IGUIGU_ = 271,
    NOTIGU_ = 272,
    EXCL_ = 273,
    ANDAND_ = 274,
    OROR_ = 275,
    ALLA_ = 276,
    CLLA_ = 277,
    APAR_ = 278,
    CPAR_ = 279,
    ACOR_ = 280,
    CCOR_ = 281,
    PCOMA_ = 282,
    PUNTO_ = 283,
    TRUE_ = 284,
    FALSE_ = 285,
    BOOL_ = 286,
    INT_ = 287,
    STRUCT_ = 288,
    FOR_ = 289,
    IF_ = 290,
    ELSE_ = 291,
    READ_ = 292,
    PRINT_ = 293
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_ASIN_H_INCLUDED  */
