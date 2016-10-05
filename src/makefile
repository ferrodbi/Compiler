#build an executable named analyzer from alex.l using flex
all:
	flex -o analyzer.c alex.l
	gcc -oanalyzer analyzer.c -lfl
	
clean: 
	$(RM) analyzer analyzer.c
	