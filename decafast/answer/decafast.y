/* C++ Files */
%{
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include "decafast-defs.h"

int yylex(void);
int yyerror(char *); 

// print AST?
bool printAST = true;
string output = "";

#include "decafast.cc"

using namespace std;

%}

/* Bison version specific */
%define parse.error verbose

/* 
    Data Structure that you must extend 
*/
%union{
    
    class decafAST *ast;
    std::string *sval;
    int number;
    int decaftype;

 }

%token T_ASSIGN T_VOID T_BOOL T_INTTYPE T_STRINGTYPE
%token T_EXTERN T_PACKAGE T_COMMA T_PLUS
%token T_LCB T_LPAREN T_RPAREN T_SEMICOLON 
%token T_RCB T_VAR T_WHILE T_BREAK T_RETURN
%token T_FUNC T_TRUE T_FALSE T_FOR T_LSB T_RSB

%token T_MINUS T_MULT T_DIV T_MOD T_LEFTSHIFT T_RIGHTSHIFT T_AND T_OR T_EQ T_GEQ
%token T_GT T_LEQ T_LT T_NEQ UMINUS T_NOT T_CONTINUE T_IF T_ELSE


%token <number> T_CHARCONSTANT T_INTCONSTANT 
%token <sval> T_ID T_STRINGCONSTANT

%type <ast> vardecl bool_constant extern_list decafpackage externvars fieldtype constant vardecls statement_list
%type <ast> externtype externdefn field_decl field_decls methoddecl methoddecls methodtype methodblock
%type <ast> externvar statement assigns assign lvalue expr methodcall methodarguments methodargument
%type <ast> return block if

%left T_OR
%left T_AND
%left T_EQ T_GEQ T_GT T_LEQ T_LT T_NEQ
%left T_PLUS T_MINUS
%left T_MULT T_DIV T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%left T_NOT
%right UMINUS


%%

start: program
    ;


program: extern_list decafpackage
            { 
                /* 
                    decafStmtList takes care of all extern function definitions
                    PackageAST holds the package subtree
                */
                ProgramAST *prog = new ProgramAST((decafStmtList *)$1, (PackageAST *)$2); 
                if (printAST) {
                    cout << getString(prog) << endl;
                }
                delete prog;
            }
    ;

// Extern
extern_list: externdefn extern_list
            {   
                decafStmtList *slist = (decafStmtList *) $2;
                slist->push_front($1);
                $$ = slist;
            }
    |        /* extern_list can be empty */
            { 
                decafStmtList *slist = new decafStmtList(); 
                $$ = slist;
            }
    ;

externdefn: T_EXTERN T_FUNC T_ID T_LPAREN externvars T_RPAREN externtype T_SEMICOLON 
            { $$ = new ExternAST(*$3, $7, $5); }
    ;

externvars: externvar externvars
            {
                decafStmtList *slist = (decafStmtList *) $2;
                slist->push_front($1);
                $$ = slist;
            }
    |        externvar T_COMMA externvars
            { 
                decafStmtList *slist = (decafStmtList *) $3;
                slist->push_front($1);
                $$ = slist;
            }
    |        /* extern_list can be empty */
            { 
                decafStmtList *slist = new decafStmtList(); 
                $$ = slist;
            }
    ;

externvar: T_STRINGTYPE { $$ = new VarDefExternAST(T_STRINGTYPE); }
    |      T_INTTYPE { $$ = new VarDefExternAST(T_INTTYPE); }
    |      T_VOID { $$ = new VarDefExternAST(T_VOID); }
    |      T_BOOL { $$ = new VarDefExternAST(T_BOOL); }
    ;

externtype: T_STRINGTYPE { $$ = new GenericAST("StringType"); }
    |       T_INTTYPE { $$ = new GenericAST("IntType"); }
    |       T_VOID { $$ = new GenericAST("VoidType"); }
    |       T_BOOL { $$ = new GenericAST("BoolType"); }
    ;

// Package
decafpackage: T_PACKAGE T_ID T_LCB field_decls methoddecls T_RCB
            { 
                $$ = new PackageAST(*$2, (decafStmtList *)$4, (decafStmtList *)$5); 
                delete $2;
            }
    ;

field_decls: field_decl field_decls
            {
                decafStmtList *slist = (decafStmtList *)$2; 
                slist->push_front($1); 
                $$ = slist;
            }
    |       /* empty */
            {
                decafStmtList *slist = new decafStmtList(); 
                $$ = slist;
            }
    ;

field_decl: T_VAR T_ID fieldtype T_SEMICOLON { $$ = new FieldDeclarationNoAssignAST(*$2,$3); }
    |       T_VAR T_ID fieldtype T_ASSIGN constant T_SEMICOLON { $$ = new FieldDeclarationAST($3,*$2, $5); }
    ;

fieldtype: T_INTTYPE { $$ = new GenericAST("IntType"); }
    |      T_BOOL { $$ = new GenericAST("BoolType"); }
    ;

constant: T_INTCONSTANT { $$ = new NumberExprAST($1); }
    | T_CHARCONSTANT { $$ = new NumberExprAST($1); }
    | bool_constant { $$ = $1; }
    ;

bool_constant: T_TRUE { $$ = new BoolAST(true); }
    |          T_FALSE { $$ = new BoolAST(false); }           
    ;

