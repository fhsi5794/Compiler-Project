%{
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include "symbol.h"
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n", #t);}
#define tokenNum(t,i) {LIST; printf("<%s:%s>\n",#t,i);}
#define tokenString(t,s) {		\
	LIST; 				\
	printf("<%s:%s>\n",#t,s);	\
	tempStr[0] = '\0';		\
	BEGIN(INITIAL);			\
	}

#define MAX_LINE_LENG 256

int linenum = 1;
int comms = 0;
char buf[MAX_LINE_LENG];
char tempStr[MAX_LINE_LENG];
Symbol symbol = Symbol() ;
%}

dig        [0-9]
digs       [0-9]+
integer    {digs}
plain_real {digs}"."{digs}
expreal    {digs}"."{digs}[Ee][+-]?{digs}
real	   {plain_real}|{expreal}|[+-]?{digs}[Ee][+-]?{digs}

letter  [a-zA-Z]
letters [a-zA-Z]+
ID      {letter}({letter}|{dig})*

%x DO_STRING
%x DO_LINE_COMM
%x DO_COMM

%%

"("     {token('(');}
")"     {token(')');}
","     {token(',');}
":"     {token(':');}
"."     {token('.');}
";"     {token(';');}
"["     {token('[');}
"]"     {token(']');}
"{"     {token('}');}

"+"     {token('+');}
"-"     {token('-');}
"*"     {token('*');}
"/"     {token('/');}
"%"     {token('%');}
"<"     {token('<');}
">"     {token('>');}
"="     {token('=');}
"<="    {token(OP_LESS_EQUAL);}
">="    {token(OP_GREAT_EQUAL);}
"<>"    {token(OP_NOT_EQUAL);}
"&&"    {token(OP_AND);}
"||"    {token(OP_OR);}
"~"     {token('~');}
":="    {token(OP_ASSIGN);}

[Aa][Rr][Rr][Aa][Yy]  		   		 {token(KW_ARR);}
[Bb][Oo][Oo][Ll][Ee][Aa][Nn]    	 {token(KW_BOOL);}
[Bb][Ee][Gg][Ii][Nn]   		    	 {token(KW_BEGIN);}
[Br][Rr][Ee][Aa][Kk]      			 {token(KW_BREAK);}
[Cc][Hh][Aa][Rr]       				 {token(KW_CHAR);}
[Cc][Aa][Ss][Ee]    		    	 {token(KW_CASE);}
[Cc][Oo][Nn][Ss][Tt]     	    	 {token(KW_CONST);}
[Cc][Oo][Nn][Tt][Ii][Nn][Uu][Ee]     {token(KW_CONTINUE);}
[Dd][Oo]     					     {token(KW_DO);}
[Ee][Ll][Ss][Ee]    			     {token(KW_ELSE);}
[Ee][Nn][Dd]      				     {token(KW_END);}
[Ee][Xx][Ii][Tt]	   			     {token(KW_EXIT);}
[Ff][Aa][Ll][Ss][Ee]	     		 {token(KW_FALSE);}
[Ff][Oo][Rr] 	     				 {token(KW_FOR);}
[Ff][Nn] 	  					     {token(KW_FN);}
[Ii][Ff] 						     {token(KW_IF);}
[Ii][Nn]						     {token(KW_IN);}
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]   		 {token(KW_INT);}
[Ll][Oo][Oo][Pp]     			     {token(KW_LOOP);}
[Mm][Oo][Dd][Uu][Ll][Ee]   			 {token(KW_MODULE);}
[Pp][Rr][Ii][Nn][Tt]   				 {token(KW_PRINT);}
[Pp][Rr][Ii][Nn][Tt][Ll][Nn]    	 {token(KW_PRINTLN);}
[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee] {token(KW_PROCE);}
[Rr][Ee][Pp][Ee][Aa][Tt]  		     {token(KW_REPEAT);}
[Rr][Ee][Tt][Uu][Rr][Nn]     		 {token(KW_RETURN);}
[Rr][Ee][Aa][Ll]    			     {token(KW_REAL);}
[Ss][Tt][Rr][Ii][Nn][Gg]   		     {token(KW_STRING);}
[Rr][Ee][Cc][Oo][Rr][Dd]     		 {token(KW_RECORD);}
[Tt][Hh][Ee][Nn]    			     {token(KW_THEN);}
[Tt][Rr][Uu][Ee]       				 {token(KW_TURE);}
[Tt][Yy][Pp][Ee]     			     {token(KW_TYPE);}
[Uu][Ss][Ee]      				     {token(KW_USE);}	
[Uu][Tt][Ii][Ll]    			     {token(KW_UTIL);}
[Vv][Aa][Rr]     		 		     {token(KW_VAR);}
[Ww][Hh][Ii][Ll][Ee]      			 {token(KW_WHILE);}

{ID}	   {
		tokenString(ID,yytext);
		std::string str(yytext,yytext+strlen(yytext));
		if(symbol.insert(str)==-1);
	   }
{integer}  {tokenNum(INTEGER,yytext);}
{real}     {tokenNum(REAL,yytext);}

\"	{
		LIST;
		BEGIN(DO_STRING);
	}

<DO_STRING>\"	{tokenString(STRING,tempStr);}
<DO_STRING>\n	{
			LIST;
			printf("%-4d: %s", linenum++, buf); 
			buf[0]='\0';
			strcat(tempStr, "\n");
		}
<DO_STRING>\"\" {
			LIST;
			strcat(tempStr, "\"");
		}
<DO_STRING>.    {
			LIST;
			strcat(tempStr, yytext);
		}
"//"	{
		LIST;
		BEGIN(DO_LINE_COMM);
	}

<DO_LINE_COMM>\n   {
		   	LIST;
			printf("%-4d: %s", linenum++, buf); 
			buf[0]='\0';
			BEGIN(INITIAL);
		    }

<DO_LINE_COMM>.      {LIST;}

"(*"	{
		LIST;
		comms++;
		BEGIN(DO_COMM);
	}

<DO_COMM>"*)"	{
			LIST;
			comms--;
			if(comms == 0)
				BEGIN(INITIAL);
		}

<DO_COMM>"(*"	{
			LIST;
			comms++;
		}

<DO_COMM>\n	{
			LIST;
			printf("%-4d: %s", linenum++, buf);
			buf[0]='\0';
		}

<DO_COMM>.	{LIST;}		    	

\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%
int main(int argc, char *argv[]){
	yylex();
	fflush(yyout);
	symbol.dump();
	exit(0);
}
