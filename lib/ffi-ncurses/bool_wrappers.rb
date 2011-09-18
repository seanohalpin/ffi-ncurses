module FFI
  module NCurses
    module BoolWrappers
      def to_bool(bf)
        if bf == 0
          false
        else
          bf ? true : false
        end
      end
      def clearok(window_p1,bool2)
        _wrapped_clearok(window_p1,to_bool(bool2))
      end
      def idcok(window_p1,bool2)
        _wrapped_idcok(window_p1,to_bool(bool2))
      end
      def idlok(window_p1,bool2)
        _wrapped_idlok(window_p1,to_bool(bool2))
      end
      def immedok(window_p1,bool2)
        _wrapped_immedok(window_p1,to_bool(bool2))
      end
      def intrflush(window_p1,bool2)
        _wrapped_intrflush(window_p1,to_bool(bool2))
      end
      def keyok(int1,bool2)
        _wrapped_keyok(int1,to_bool(bool2))
      end
      def keypad(window_p1,bool2)
        _wrapped_keypad(window_p1,to_bool(bool2))
      end
      def leaveok(window_p1,bool2)
        _wrapped_leaveok(window_p1,to_bool(bool2))
      end
      def meta(window_p1,bool2)
        _wrapped_meta(window_p1,to_bool(bool2))
      end
      def mouse_trafo(int_p1,int_p2,bool3)
        _wrapped_mouse_trafo(int_p1,int_p2,to_bool(bool3))
      end
      def nodelay(window_p1,bool2)
        _wrapped_nodelay(window_p1,to_bool(bool2))
      end
      def notimeout(window_p1,bool2)
        _wrapped_notimeout(window_p1,to_bool(bool2))
      end
      def scrollok(window_p1,bool2)
        _wrapped_scrollok(window_p1,to_bool(bool2))
      end
      def syncok(window_p1,bool2)
        _wrapped_syncok(window_p1,to_bool(bool2))
      end
      def use_env(bool1)
        _wrapped_use_env(to_bool(bool1))
      end
      def use_extended_names(bool1)
        _wrapped_use_extended_names(to_bool(bool1))
      end
      def wmouse_trafo(window_p1,int_p2,int_p3,bool4)
        _wrapped_wmouse_trafo(window_p1,int_p2,int_p3,to_bool(bool4))
      end
    end
  include BoolWrappers
  extend BoolWrappers
  end
end
