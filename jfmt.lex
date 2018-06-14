%{

/*
 *  @(!--#) @(#) jfmt.lex, version 004, 18-april-2018
 *
 *  JSON string formatter - lexer
 *
 *  Links:
 *
 *    http://dinosaur.compilertools.net/lex/index.html
 *
 */

#include "y.tab.h"

%}

%%

\"(\\.|[^"\\])*\"	{
			  strcpy(yylval.string, yytext);
			  /*
			  printf("STRING=[%s]\n", yylval.string);
			  */
			  return(STRING);
			}

\-?[0-9]+(\.[0-9]+)?	{
			  strcpy(yylval.string, yytext);
			  /*
			  printf("NUMBER=[%s]\n", yylval.string);
			  */
			  return(NUMBER);
			}

\{			{
			  return(OPENCURLYBRACE);
			}

\}			{
			  return(CLOSECURLYBRACE);
			}

:			{
			  return(COLON);
			}

,			{
			  return(COMMA);
			  printf("Comma\n");
			}

\n			{
			 ; /* ignore */
			}

.			{
			  fprintf(stderr, "Unrecognised character [%s]\n", yytext);
			}

%%

int yywrap()
{
  return 1;
}
