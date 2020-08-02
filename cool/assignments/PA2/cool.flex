/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%option noyywrap

%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <cstdio>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1024
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int string_len;
int escape;
int comment_level = 0;

%}

/*
 * Define names for regular expressions here.
 */

CLASS           (?i:class)
ELSE            (?i:else)
FALSE           f(?i:alse)
FI              (?i:fi)
IF              (?i:if)
IN              (?i:in)
INHERITS        (?i:inherits)
ISVOID          (?i:isvoid)
LET             (?i:let)
LOOP            (?i:loop)
POOL            (?i:pool)
THEN            (?i:then)
WHILE           (?i:while)
CASE            (?i:case)
ESAC            (?i:esac)
NEW             (?i:new)
OF              (?i:of)
NOT             (?i:not)
TRUE            t(?i:rue)

DARROW          =>
ASSIGN          <-
NEW_LINE        \n
LE              <=

WHITESPACE      [ \t\r\f\v]
SINGLE_CHAR     [+/\-\*=<.~,;:\(\)@\{\}]
DOUBLE_QUOTE    \"
ESCAPE_CHAR     \\
ALL_CHARACTER   .

INT_CONST       [0-9]+
OBJECTID        [a-z][a-zA-Z0-9_]*
TYPEID          [A-Z][a-zA-Z0-9_]*

/*
LET_STMT        (?i:let_stmt)
*/

%x COMMENT1LINE
%x COMMENT
%x STRING
%x STRING_ERROR

%%

 /*
  *  Nested comments
  */
"*)"              {
  yylval.error_msg = "Unmatched *)";
  return ERROR;
}

"(*"              {
  BEGIN(COMMENT);
  comment_level++;
}

<COMMENT>"(*"     { comment_level++; }

<COMMENT>"*)"     {
  comment_level--;
  if (comment_level == 0)
    BEGIN(INITIAL);
}

<COMMENT><<EOF>>  {
  yylval.error_msg = "EOF in comment";
  BEGIN(INITIAL);
  return ERROR;
}

<COMMENT>\n       { curr_lineno++; }
<COMMENT>.        { }

"--"              { BEGIN(COMMENT1LINE); }

<COMMENT1LINE>\n  {
  BEGIN(INITIAL);
  curr_lineno++;
}

<COMMENT1LINE>.   { }

 /*
  *  The multiple-character operators.
  */

{DARROW}          { return (DARROW); }
{ASSIGN}          { return (ASSIGN); }
{LE}              { return (LE);}
{NEW_LINE}        { curr_lineno++; }
{WHITESPACE}      { }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{CLASS}           { return (CLASS); }
{ELSE}            { return (ELSE); }
{FI}              { return (FI); }
{IF}              { return (IF); }
{IN}              { return (IN); }
{INHERITS}        { return (INHERITS); }
{ISVOID}          { return (ISVOID); }
{LET}             { return (LET); }
{LOOP}            { return (LOOP); }
{POOL}            { return (POOL); }
{THEN}            { return (THEN); }
{WHILE}           { return (WHILE); }
{CASE}            { return (CASE); }
{ESAC}            { return (ESAC); }
{NEW}             { return (NEW); }
{OF}              { return (OF); }
{NOT}             { return (NOT); }

{TRUE}            {
  yylval.boolean = 1;
  return BOOL_CONST;
}

{FALSE}           {
  yylval.boolean = 0;
  return BOOL_CONST;
}

{INT_CONST}       {
  yylval.symbol = inttable.add_string(yytext);
  return INT_CONST;
}

{OBJECTID}        {
  yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

{TYPEID}          {
  yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}

{SINGLE_CHAR}     { return yytext[0]; }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\"                {
  BEGIN(STRING);
  string_len = 0;
}

<STRING><<EOF>>   {
  BEGIN(STRING_ERROR);
  yylval.error_msg = "EOF in string constant";
  return ERROR;
}

<STRING>\"        {
  if (escape) {
    if (string_len == MAX_STR_CONST) {
      BEGIN(STRING_ERROR);
      yylval.error_msg = "String constant too long";
      return ERROR;
    }
    escape = 0;
    string_buf[string_len++] = '"';
  }
  else {
    BEGIN(INITIAL);
    yylval.symbol = stringtable.add_string(string_buf, string_len);
    return STR_CONST;
  }
}

<STRING>\n        {
  curr_lineno++;
  if (escape) {
    if (string_len == MAX_STR_CONST) {
      BEGIN(STRING_ERROR);
      yylval.error_msg = "String constant too long";
      return ERROR;
    }
    string_buf[string_len++] = '\n';
    escape = 0;
  }
  else {
    BEGIN(INITIAL);
    yylval.error_msg = "Unterminated string constant";
    return ERROR;
  }
}

<STRING>\\        {
  if (escape) {
    if (string_len == MAX_STR_CONST) {
      BEGIN(STRING_ERROR);
      yylval.error_msg = "String constant too long";
      return ERROR;
    }
    string_buf[string_len++] = '\\';
    escape = 0;
  }
  else {
    escape = 1;
  }
}

<STRING>.         {
  if (yytext[0] == '\0') {
    BEGIN(STRING_ERROR);
    yylval.error_msg = "String contains null character.";
    return ERROR;
  }

  if (string_len == MAX_STR_CONST) {
    BEGIN(STRING_ERROR);
    yylval.error_msg = "String constant too long";
    return ERROR;
  }
  if (escape) {
    switch (yytext[0]) {
      case 'n':
        string_buf[string_len++] = '\n';
        break;
      case 't':
        string_buf[string_len++] = '\t';
        break;
      case 'b':
        string_buf[string_len++] = '\b';
        break;
      case 'f':
        string_buf[string_len++] = '\f';
        break;
      default:
        string_buf[string_len++] = yytext[0];
    }
    escape = 0;
  }
  else {
    string_buf[string_len++] = yytext[0];
  }
}

<STRING_ERROR>\n  {
  BEGIN(INITIAL);
  curr_lineno++;
}

<STRING_ERROR>\\  {
  escape = 1 - escape;
}

<STRING_ERROR>\"  {
  if (escape == 0) {
    BEGIN(INITIAL);
  }
}

<STRING_ERROR>.   { }

 /*
  * Invalid characters
  */

.                 {
  yylval.error_msg = yytext;
  return ERROR;
}
%%
