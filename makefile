v = 1
CC = g++ --std=c++11
carp: flex-bison.tab.c lex.yy.c node.c
	$(CC) $^ -ll -o $@

flex-bison.tab.c flex-bison.tab.h: flex-bison.y node.h
	bison -d $<

lex.yy.c: flex-bison.l flex-bison.tab.h 
	flex $<

clean:
	rm -f *~ *# *.o *.tab.* lex.yy.c
