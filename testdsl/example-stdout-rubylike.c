#include <ncurses.h>

#define then {
#define end }
#define c_if if
#define nloop(n) for(i = 0; i < n; i++)

int main(int argc, char *argv[])
{
  int i;

  #include "eg1.src"

  return(0);
}