// Methods
methoddecls: methoddecl methoddecls { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    |        /* empty */ { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

methoddecl: T_FUNC T_ID T_LPAREN T_RPAREN methodtype methodblock {$$ = new MethodDeclarationAST(*$2,$5,NULL,$6);}
    ;

methodtype: T_VOID {$$ = new GenericAST("VoidType");}
    |       T_INTTYPE {$$ = new GenericAST("IntType");}
    |       T_BOOL {$$ = new GenericAST("BoolType");}
    ;

methodblock: T_LCB vardecls statement_list T_RCB { $$ = new MethodBlockAST($2,$3); }
    |        /* empty */ { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

vardecls: vardecl vardecls T_SEMICOLON { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | vardecl T_COMMA vardecls T_SEMICOLON { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist;}
    | /* empty */ { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

vardecl: T_VAR T_ID T_INTTYPE {$$ = new VarDefMethodBlockAST(T_INTTYPE,*$2);}
    |    T_VAR T_ID T_BOOL {$$ = new VarDefMethodBlockAST(T_BOOL,*$2); }
    ;

statement_list: statement statement_list { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    |           /* empty */ {decafStmtList *slist = new decafStmtList(); $$ = slist;}   
    ;

// new stuff

statement: methodcall T_SEMICOLON { $$ = $1;}
    |      assign T_SEMICOLON { $$ = $1; }
    |       if { $$ = $1; }
    |       T_WHILE T_LPAREN expr T_RPAREN block { $$ = new WhileAST($3,$5); }
    |       T_FOR T_LPAREN assigns T_SEMICOLON expr T_SEMICOLON assigns T_RPAREN block { $$ = new ForAST($3,$5,$7,$9);}
    |       T_BREAK T_SEMICOLON { $$ = new GenericAST("BreakStmt");}
    |       T_CONTINUE T_SEMICOLON { $$ = new GenericAST("ContinueStmt");}
    |       return { $$ = $1;}
    |       block { $$ = $1; }
    ;

// // below here...

assigns: assign assigns { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */ { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

// check the formatting
assign: T_ID T_ASSIGN expr { $$ = new AssignVarAST(*$1, $3); delete $1; }
    |   T_ID T_LSB expr T_RSB T_ASSIGN expr { $$ = new AssignArrayAST(*$1,$3,$6); }
    ;
 
expr: constant { $$ = $1; }
    | lvalue { $$ = $1; }
    | methodcall { $$ = $1; }
    | expr T_PLUS expr { $$ = new BinaryExprAST(T_PLUS, $1, $3); }
    | expr T_MINUS expr { $$ = new BinaryExprAST(T_MINUS, $1, $3); }
    | expr T_MULT expr { $$ = new BinaryExprAST(T_MULT, $1, $3); }
    | expr T_DIV expr { $$ = new BinaryExprAST(T_DIV, $1, $3); }
    | expr T_MOD expr { $$ = new BinaryExprAST(T_MOD, $1, $3); }
    | expr T_LEFTSHIFT expr { $$ = new BinaryExprAST(T_LEFTSHIFT, $1, $3); }
    | expr T_RIGHTSHIFT expr { $$ = new BinaryExprAST(T_RIGHTSHIFT, $1, $3); }
    | expr T_AND expr { $$ = new BinaryExprAST(T_AND, $1, $3); }
    | expr T_OR expr { $$ = new BinaryExprAST(T_OR, $1, $3); }
    | expr T_EQ expr { $$ = new BinaryExprAST(T_EQ, $1, $3); }
    | expr T_GEQ expr { $$ = new BinaryExprAST(T_GEQ, $1, $3); }
    | expr T_GT expr { $$ = new BinaryExprAST(T_GT, $1, $3); }
    | expr T_LEQ expr { $$ = new BinaryExprAST(T_LEQ, $1, $3); }
    | expr T_LT expr { $$ = new BinaryExprAST(T_LT, $1, $3); }
    | expr T_NEQ expr { $$ = new BinaryExprAST(T_NEQ, $1, $3); }
    | T_MINUS expr %prec UMINUS { $$ = new UnaryExprAST(T_MINUS, $2); }
    | T_NOT expr { $$ = new UnaryExprAST(T_NOT, $2); }
    | T_LPAREN expr T_RPAREN { $$ = $2; }
    ;

lvalue: T_ID { $$ = new VariableExprAST(*$1); delete $1; }
    |   T_ID T_LSB expr T_RSB { $$ = new ArrayLocExprAST(*$1,$3);}
    ;

methodcall: T_ID T_LPAREN T_RPAREN {$$ = new MethodCallAST(*$1, NULL); }
    |       T_ID T_LPAREN methodarguments T_RPAREN { $$ = new MethodCallAST(*$1,$3); }
    ;

methodarguments: methodargument methodarguments { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    |            methodargument T_COMMA methodarguments { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist;}
    |            /* empty */ { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

methodargument: T_STRINGCONSTANT { $$ = new StringConstAST(*$1); }
    |           expr {$$ = $1;} 
    |           /* empty */ { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

return:  T_RETURN T_SEMICOLON { $$ = new ReturnAST(NULL); }
    |    T_RETURN T_LPAREN T_RPAREN T_SEMICOLON { $$ = new ReturnAST(NULL); }
    |    T_RETURN T_LPAREN expr T_RPAREN T_SEMICOLON { $$ = new ReturnAST($3); }
    ;

if:   T_IF T_LPAREN expr T_RPAREN block { $$ = new IfElseAST($3,$5, NULL); }
    | T_IF T_LPAREN expr T_RPAREN block T_ELSE block { $$ = new IfElseAST($3,$5,$7); }
    ;

block: T_LCB vardecls statement_list T_RCB { $$ = new BlockAST($2,$3);}
    ;

%%

int main() {
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  return(retval >= 1 ? EXIT_FAILURE : EXIT_SUCCESS);
}

