%{

/*
 *  @(!--#) @(#) jfmt.yacc, version 004, 17-april-2018
 *
 *  JSON formatter - yacc grammar
 *
 */

#include <stdio.h>
#include <string.h>

int yylex(void);

void yyerror(char *);

char *matchstring;

int    numopen = 0;
int    numclose = 0;

void isamatch(ms, val)
  char *ms;
  char *val;
{
  if (*matchstring == '\0') {
    printf("%s:%s\n", ms, val);
  } else {
    if (strcmp(matchstring, ms) == 0) {
      printf("%s\n", val);
    }
  }

  return;
}

%}

%union {
  char  string[1024];
}

%token STRING
%token NUMBER
%token OPENCURLYBRACE
%token CLOSECURLYBRACE
%token COLON
%token COMMA

%type<string> STRING NUMBER

%%

json		: OPENCURLYBRACE pairlist CLOSECURLYBRACE
		;

pairlist	: pair
		| pairlist COMMA pair
		;

pair		: STRING COLON STRING		{ isamatch($1, $3); }
		| STRING COLON NUMBER		{ isamatch($1, $3); }
		| STRING COLON json
		;

%%

void yyerror(s)
  char *s;
{
  fprintf(stderr, "%s\n", s);
}

int main(argc, argv)
  int   argc;
  char *argv[];
{
  if (argc >= 2) {
    matchstring = argv[1];
  } else {
    matchstring = "";
  }

  yyparse();

  return 0;
}
