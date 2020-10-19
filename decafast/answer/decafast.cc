
#include "decafast-defs.h"
#include <list>
#include <ostream>
#include <iostream>
#include <sstream>

#ifndef YYTOKENTYPE
#include "decafast.tab.h"
#endif

using namespace std;

// helper functions
string getType(int Op) {
	switch (Op) {
		case T_STRINGTYPE: return string("StringType");
		case T_INTTYPE: return string("IntType");
		case T_VOID: return string("VoidType");
		case T_BOOL: return string("BoolType");
		default: throw runtime_error("unknown type in TypeString call");
	}
}

string BinaryOpString(int Op) {
	switch (Op) {
		case T_PLUS: return string("Plus");
  		case T_MINUS: return string("Minus");
  		case T_MULT: return string("Mult");
  		case T_DIV: return string("Div");
  		case T_MOD: return string("Mod");
  		case T_LEFTSHIFT: return string("Leftshift");
  		case T_RIGHTSHIFT: return string("Rightshift");
  		case T_AND: return string("And");
  		case T_OR: return string("Or");
  		case T_EQ: return string("Eq");
  		case T_GEQ: return string("Geq");
  		case T_GT: return string("Gt");
  		case T_LEQ: return string("Leq");
  		case T_LT: return string("Lt");
  		case T_NEQ: return string("Neq");
  
		default: throw runtime_error("unknown type in BinaryOpString call");
	}
}

string UnaryOpString(int Op) {
	switch (Op) {
  		case T_MINUS: return string("UnaryMinus");
  		case T_NOT: return string("Not");
  		case T_BREAK: return string("BreakStmt");
		default: throw runtime_error("unknown type in UnaryOpString call");
	}
}

string convertInt(int number) {
	stringstream ss;
	ss << number;
	return ss.str();
}




/// decafAST - Base class for all abstract syntax tree nodes.
class decafAST {
public:
  virtual ~decafAST() {}
  virtual string str() { return string(""); }
};

string getString(decafAST *d) {
	if (d != NULL) {
		return d->str();
	} else {
		return string("None");
	}
}

template <class T>
string commaList(list<T> vec) {
    string s("");
    for (typename list<T>::iterator i = vec.begin(); i != vec.end(); i++) { 
        s = s + (s.empty() ? string("") : string(",")) + (*i)->str(); 
    }   
    if (s.empty()) {
        s = string("None");
    }   
    return s;
}

/// decafStmtList - List of Decaf statements
class decafStmtList : public decafAST {
	list<decafAST *> stmts;
public:
	decafStmtList() {}
	~decafStmtList() {
		for (list<decafAST *>::iterator i = stmts.begin(); i != stmts.end(); i++) { 
			delete *i;
		}
	}
	int size() { return stmts.size(); }
	void push_front(decafAST *e) { stmts.push_front(e); }
	void push_back(decafAST *e) { stmts.push_back(e); }
	string str() { return commaList<class decafAST *>(stmts); }
};

// similar to Defaf.asdl
class PackageAST : public decafAST {
	string Name;
	decafStmtList *FieldDeclList;
	decafStmtList *MethodDeclList;
public:
	// constructor takes 3 args
	PackageAST(string name, decafStmtList *fieldlist, decafStmtList *methodlist) 
		: Name(name), FieldDeclList(fieldlist), MethodDeclList(methodlist) {}
	~PackageAST() { 
		if (FieldDeclList != NULL) { delete FieldDeclList; }
		if (MethodDeclList != NULL) { delete MethodDeclList; }
	}
	string str() { 
		return string("Package") + "(" + Name + "," + getString(FieldDeclList) + "," + getString(MethodDeclList) + ")";
	}
};

// add more of these following the Decaf.asdl

// example ExternFunction

// example field assignment  ex.AssignVar size = 1 

/// ProgramAST - the decaf program
class ProgramAST : public decafAST {
	decafStmtList *ExternList;
	PackageAST *PackageDef;
public:
	ProgramAST(decafStmtList *externs, PackageAST *c) : ExternList(externs), PackageDef(c) {}
	~ProgramAST() { 
		if (ExternList != NULL) { delete ExternList; } 
		if (PackageDef != NULL) { delete PackageDef; }
	}
	string str() { return string("Program") + "(" + getString(ExternList) + "," + getString(PackageDef) + ")"; }
};


class VarDefExternAST : public decafAST {
	int Op;
public:
	VarDefExternAST(int op) : Op(op) {}
	~VarDefExternAST() { }
	string str() { return string("VarDef") + "(" + getType(Op) + ")"; }
};

class GenericAST : public decafAST {
	string Name;
public:
	GenericAST(string name) : Name(name) {}
	string str() { return Name; }
};

// Extern
class ExternAST : public decafAST {
	decafAST *LHS,*RHS;
	string Name;
public:
	ExternAST(string name, decafAST *lhs, decafAST *rhs) : Name(name), LHS(lhs), RHS(rhs) {}
	~ExternAST() { delete LHS; delete RHS; }
	string str() { return string("ExternFunction") + "(" + Name + "," + getString(LHS) + "," + getString(RHS) + ")"; }
};

class FieldDeclarationNoAssignAST : public decafAST {
	string Name;
	decafAST *LHS;
public: 
	FieldDeclarationNoAssignAST(string name, decafAST *lhs) : Name(name), LHS(lhs) {}
	~FieldDeclarationNoAssignAST() { delete LHS; }
	string str() { return string("FieldDecl") + "(" + Name + "," + getString(LHS) + "," + string("Scalar") + ")";  }
};

