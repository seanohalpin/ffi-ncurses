# typedef struct panel
# {
#   WINDOW *win;
#   struct panel *below;
#   struct panel *above;
#   NCURSES_CONST void *user;
# } PANEL;

module FFI
  module NCurses
    module PanelStruct
      class Panel < FFI::Struct
        layout \
        :win, :pointer,   # WINDOW*
        :below, :pointer, # PANEL*
        :above, :pointer, # PANEL*
        :user, :pointer   # void*
      end
    end
  end
end
