CXX = g++ -O2 -w -std=c++11

all:	IGNViewer

lex.yy.c:	mylex.l
	@flex mylex.l

IGNViewer:	lex.yy.c
	@$(CXX) $^ -o $@ -lfl

clean:
	@rm -f IGNViewer lex.yy.c IGN.html
