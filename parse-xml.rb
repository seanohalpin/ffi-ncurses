require 'rubygems'
require 'xml'
require 'pp'

# todo:
# - define new classes within own module (namespace) (perhaps root element? or specified on init)
# - BaseObject should be BlankSlate
# - internal attributes & methods should be invalid XML names
# - LibXML should be within namespace
# - command line option handling
# - any point making these Doodles?
# - how to handle XML namespaces? generate module?
# - need better introspection to report what has been created
# - perhaps (optionally) output definitions as classes (doodles?)
# - optionally ignore Text nodes
# - generate unique ids for elements that don't specify id

@constants = Object.constants

parser = XML::Parser.new
parser.file = 'ncurses.gccxml.xml'
#parser.file = 'junk.xml'
doc = parser.parse

#pp doc.root.children.size

#pp doc.root.attributes.map{ |a| [a.name, a.value] }

class BaseObject
  attr_accessor :_children
  attr_accessor :_text
  attr_accessor :_index
  def initialize(attributes, &block)
    attributes.each do |arg|
      method = "#{arg[0]}="
      if !respond_to?(method)
        self.class.class_eval {
          attr_accessor arg[0]
        }
      end
      send method, arg[1]
    end
  end
end

class Text
  attr_accessor :_index
  attr_accessor :_text
  def initialize(text, index)
    @_text, @_index = text, index
  end
end

@instances = { }
@klasses = []

def gen_instance(klass_name, attributes)
  #p [klass_name, attributes]
  case klass_name
  when 'String', 'Struct', 'Hash', 'Array', 'File'
    klass_name = "C#{klass_name}"
  end
  if Object.const_defined?(klass_name)
    klass = Object.const_get(klass_name)
  else
    klass = Class.new(BaseObject) do
      attributes.each do |attr|
        attr_accessor attr[0]
      end
    end
    Object.const_set(klass_name, klass)
    @klasses << klass
  end
  instance = klass.new(attributes)
end

def process_node(node, index)
  instance = gen_instance(node.name, node.attributes.map{ |a| [a.name, a.value] })
  @instances[node['id']] = instance
  instance._index = index
  instance._children = []
  instance._text = []
  node.children.each_with_index do |child, index|
    #p child.name
    if child.name == 'text'
      #instance._text << TextObject.new(child.to_s, index)
      instance._children << Text.new(child.to_s, index)
    else
      instance._children << process_node(child, index)
    end
  end
  instance
end

begin
  root = process_node(doc.root, 0)
rescue Object => e
  p [e, e.backtrace]
end
pp root
#pp @instances.keys
#pp @klasses

#require 'yaml'
#puts root.to_yaml
