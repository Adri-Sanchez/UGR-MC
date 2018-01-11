CXX = g++ -O2 -w -std=c++11

all:	terremotos

lex.yy.c:	mylex
	@flex mylex

terremotos:	lex.yy.c
	@$(CXX) $^ -o $@ -lfl

clean:
	@rm -f terremotos lex.yy.c IGN.html