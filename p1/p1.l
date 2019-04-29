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

"array"      {token(KW_ARR);}
"boolean"    {token(KW_BOOL);}
"begin"      {token(KW_BEGIN);}
"break"      {token(KW_BREAK);}
"char"       {token(KW_CHAR);}
"case"       {token(KW_CASE);}
"const"      {token(KW_CONST);}
"continue"   {token(KW_CONTINUE);}
"do"         {token(KW_DO);}
"else"       {token(KW_ELSE);}
"end"        {token(KW_END);}
"exit" 	     {token(KW_EXIT);}
"false"	     {token(KW_FALSE);}
"for"  	     {token(KW_FOR);}
"fn" 	     {token(KW_FN);}
"if" 	     {token(KW_IF);}
"in"         {token(KW_IN);}
"integer"   {token(KW_INT);}
"loop"       {token(KW_LOOP);}
"module"     {token(KW_MODULE);}
"print"      {token(KW_PRINT);}
"println"    {token(KW_PRINTLN);}
"procedure"  {token(KW_PROCE);}
"repeat"     {token(KW_REPEAT);}
"return"     {token(KW_RETURN);}
"real"       {token(KW_REAL);}
"string"     {token(KW_STRING);}
"record"     {token(KW_RECORD);}
"then"       {token(KW_THEN);}
"true"       {token(KW_TURE);}
"type"       {token(KW_TYPE);}
"use"        {token(KW_USE);}
"util"       {token(KW_UTIL);}
"var"        {token(KW_VAR);}
"while"      {token(KW_WHILE);}

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
