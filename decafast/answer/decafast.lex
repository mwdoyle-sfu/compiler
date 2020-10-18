%{
#include "default-defs.h"
#include "decafast.tab.h"
#include <cstring>
#include <string>
#include <sstream>
#include <iostream>

using namespace std;

int lineno = 1;
int tokenpos = 1;

%}

%option yylineno


/* 
  Regexp definitions 
*/

/* valid characters */
all_char [\7-\13\40-\47\50-\67\70-\77\100-\107\110-\117\120-\127\130-\137\140-\147\150-\157\160-\167\170-\177]
char [\7-\11\13\40\41\43-\46\50-\67\70-\77\100-\107\110-\117\120-\127\130-\133\135-\137\140-\147\150-\157\160-\167\170-\177]
char_lit_chars [\7-\13\40-\46\50-\67\70-\77\100-\107\110-\117\120-\127\130-\133\135-\137\140-\147\150-\157\160-\167\170-\177]
char_no_nl [\7-\11\13\40-\46\50-\67\70-\77\100-\107\110-\117\120-\127\130-\137\140-\147\150-\157\160-\167\170-\177]

/* letters and digits */
letter [A-Za-z\_]
decimal_digit [0-9]
hex_digit [0-9A-Fa-f]
digit [0-9]
identifier {letter}({letter}|{digit})* 

/* whitespace */
newline "\n"
carriage_return "\r"
horizontal_tab "\t"
vertical_tab "\v"
form_feed "\f"
space " "
whitespace ({carriage_return}|{horizontal_tab}|{vertical_tab}|{form_feed}|{space})+

/* not whitespace */
bell "\a"
backspace "\b"

/* interger literal */
decimal_lit {decimal_digit}+
hex_lit "0"("x"|"X"){hex_digit}+
int_lit ({decimal_lit}|{hex_lit})

/* char literal */
escaped_char \\(n|r|t|v|f|a|b|(\\)|(\')|(\"))
char_lit (\'({char_lit_chars}|{escaped_char})\')

/* string literal */
string_lit \"(({char}|{escaped_char}))*\"






%%
  /*
    Pattern definitions for all tokens 
  */

=                          { return T_ASSIGN; }  
bool                       { return T_BOOL; }
{char_lit}                 { return T_CHARCONSTANT; }
,                          { return T_COMMA; }
extern                     { return T_EXTERN; }
false                      { return T_FALSE; }
func                       { return T_FUNC; }
int                        { return T_INTTYPE; }
\(                         { return T_LPAREN; }
\)                         { return T_RPAREN; }
{int_lit}                  { return T_INTCONSTANT; }

package                    { return T_PACKAGE; }
true                       { return T_TRUE; }
void                       { return T_VOID; }


\{                         { return T_LCB; }
\}                         { return T_RCB; }
\;                         { return T_SEMICOLON; }
string                     { return T_STRINGTYPE; }
var                        { return T_VAR; }

[a-zA-Z\_][a-zA-Z\_0-9]*   { yylval.sval = new string(yytext); return T_ID; } /* note that identifier pattern must be after all keywords */
[\t\r\n\a\v\b ]+           { } /* ignore whitespace */
.                          { cerr << "Error: unexpected character in input" << endl; return -1; }

%%

int yyerror(const char *s) {
  cerr << yylineno << ": " << s << " at char " << yytext << endl;
  return 1;
}

