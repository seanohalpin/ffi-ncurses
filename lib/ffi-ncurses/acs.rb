module FFI
  module NCurses
    module ACS
      def define_acs(name, char)
        const_set name, acs_map[char[0].ord]
      end

      # We have to define these dynamically as =acs_map= is not initialized until =init_scr= has been called
      def define_acs_constants
        define_acs :ACS_ULCORNER, 'l' # upper left corner
        define_acs :ACS_LLCORNER, 'm' # lower left corner
        define_acs :ACS_URCORNER ,'k' # upper right corner
        define_acs :ACS_LRCORNER ,'j' # lower right corner
        define_acs :ACS_LTEE     ,'t' # tee pointing right
        define_acs :ACS_RTEE     ,'u' # tee pointing left
        define_acs :ACS_BTEE     ,'v' # tee pointing up
        define_acs :ACS_TTEE     ,'w' # tee pointing down
        define_acs :ACS_HLINE    ,'q' # horizontal line
        define_acs :ACS_VLINE    ,'x' # vertical line
        define_acs :ACS_PLUS     ,'n' # large plus or crossover
        define_acs :ACS_S1       ,'o' # scan line 1
        define_acs :ACS_S9       ,'s' # scan line 9
        define_acs :ACS_DIAMOND  ,'`' # diamond
        define_acs :ACS_CKBOARD  ,'a' # checker board (stipple)
        define_acs :ACS_DEGREE   ,'f' # degree symbol
        define_acs :ACS_PLMINUS  ,'g' # plus/minus
        define_acs :ACS_BULLET   ,'~' # bullet
        # Teletype 5410v1 symbols begin here
        define_acs :ACS_LARROW   ,',' # arrow pointing left
        define_acs :ACS_RARROW   ,'+' # arrow pointing right
        define_acs :ACS_DARROW   ,'.' # arrow pointing down
        define_acs :ACS_UARROW   ,'-' # arrow pointing up
        define_acs :ACS_BOARD    ,'h' # board of squares
        define_acs :ACS_LANTERN  ,'i' # lantern symbol
        define_acs :ACS_BLOCK    ,'0' # solid square block

        # These aren't documented, but a lot of System Vs have them anyway
        # (you can spot pprryyzz{{||}} in a lot of AT&T terminfo strings).
        # The ACS_names may not match AT&T's, our source didn't know them.

        define_acs :ACS_S3       ,'p' # scan line 3
        define_acs :ACS_S7       ,'r' # scan line 7
        define_acs :ACS_LEQUAL   ,'y' # less/equal
        define_acs :ACS_GEQUAL   ,'z' # greater/equal
        define_acs :ACS_PI       ,'{' # Pi
        define_acs :ACS_NEQUAL   ,'|' # not equal
        define_acs :ACS_STERLING ,'}' # UK pound sign

        # Line drawing ACS names are of the form ACS_trbl, where t is the top, r
        # is the right, b is the bottom, and l is the left.  t, r, b, and l might
        # be B (blank), S (single), D (double), or T (thick).  The subset defined
        # here only uses B and S.
        const_set :ACS_BSSB, ACS_ULCORNER
        const_set :ACS_SSBB, ACS_LLCORNER
        const_set :ACS_BBSS, ACS_URCORNER
        const_set :ACS_SBBS, ACS_LRCORNER
        const_set :ACS_SBSS, ACS_RTEE
        const_set :ACS_SSSB, ACS_LTEE
        const_set :ACS_SSBS, ACS_BTEE
        const_set :ACS_BSSS, ACS_TTEE
        const_set :ACS_BSBS, ACS_HLINE
        const_set :ACS_SBSB, ACS_VLINE
        const_set :ACS_SSSS, ACS_PLUS
      end
    end
    extend ACS
  end
end
