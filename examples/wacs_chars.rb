require 'ffi-ncurses'

include FFI::NCurses

def main
  begin
    initscr

    def addwch(ch)
      cchar = WinStruct::CCharT.new
      cchar[:chars][0] = ch
      # cchar[:attr] = WA_BOLD
      wadd_wch(stdscr, cchar)
    end

    addstr("Upper left corner           "); addwch(WACS_ULCORNER); addstr("\n");
    addstr("Lower left corner           "); addwch(WACS_LLCORNER); addstr("\n");
    addstr("Lower right corner          "); addwch(WACS_LRCORNER); addstr("\n");
    addstr("Tee pointing right          "); addwch(WACS_LTEE); addstr("\n");
    addstr("Tee pointing left           "); addwch(WACS_RTEE); addstr("\n");
    addstr("Tee pointing up             "); addwch(WACS_BTEE); addstr("\n");
    addstr("Tee pointing down           "); addwch(WACS_TTEE); addstr("\n");
    addstr("Horizontal line             "); addwch(WACS_HLINE); addstr("\n");
    addstr("Vertical line               "); addwch(WACS_VLINE); addstr("\n");
    addstr("Large Plus or cross over    "); addwch(WACS_PLUS); addstr("\n");
    addstr("Scan Line 1                 "); addwch(WACS_S1); addstr("\n");
    addstr("Scan Line 3                 "); addwch(WACS_S3); addstr("\n");
    addstr("Scan Line 7                 "); addwch(WACS_S7); addstr("\n");
    addstr("Scan Line 9                 "); addwch(WACS_S9); addstr("\n");
    addstr("Diamond                     "); addwch(WACS_DIAMOND); addstr("\n");
    addstr("Checker board (stipple)     "); addwch(WACS_CKBOARD); addstr("\n");
    addstr("Degree Symbol               "); addwch(WACS_DEGREE); addstr("\n");
    addstr("Plus/Minus Symbol           "); addwch(WACS_PLMINUS); addstr("\n");
    addstr("Bullet                      "); addwch(WACS_BULLET); addstr("\n");
    addstr("Arrow Pointing Left         "); addwch(WACS_LARROW); addstr("\n");
    addstr("Arrow Pointing Right        "); addwch(WACS_RARROW); addstr("\n");
    addstr("Arrow Pointing Down         "); addwch(WACS_DARROW); addstr("\n");
    addstr("Arrow Pointing Up           "); addwch(WACS_UARROW); addstr("\n");
    addstr("Board of squares            "); addwch(WACS_BOARD); addstr("\n");
    addstr("Lantern Symbol              "); addwch(WACS_LANTERN); addstr("\n");
    addstr("Solid Square Block          "); addwch(WACS_BLOCK); addstr("\n");
    addstr("Less/Equal sign             "); addwch(WACS_LEQUAL); addstr("\n");
    addstr("Greater/Equal sign          "); addwch(WACS_GEQUAL); addstr("\n");
    addstr("Pi                          "); addwch(WACS_PI); addstr("\n");
    addstr("Not equal                   "); addwch(WACS_NEQUAL); addstr("\n");
    addstr("UK pound sign               "); addwch(WACS_STERLING); addstr("\n");

    refresh
    getch
  rescue => e
    endwin
    raise
  ensure
    endwin
  end
end

main
