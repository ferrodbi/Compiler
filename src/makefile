#build an executable named analyzer from alex.l using flex
all:
	bison -d -o asin.c asin.y	
	flex -o alex.c alex.l
	gcc -o compilador alex.c asin.c -lfl
	#gcc -oanalyzer analyzer.c -lfl
	
clean: 
	$(RM) asin.c alex.c compilador