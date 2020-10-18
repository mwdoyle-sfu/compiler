
%{

#include <iostream>
#include <cstdlib>

using namespace std;

int yycolumn = 1;

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
bool                         { return 1; }
break                        { return 2; }
continue                     { return 3; }
else                         { return 4; }
extern                       { return 5; }
false                        { return 6; }
for                          { return 7; }
func                         { return 8; }
if                           { return 9; }
int                          { return 10; }
null                         { return 11; }
package                      { return 12; }
return                       { return 13; }
string                       { return 14; }
true                         { return 15; }
var                          { return 16; }
void                         { return 17; }
while                        { return 18; }
{int_lit}                    { return 19; }
{string_lit}                 { return 20; }
((\/\/){char_no_nl}*(\n))    { return 21; }
\[                           { return 22; }
\]                           { return 23; }
\,                           { return 24; }
\!                           { return 25; }
\+                           { return 26; }
\*                           { return 27; }
\/                           { return 28; }
"<<"                         { return 29; }
">>"                         { return 30; }
\<                           { return 31; }
\>                           { return 32; }
\%                           { return 33; }
"<="                         { return 34; }
">="                         { return 35; }
"=="                         { return 36; }
"!="                         { return 37; }
"&&"                         { return 38; }
"||"                         { return 39; }
\.                           { return 40; }
\-                           { return 41; }
\{                           { return 42; }
\}                           { return 43; }
\(                           { return 44; }
\)                           { return 45; }
{identifier}                 { return 46; }
{whitespace}                 { return 47; }
[\n\t\ ]*|(\t)*(" ")*(\n)    { return 48; } 
\;                           { return 49; }
\=                           { return 50; }
{char_lit}                   { return 51; }
\"\\z\"                      { cerr << "Error: unknown escape sequence in string constant" << endl; 
                               cerr << "Lexical error: line " << yylineno << ", position " << yycolumn << endl; return -1; }
\"\n\"                      { cerr << "Error: newline in string constant" << endl;
                              cerr << "Lexical error: line " << yylineno << ", position " << yycolumn << endl; return -1; }
\"\"\"                       { cerr << "Error: string constant is missing closing delimiter" << endl;
                               cerr << "Lexical error: line " << yylineno << ", position " << yycolumn << endl; return -1; }
.                            { cerr << "Error: unexpected character in input" << endl;
                               cerr << "Lexical error: line " << yylineno << ", position " << yycolumn << endl; return -1; }
%%

int main () {
  int token;
  string lexeme;
  while ((token = yylex())) {
    if (token > 0) {
      lexeme.assign(yytext);
      switch(token) {
        case 1: cout << "T_BOOLTYPE " << lexeme << endl; break;
        case 2: cout << "T_BREAK " << lexeme << endl; break;
        case 3: cout << "T_CONTINUE " << lexeme << endl; break;
        case 4: cout << "T_ELSE " << lexeme << endl; break;
        case 5: cout << "T_EXTERN " << lexeme << endl; break;
        case 6: cout << "T_FALSE " << lexeme << endl; break;
        case 7: cout << "T_FOR " << lexeme << endl; break;
        case 8: cout << "T_FUNC " << lexeme << endl; break;
        case 9: cout << "T_IF " << lexeme << endl; break;
        case 10: cout << "T_INTTYPE " << lexeme << endl; break;
        case 11: cout << "T_NULL " << lexeme << endl; break;
        case 12: cout << "T_PACKAGE " << lexeme << endl; break;
        case 13: cout << "T_RETURN " << lexeme << endl; break;
        case 14: cout << "T_STRINGTYPE " << lexeme << endl; break;
        case 15: cout << "T_TRUE " << lexeme << endl; break;
        case 16: cout << "T_VAR " << lexeme << endl; break;
        case 17: cout << "T_VOID " << lexeme << endl; break;
        case 18: cout << "T_WHILE " << lexeme << endl; break;
        case 19: cout << "T_INTCONSTANT " << lexeme << endl; break;
        case 20: cout << "T_STRINGCONSTANT " << lexeme << endl; break;
        case 21: cout << "T_COMMENT " << lexeme.substr(0, lexeme.length()-1) << "\\n" << endl; break;
        case 22: cout << "T_LSB " << lexeme << endl; break;
        case 23: cout << "T_RSB " << lexeme << endl; break;
        case 24: cout << "T_COMMA " << lexeme << endl; break;
        case 25: cout << "T_NOT " << lexeme << endl; break;
        case 26: cout << "T_PLUS " << lexeme << endl; break;
        case 27: cout << "T_MULT " << lexeme << endl; break;
        case 28: cout << "T_DIV " << lexeme << endl; break;
        case 29: cout << "T_LEFTSHIFT " << lexeme << endl; break;
        case 30: cout << "T_RIGHTSHIFT " << lexeme << endl; break;
        case 31: cout << "T_LT " << lexeme << endl; break;
        case 32: cout << "T_GT " << lexeme << endl; break;
        case 33: cout << "T_MOD " << lexeme << endl; break;
        case 34: cout << "T_LEQ " << lexeme << endl; break;
        case 35: cout << "T_GEQ " << lexeme << endl; break;
        case 36: cout << "T_EQ " << lexeme << endl; break;
        case 37: cout << "T_NEQ " << lexeme << endl; break;
        case 38: cout << "T_AND " << lexeme << endl; break;
        case 39: cout << "T_OR " << lexeme << endl; break;
        case 40: cout << "T_DOT " << lexeme << endl; break;
        case 41: cout << "T_MINUS " << lexeme << endl; break;
        case 42: cout << "T_LCB " << lexeme << endl; break;
        case 43: cout << "T_RCB " << lexeme << endl; break;
        case 44: cout << "T_LPAREN " << lexeme << endl; break;
        case 45: cout << "T_RPAREN " << lexeme << endl; break;
        case 46: cout << "T_ID " << lexeme << endl; break;
        case 47: cout << "T_WHITESPACE " << lexeme << endl; break;
        case 48: 
          cout << "T_WHITESPACE "; 
          for(int i = 0; i< lexeme.length(); i++) {
            if(lexeme[i] == '\n') {
              cout << "\\n";
            } else if (lexeme[i] == ' '){
              cout << " ";
            } else if (lexeme[i] == '\t'){
              cout << "\t";
            }
          }
          cout << endl;
          break;
        case 49: cout << "T_SEMICOLON ;" << endl; break;
        case 50: cout << "T_ASSIGN =" << endl; break;
        case 51: cout << "T_CHARCONSTANT " << lexeme << endl; break; 
        default: exit(EXIT_FAILURE);
      }
    } else {
      if (token < 0) {
        exit(EXIT_FAILURE);
      }
    }
  }
  exit(EXIT_SUCCESS);
}
