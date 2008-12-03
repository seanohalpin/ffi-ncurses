#include <ncurses.h>

int main(int argc, char *argv[])
{
  initscr();
  addstr("Hello World");
  refresh();
  if(argc < 1)
    {
      (void)getch();
    }
  endwin();
  return(0);
}