class FieldDeclarationAST : public decafAST {
	decafAST *LHS,*RHS;
	string Name;
public:
	FieldDeclarationAST(decafAST *lhs, string name, decafAST *rhs) : LHS(lhs), Name(name), RHS(rhs) {}
	~FieldDeclarationAST() { delete LHS; delete RHS; }
	string str() { return string("FieldDecl") + "(" + Name + "," + getString(LHS) + "," + getString(RHS) + ")";  }
};


class BoolAST : public decafAST {
	bool B;
public: 
	BoolAST(bool b) : B(b) {}
	string str() {
		if (B)
		{
			return string("BoolExpr") + "(" + "True" + ")";
		} else
		{
			return string("BoolExpr") + "(" + "False" + ")";
		}		
	} 
};

class NumberExprAST : public decafAST {
	int Val;
public:
	NumberExprAST(int val) : Val(val) {}
	string str() { return string("NumberExpr") + "(" + convertInt(Val) + ")"; }
};

class MethodDeclarationAST : public decafAST {
	string Name;
	decafAST *LHS1,*RHS1,*RHS2;
public:
	MethodDeclarationAST(string name, decafAST *lhs1,  decafAST *rhs1, decafAST *rhs2) : Name(name), LHS1(lhs1), RHS1(rhs1), RHS2(rhs2) {}
	~MethodDeclarationAST() { delete LHS1; delete RHS1; delete RHS2; }
	string str() { return string("Method") + "(" + Name + "," + getString(LHS1) + "," + getString(RHS1) + "," + getString(RHS2) + ")"; }
};

class MethodBlockAST : public decafAST {
	decafAST *LHS, *RHS;
public:
	MethodBlockAST(decafAST *lhs, decafAST *rhs) : LHS(lhs), RHS(rhs) {}
	~MethodBlockAST() { delete LHS; delete RHS; }
	string str() { return string("MethodBlock") + "(" + getString(LHS) + "," + getString(RHS) + ")"; }
};

class VarDefMethodBlockAST : public decafAST {
	int Op; // use the token value of the operator
	string Name;
public:
	VarDefMethodBlockAST(int op, string name) : Op(op), Name(name){}
	~VarDefMethodBlockAST() {  }
	string str() { return string("VarDef") + "(" + Name + "," + getType(Op) + ")"; }
};

class MethodCallAST : public decafAST {
	string Name;
	decafAST *AST;
public:
	MethodCallAST(string name, decafAST *ast) : Name(name), AST(ast) {}
	~MethodCallAST() { 
		if (AST != NULL) { delete AST; }
	}
	string str() { return string("MethodCall") + "(" + Name + "," + getString(AST) + ")"; }
};

/// StringConstAST - string constant
class StringConstAST : public decafAST {
	string StringConst;
public:
	StringConstAST(string s) : StringConst(s) {}
	string str() { return string("StringConstant") + "(" + "\"" + StringConst + "\"" + ")"; }

};


/// AssignVarAST - assign value to a variable
class AssignVarAST : public decafAST {
	string Name; // location to assign value
	decafAST *Value;
public:
	AssignVarAST(string name, decafAST *value) : Name(name), Value(value) {}
	~AssignVarAST() { 
		if (Value != NULL) { delete Value; }
	}
	string str() { return string("AssignVar") + "(" + Name + "," + getString(Value) + ")"; }
};

class BinaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *LHS, *RHS;
public:
	BinaryExprAST(int op, decafAST *lhs, decafAST *rhs) : Op(op), LHS(lhs), RHS(rhs) {}
	~BinaryExprAST() { delete LHS; delete RHS; }
	string str() { return string("BinaryExpr") + "(" + BinaryOpString(Op) + "," + getString(LHS) + "," + getString(RHS) + ")"; }
};

/// UnaryExprAST - Expression class for a unary operator.
class UnaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *Expr;
public:
	UnaryExprAST(int op, decafAST *expr) : Op(op), Expr(expr) {}
	~UnaryExprAST() { delete Expr; }
	string str() { return string("UnaryExpr") + "(" + UnaryOpString(Op) + "," + getString(Expr); }

};

/// VariableExprAST - Expression class for variables like "a".
class VariableExprAST : public decafAST {
	string Name;
public:
	VariableExprAST(string name) : Name(name) {}
	string str() { return string("VariableExpr") + "(" + Name + ")"; }
};

class ArrayLocExprAST : public decafAST {
	string Name;
	decafAST *AST;
public:
	ArrayLocExprAST(string name, decafAST *ast) : Name(name), AST(ast) {}
	~ArrayLocExprAST() { delete AST; }
	string str() { return string("ArrayLocExpr") + "(" + Name + "," + getString(AST) + ")"; }
};

class AssignArrayAST : public decafAST {
	string Name; // location to assign value
	decafAST *Value;
	decafAST *Expr;
public:
	AssignArrayAST(string name, decafAST *expr, decafAST *value) : Name(name), Value(value), Expr(expr) {}
	~AssignArrayAST() { 
		if (Value != NULL) { delete Value; }
	}
	string str() { return string("AssignArrayLoc") + "(" + Name + "," + getString(Expr) + "," + getString(Value) + ")"; }
};