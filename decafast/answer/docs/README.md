
Your documentation
------------------

Build the tree stuctrue in C++
Then print it out
helper functions
-getString
-commaList
-decafSttmtList
    -str() to print list
PackageAST
    -name
    -field list
    -method list

Look at the Decaf.asdl file and see how the package data structure is similar

could maybe use comma list instead of all the buildString functions

keep adding more

extend the Grammar in dacaf.y for all the different rules
everytime u add a new rule make a new call to one of the constructors



./runTests.sh

./decafast < a.decaf
Program(None,Package(QuickSort,None,None))

a.decaf
package QuickSort {

}





decadeStmtsList functions
    int size() { return stmts.size(); }
	void push_front(decafAST *e) { stmts.push_front(e); }
	void push_back(decafAST *e) { stmts.push_back(e); }
	string str() { return commaList<class decafAST *>(stmts); }


extern func print_string(string) void;

Program(ExternFunction(print_int,VoidType,VarDef(IntType)))





python3 zipout.py -r decafast
python3 check.py -l log


git add decafast.lex decafast.cc decafast.y docs/README.md


grep -r "Diff" log