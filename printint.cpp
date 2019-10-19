#include <iostream>
#include <cstring>
using namespace std;

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
    int a;
    cin >> a;
    printint(a);
}