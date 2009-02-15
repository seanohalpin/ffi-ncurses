module FFI
  module NCurses
    module WinStruct
      NCURSES_SIZE_T = :short
      NCURSES_ATTR_T = :int
      NCURSES_COLOR_T = :short
      NCURSES_CH_T = :short

      CHTYPE = :ulong
      CCHARW_MAX = 5

      BOOLEAN = :uchar              # sizeof(bool) == 1

      WCHAR_T = :ushort
      
      #   class CCharT < FFI::Struct
      #     layout \
      #     :attr, NCURSES_ATTR_T,
      #     :chars, [WCHAR_T, CCHARW_MAX]
      #   end

      class PDat < FFI::Struct
        layout \
        :_pad_y, NCURSES_SIZE_T,
        :_pad_x, NCURSES_SIZE_T,
        :_pad_top, NCURSES_SIZE_T,
        :_pad_left, NCURSES_SIZE_T,
        :_pad_bottom, NCURSES_SIZE_T,
        :_pad_right, NCURSES_SIZE_T
      end

      class WinSt < FFI::Struct
        layout \
        :_cury, NCURSES_SIZE_T,
        :_curx, NCURSES_SIZE_T,
        :_maxy, NCURSES_SIZE_T,
        :_maxx, NCURSES_SIZE_T,
        :_begy, NCURSES_SIZE_T,
        :_begx, NCURSES_SIZE_T,
        :_flags, :short,
        :_attrs, NCURSES_ATTR_T,
        :_bkgd, CHTYPE,
        :_notimeout, BOOLEAN,
        :_clear, BOOLEAN,
        :_leaveok, BOOLEAN,
        :_scroll, BOOLEAN,
        :_idlok, BOOLEAN,
        :_idcok, BOOLEAN,
        :_immed, BOOLEAN,
        :_sync, BOOLEAN,
        :_use_keypad, BOOLEAN,
        :_delay, :int,

        # struct ldat *_line
        :_line, :pointer,

        :_regtop, NCURSES_SIZE_T,
        :_regbottom, NCURSES_SIZE_T,

        # why x,y when everything else is y,x?
        :_parx, :int,
        :_pary, :int,
        :_parent, :pointer          # WINDOW

        # don't know how to include nested Struct yet
        #     :_pad, PDat,
        
        #     :_yoffset, NCURSES_SIZE_T
        #     :_bkgrnd, CCharT
      end

      def _win(win, member)
        win && WinSt.new(win)[member]
      end
      private :_win
      
      # extensions - not in X/Open
      def is_cleared(win)
        _win(win, :_clear)
      end
      def is_idcok(win)
        _win(win, :_idcok)
      end
      def is_idlok(win)
        _win(:win, :_idlok)
      end
      def is_immedok(win)
        _win(win, :_immed)
      end
      def is_keypad(win)
        _win(win, :_use_keypad)
      end
      def is_leaveok(win)
        _win(win, :_leaveok) || ERR
      end
      def is_nodelay(win)
        _win(win, :_delay) == 0 ? FFI::NCurses::TRUE : FFI::NCurses::FALSE
      end
      def is_notimeout(win)
        _win(win, :_notimeout)
      end
      def is_scrollok(win)
        _win(win, :_scroll)
      end
      def is_syncok(win)
        _win(win, :_sync)
      end
      def wgetparent(win)
        _win(win, :_parent)
      end
      def wgetscrreg(win, t, b)
        # ((win) ? (*(t) = (win)->_regtop, *(b) = (win)->_regbottom, OK) : ERR)
        # not entirely satisfactory - no error return
        # should I raise an exception?
        if win
          win_st = WinSt.new(win)
          [win_st[:_regtop], win_st[:_regbottom]]
        else
          #raise ArgumentError, "win is nil"
          nil
        end
      end
    end

    # struct _win_st
    # {
    # 	NCURSES_SIZE_T _cury, _curx; /* current cursor position */

    # 	/* window location and size */
    # 	NCURSES_SIZE_T _maxy, _maxx; /* maximums of x and y, NOT window size */
    # 	NCURSES_SIZE_T _begy, _begx; /* screen coords of upper-left-hand corner */

    # 	short   _flags;		/* window state flags */

    # 	/* attribute tracking */
    # 	attr_t  _attrs;		/* current attribute for non-space character */
    # 	chtype  _bkgd;		/* current background char/attribute pair */

    # 	/* option values set by user */
    # 	bool	_notimeout;	/* no time out on function-key entry? */
    # 	bool	_clear;		/* consider all data in the window invalid? */
    # 	bool	_leaveok;	/* OK to not reset cursor on exit? */
    # 	bool	_scroll;	/* OK to scroll this window? */
    # 	bool	_idlok;		/* OK to use insert/delete line? */
    # 	bool	_idcok;		/* OK to use insert/delete char? */
    # 	bool	_immed;		/* window in immed mode? (not yet used) */
    # 	bool	_sync;		/* window in sync mode? */
    # 	bool	_use_keypad;	/* process function keys into KEY_ symbols? */
    # 	int	_delay;		/* 0 = nodelay, <0 = blocking, >0 = delay */

    # 	struct ldat *_line;	/* the actual line data */

    # 	/* global screen state */
    # 	NCURSES_SIZE_T _regtop;	/* top line of scrolling region */
    # 	NCURSES_SIZE_T _regbottom; /* bottom line of scrolling region */

    # 	/* these are used only if this is a sub-window */
    # 	int	_parx;		/* x coordinate of this window in parent */
    # 	int	_pary;		/* y coordinate of this window in parent */
    # 	WINDOW	*_parent;	/* pointer to parent if a sub-window */

    # 	/* these are used only if this is a pad */
    # 	struct pdat
    # 	{
    # 	    NCURSES_SIZE_T _pad_y,      _pad_x;
    # 	    NCURSES_SIZE_T _pad_top,    _pad_left;
    # 	    NCURSES_SIZE_T _pad_bottom, _pad_right;
    # 	} _pad;

    # 	NCURSES_SIZE_T _yoffset; /* real begy is _begy + _yoffset */

    # #ifdef _XOPEN_SOURCE_EXTENDED
    # 	cchar_t  _bkgrnd;	/* current background char/attribute pair */
    # #endif
    # };
  end
end
