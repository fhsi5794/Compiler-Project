CC = g++
LEX = flex
LEX_FILENAME = p1.l
OUTPUT_FILENAME = p1.out
OTHER_SOURCE = symbol.cpp

$(OUTPUT_FILENAME): clean lex.yy.cpp
	$(CC) -O lex.yy.cpp -ll $(OTHER_SOURCE) -o $(OUTPUT_FILENAME)
	rm -f lex.yy.cpp *.o

lex.yy.cpp: $(LEX_FILENAME)
	$(LEX) -o lex.yy.cpp $(LEX_FILENAME)

clean:
	rm -f lex.yy.cpp *.o *.out
