%{
#include <iostream>
#include <string>
#include <map>
static std::map<std::string, int> vars;
inline void yyerror(const char *str) { std::cout << str << std::endl; }
int yylex();
%}

%union { int num; std::string *str; }

%token<num> NUMBER
%token<str> ID
%type<num> expression
%type<num> assignment

%right '='
%left '+' '-'
%left '*' '/'

%%

program: statement_list
        ;

statement_list: statement '\n'
    | statement_list statement '\n'
    ;

statement: assignment
    | expression ':' { std::cout << "Resultado Obtenido" << $1 << std::endl; }
    | error '\n' { yyerror("Error: Invalid Tokend "); yyerrok; }
    ;

assignment: ID '=' expression
    {
        printf("Assign %s = %d\n", $1->c_str(), $3);
        $$ = vars[*$1] = $3;
        delete $1;
    }
    | ID '=' { yyerror("Error: Missing expression after '='"); }
    ;

expression: NUMBER { $$ = $1; }
    | ID { 
        if (vars.find(*$1) == vars.end()) {
            yyerror(("Error: Undeclared variable " + *$1).c_str());
            $$ = 0;
        } else {
            $$ = vars[*$1];
        }
        delete $1;
    }
    | expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression {
        if ($3 == 0) {
            yyerror("Error: Division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | expression expression { yyerror("Error: Missing operator between expressions"); }
    ;

%%

int main() {
    yyparse();
    return 0;
}