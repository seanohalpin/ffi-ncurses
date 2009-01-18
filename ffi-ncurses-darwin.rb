module NCurses
  module Darwin
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
