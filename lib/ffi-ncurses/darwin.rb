module FFI
  module NCurses
    module Darwin
      include FFI::NCurses::WinStruct

      # translated from Mac OSX 10.4 ('Tiger') /usr/include/ncurses.h
      def getattrs(win)
        win_st = WinSt.new(win)
        win ? win_st[:_attrs] : A_NORMAL
      end
      def getcurx(win)
        win_st = WinSt.new(win)
        win ? win_st[:_curx] : ERR
      end
      def getcury(win)
        win_st = WinSt.new(win)
        win ? win_st[:_cury] : ERR
      end
      def getbegx(win)
        win_st = WinSt.new(win)
        win ? win_st[:_begx] : ERR
      end
      def getbegy(win)
        win_st = WinSt.new(win)
        win ? win_st[:_begy] : ERR
      end
      def getmaxx(win)
        win_st = WinSt.new(win)
        win ? win_st[:_maxx] + 1 : ERR
      end
      def getmaxy(win)
        win_st = WinSt.new(win)
        win ? win_st[:_maxy] + 1 : ERR
      end
      def getparx(win)
        win_st = WinSt.new(win)
        win ? win_st[:_parx] : ERR
      end
      def getpary(win)
        win_st = WinSt.new(win)
        win ? win_st[:_pary] : ERR
      end
    end
  end
end
