#include <iostream>
#include <cstring>
using namespace std;

int readint()
{
    char c;
    int result = 0;
    while( cin.get(c) && (c == ' ' || c == '\r' || c == '\n')); //去除前导空白
    do
    {
        result *= 10;
        result += c - '0';
    } while(  cin.get(c) && c != ' ' && c != '\r' && c != '\n' ); //读到空白停止
    return result;
}

void printint( int a )
{
    char buf[12];
    memset( buf, 0, sizeof(buf));

    int remainder = 0;
    int quotient = 1;
    int significant_bit = 0;
    while( quotient != 0 )
    {
        remainder = a % 10;
        quotient = a / 10;
        buf[ significant_bit ] = remainder + '0';
        significant_bit++;
        a = quotient;
    }
    do
    {
        significant_bit--;
        cout << buf[significant_bit];
    } while ( significant_bit != 0 );
    cout <<endl;
}

int main()
{
    printint( readint() );
}