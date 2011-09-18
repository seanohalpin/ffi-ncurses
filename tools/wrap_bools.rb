functions = [
 [:clearok, [:window_p, :bool], :int],
 [:idcok, [:window_p, :bool], :void],
 [:idlok, [:window_p, :bool], :int],
 [:immedok, [:window_p, :bool], :void],
 [:intrflush, [:window_p, :bool], :int],
 [:keyok, [:int, :bool], :int],
 [:keypad, [:window_p, :bool], :int],
 [:leaveok, [:window_p, :bool], :int],
 [:meta, [:window_p, :bool], :int],
 [:mouse_trafo, [:int_p, :int_p, :bool], :bool],
 [:nodelay, [:window_p, :bool], :int],
 [:notimeout, [:window_p, :bool], :int],
 [:scrollok, [:window_p, :bool], :int],
 [:syncok, [:window_p, :bool], :int],
 [:use_env, [:bool], :void],
 [:use_extended_names, [:bool], :int],
 [:wmouse_trafo, [:window_p, :int_p, :int_p, :bool], :bool],
]

def format_params(params)
  if params.size > 0
    counter = 0
    "("+ params.map{ |x| "#{x}#{counter += 1}" }.join(',') + ")"
  else
    ""
  end
end

def format_args(params)
  if params.size > 0
    counter = 0
    "(" + params.map{ |x|
      counter += 1
      case x
      when :bool
        "to_bool(bool#{counter})"
      else
        "#{x}#{counter}"
      end
    }.join(',') + ")"
  else
    ""
  end
end

puts <<EOT
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
EOT
functions.each do |name, args, rv|
  puts <<EOT
      def #{name}#{format_params(args)}
        _wrapped_#{name}#{format_args(args)}
      end
EOT
end
puts <<EOT
    end
  include BoolWrappers
  extend BoolWrappers
  end
end
EOT
