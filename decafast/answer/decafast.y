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

 }

%token T_ASSIGN T_VOID T_BOOL T_INTTYPE T_STRINGTYPE
%token T_EXTERN T_PACKAGE T_COMMA  
%token T_LCB T_LPAREN T_RPAREN T_SEMICOLON 
%token T_RCB T_VAR 
%token T_FUNC T_TRUE T_FALSE

%token <number> T_CHARCONSTANT T_INTCONSTANT
%token <sval> T_ID

%type <ast> vardecl bool_constant extern_list decafpackage externvars fieldtype constant vardecls statement_list
%type <ast> externvar externtype externdefn field_decl field_decls methoddecl methoddecls methodtype methodblock

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

field_decl: T_VAR T_ID fieldtype T_SEMICOLON 
            { $$ = new FieldDeclarationNoAssignAST(*$2,$3); }
    |       T_VAR T_ID fieldtype T_ASSIGN constant T_SEMICOLON { $$ = new FieldDeclarationNoAssignAST(*$2,$3); }
    ;

fieldtype: T_INTTYPE { $$ = new GenericAST("IntType"); }
    |      T_BOOL { $$ = new GenericAST("BoolType"); }
    ;

constant: bool_constant { $$ = $1; }
    |     T_INTCONSTANT { $$ = new NumberExprAST($1); }
    |     T_CHARCONSTANT { $$ = new NumberExprAST($1); }
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

vardecls: vardecl vardecls T_SEMICOLON
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | vardecl T_COMMA vardecls T_SEMICOLON
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist;}
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

vardecl: T_VAR T_ID T_INTTYPE
        {$$ = new VarDefMethodBlockAST(T_INTTYPE,*$2);}
    |    T_VAR T_ID T_BOOL
        {$$ = new VarDefMethodBlockAST(T_BOOL,*$2); }
    ;

statement_list: {decafStmtList *slist = new decafStmtList(); $$ = slist;}

%%

int main() {
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  return(retval >= 1 ? EXIT_FAILURE : EXIT_SUCCESS);
}

