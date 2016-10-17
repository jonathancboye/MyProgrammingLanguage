%{
#include <iostream>
#include <cstdlib>
#include <string>
#include <unordered_map>
#include <iterator>
#include <time.h>
#include <stdlib.h>
#include "node.h"
using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *str);
node_t *result;
unordered_map<string, node_t*> vars;
%}

%union {
    int num;
    char *str;
    struct _node_t *node;
}
			
%token	<num>		NUM
%token	<str>		IV
%token	<str>		STRV
%token	<str>		STR
%token	<str>		OBJ
%token			RANDCHAR	
%token			ADD
%token			SUB
%token			MUL
%token 			DIV
%token			LT
%token			ASSIGN
%token			SEMI
%token			LP
%token			RP
%token			COLON
%token			QUOTE
%token			QUESTION
%token                  IF
%token			LB
%token			RB
%token			WHILE
%token			ELSE
%token			PRINT
%token                  NEW
%token			COMMA
%token			DOT
			
%type	<node>		expr
%type	<node>		term
%type	<node>		factor
%type	<node>		statement
%type	<node>		sentence
%type	<node>		string
%type	<node>		strings
%type	<str>		string_var
%type	<str>		integer_var
%type	<str>		obj_var
%%
statement:	IF LP expr RP LB statement SEMI RB ELSE LB statement SEMI RB
		{
		    $$ = makeNode($3, $6, $11, if_statement);
		    result = $$;
		}
	|	WHILE LP expr RP LB statement RB
		{
		    $$ = makeNode($3, NULL, $6, while_loop);
		    result = $$;
		}
	|	PRINT strings
		{
		    $$ = makeNode($2, NULL, NULL, print);
		    result = $$;
		}
	|	PRINT expr
		{
		    $$ = makeNode($2, NULL, NULL, print_int);
		    result = $$;
		}
	|	statement SEMI statement
		{
		    $$ = makeNode($1, NULL, $3, do_statements);
		    result = $$;
		}
	|	sentence 
		{
		    $$ = $1;
		    $$ = result;
		}
	|	expr
		{
		    $$ = $1;
		    $$ = result;
		}
	|	obj_var
		{
		    $$ = vars[$1];
		    result = $$;
		}
		;

sentence:	integer_var ASSIGN expr
		{
		  auto it = vars.find($1);
		  $$ = makeNode(vars[$1], NULL, $3, assignment);
		  result = $$;
		}
	|	string_var ASSIGN strings
		{
		  auto it = vars.find($1);
		  $$ = makeNode(vars[$1], NULL, $3, str_assignment);
		  result = $$;
		}
	|	obj_var DOT IV ASSIGN expr
		{
		    auto it = vars.find($1);
		    if(it != vars.end()){
		      $$ = makeNode(vars[$1], makeStrNode($3), $5, addIntVarNode);
		      result = $$;
		    }
		    else{
		      yyerror("Object was not declared");
		    }
		}
	|	obj_var DOT STRV ASSIGN strings
		{
		    auto it = vars.find($1);
		    if(it != vars.end()){
		      $$ = makeNode(vars[$1], makeStrNode($3), $5, addStrVarNode);
		      result = $$;
		    }
		    else{
		      yyerror("Object was not declared");
		    }
		}
	|	strings
		{
		    $$ = $1;
		    result = $$;
		}
		;

strings:	strings ADD string
		{
		    $$ = makeNode($1, NULL, $3, str_concat);
		    result = $$;
		}
	|	string
		{
		    $$ = $1;
		    result = $$;
		}
		;

string:		QUOTE STR QUOTE
		{
		    $$ = makeStrNode($2);
		}
	|	string_var
		{
		    $$ = vars[$1];
		}
	|	RANDCHAR
		{
		    $$ = makeRandStrNode();
		}
	|	obj_var DOT STRV
		{
		    auto it = vars.find($1);
		    if(it != vars.end()){
			$$ = makeNode(vars[$1], NULL, makeStrNode($3), getStrVarNode);
			result = $$;
		    }
		    else{
			yyerror("Class not defined");
		    }
		}
		;

expr: 		term ADD expr 
		{
		    $$ = makeNode($1, NULL, $3, add);
		    result = $$;
		}
	| 	term SUB expr
		{
		    $$ = makeNode($1, NULL, $3, subtract);
		    result = $$;
		}
	| 	term LT expr
		{
		    $$ = makeNode($1, NULL, $3, less_than);
		    result = $$;
		}
	| 	term 
		{
		    $$ = $1;
		    result = $$;
		}
		;		

term: 		factor MUL term
		{
		    $$ = makeNode($1, NULL, $3, multiply);
		    result = $$;
		}
	|	factor DIV term
		{
		    $$ = makeNode($1, NULL, $3, divide);
		    result = $$;
		}
	|	factor
		{
		    $$ = $1;
		    result = $$;
		}
		;

factor:		NUM
		{
		    $$ = makeIntNode($1);
		}
	|	integer_var
		{
		    $$ = vars[$1];
		}
	|	obj_var DOT IV
		{
		    auto it = vars.find($1);
		    if(it != vars.end()){
			$$ = makeNode(vars[$1], NULL, makeStrNode($3), getIntVarNode);
			result = $$;
		    }
		    else{
			yyerror("Class not defined");
		    }
		}
		;

integer_var:	IV
		{
		  unordered_map<string, node_t*>::iterator it = vars.find($1);
		  if(it == vars.end()) {
		    vars.insert({$1, makeIntNode(0)});
		  }
		  $$ = $1;
		}
		;

string_var:	STRV
		{
		  unordered_map<string, node_t*>::iterator it = vars.find($1);
		  if(it == vars.end()) {
		    vars.insert({$1, makeIntNode(0)});
		  }
		  $$ = $1;
		}
		;

obj_var:	OBJ ASSIGN LP QUOTE STR QUOTE RP
		{
		  unordered_map<string, node_t*>::iterator it = vars.find($1);
		  if(it == vars.end()) {
		      vars.insert({$1, makeClassNode($5, NULL)});
		  }
		  $$ = $1;
		}
	|	OBJ ASSIGN LP QUOTE STR QUOTE COMMA OBJ RP
		{
		  unordered_map<string, node_t*>::iterator subit = vars.find($1);
		  unordered_map<string, node_t*>::iterator supit = vars.find($8);
		  if(subit == vars.end() && supit != vars.end()) {
		      vars.insert({$1, makeClassNode($5, vars[$8]->obj)});
		  }
		  else{
		    yyerror("Class not declared");
		  }
		  $$ = $1;
		}
	|	OBJ
		{
		    $$ = $1;
		}
	
		;

%%

int main()
{
  //FILE *myfile = fopen("test_program2.txt", "r");

    srand(time(NULL));

    /* if(!myfile) { */
    /* 	cout << "COULD NOT FIND FILE" << endl; */
    /* 	return -1; */
    /* } */

    yyin = stdin;

    while(!feof(yyin)){
      yyparse();
    }

    fclose(myfile);

    evaluate(result);

    /* //Print out variables */
    /* unordered_map<string,node_t*>::iterator it; */
    /* cout << "====" << "VARS" << "====" << endl; */
    /* for(auto& p: vars) */
    /*   { */
    /* 	  cout << p.first << " " << p.second->value << endl; */
    /*   } */
    return 0;
}

void yyerror(const char *str) {
    cout << "ERROR OCCURED SOMEWHERE: " << endl;
    cout << str << endl;
    exit(-1);
}
