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


int get_intconstant(const char *s) {
  if ((s[0] == '0') && (s[1] == 'x')) {
    int x;
    sscanf(s, "%x", &x);
    return x;
  } else {
    return atoi(s);
  }
}

int get_charconstant(const char *s) {
  if (s[1] == '\\') { // backslashed char
    switch(s[2]) {
    case 't': return (int)'\t';
    case 'v': return (int)'\v';
    case 'r': return (int)'\r';
    case 'n': return (int)'\n';
    case 'a': return (int)'\a';
    case 'f': return (int)'\f';
    case 'b': return (int)'\b';
    case '\\': return (int)'\\';
    case '\'': return (int)'\'';
    default: throw runtime_error("unknown char constant\n");
    }
  } else {
    return (int)s[1];
  }
}

string *process_string (const char *s) {
  string *ns = new string("");
  size_t len = strlen(s);
  // remove the double quotes, use s[1..len-1]
  for (int i = 1; i < len-1; i++) {
    if (s[i] == '\\') {
      i++;
      switch(s[i]) {
      case 't': ns->push_back('\t'); break;
      case 'v': ns->push_back('\v'); break;
      case 'r': ns->push_back('\r'); break;
      case 'n': ns->push_back('\n'); break;
      case 'a': ns->push_back('\a'); break;
      case 'f': ns->push_back('\f'); break;
      case 'b': ns->push_back('\b'); break;
      case '\\': ns->push_back('\\'); break;
      case '\'': ns->push_back('\''); break;
      case '\"': ns->push_back('\"'); break;
      default: throw runtime_error("unknown char escape\n");  
      }
    } else {
      ns->push_back(s[i]);
    }
  }
  return ns;
}

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
&&                         { return T_AND; }
=                          { return T_ASSIGN; }  
bool                       { return T_BOOL; }
break                      { return T_BREAK; }
{char_lit}                 { yylval.number = get_charconstant(yytext); return T_CHARCONSTANT;  }
,                          { return T_COMMA; }
\/                         { return T_DIV; }
==                         { return T_EQ; }

extern                     { return T_EXTERN; }
\>=                        { return T_GEQ; }
\>                         { return T_GT; }

false                      { return T_FALSE; }
for                        { return T_FOR; }

func                       { return T_FUNC; }
int                        { return T_INTTYPE; }
(0x[0-9a-fA-F]+)|([0-9]+)                   { yylval.number = get_intconstant(yytext); return T_INTCONSTANT; }

package                    { return T_PACKAGE; }
true                       { return T_TRUE; }
void                       { return T_VOID; }


\{                         { return T_LCB; }
\<<                        { return T_LEFTSHIFT; }
\<=                        { return T_LEQ; }

\[                         { return T_LSB; }
\<                         { return T_LT; }

\(                         { return T_LPAREN; }
-                          { return T_MINUS; }
\%                         { return T_MOD; }

\*                         { return T_MULT; }
\!=                        { return T_NEQ; }
!                          { return T_NOT; }

\+                         { return T_PLUS; }
\|\|                       { return T_OR; }

\}                         { return T_RCB; }
\>>                        { return T_RIGHTSHIFT; }
\)                         { return T_RPAREN; }
\]                           { return T_RSB; }

\;                         { return T_SEMICOLON; }
string                     { return T_STRINGTYPE; }
{string_lit}               { yylval.sval = process_string(yytext); return T_STRINGCONSTANT; }
var                        { return T_VAR; }
while                      { return T_WHILE; }

[a-zA-Z\_][a-zA-Z\_0-9]*   { yylval.sval = new string(yytext); return T_ID; } /* note that identifier pattern must be after all keywords */
[\t\r\n\a\v\b ]+           { } /* ignore whitespace */
.                          { cerr << "Error: unexpected character in input" << endl; return -1; }

%%

int yyerror(const char *s) {
  cerr << yylineno << ": " << s << " at char " << yytext << endl;
  return 1;
}

