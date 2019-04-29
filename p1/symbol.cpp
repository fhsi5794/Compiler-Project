#include<iostream>
#include <string>
#include <vector>
#include"symbol.h"

using namespace std;

Symbol::Symbol()
{
	ID.resize(0);
}

int Symbol::findID(string s)
{
	for(int i=0;i<ID.size();i++)
		if(ID[i].compare(s)==0)	return i;
	return -1;

}

int Symbol::insert(string s)
{
	if(findID(s)!=-1)	return -1;
	else ID.push_back(s);
	return 1;
}

void Symbol::dump()
{
	cout<<endl<<"Symbol Table:"<<endl;
	for(int i=0;i<ID.size();i++)
		cout<<ID[i]<<endl;
}
