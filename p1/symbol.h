#include <string>
#include <vector>
using namespace std;

class Symbol {
public:
	Symbol();
	int findID(string s);
	int insert(string s);
	void dump();
	vector<string> ID;
};
