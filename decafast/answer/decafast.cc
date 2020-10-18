
#include "default-defs.h"
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
	string str() { return string("Number") + "(" + convertInt(Val) + ")"; }
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
	string str() { return string("VarDef") + "(" + getType(Op) + ")"; }
};
