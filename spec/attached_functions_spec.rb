# -*- coding: utf-8 -*-
require 'minitest/spec'
require 'minitest/autorun'
require 'ffi-ncurses'

# Some preliminary sanity tests for FFI::NCurses

# test if all expected functions have been attached
describe "attached functions" do

  FFI::NCurses::FUNCTION_SIGNATURES.each do |sig|
    name = sig[0].to_s
    if name =~ /^_.*trace/ || name == "trace"
      next
    end

    it "should provide a module level function #{name}" do
      FFI::NCurses.respond_to?(name).must_equal true
    end

    it "should provide an instance level function #{name}" do
      FFI::NCurses.instance_methods.include?(name).must_equal true
    end

  end
end

# test that initscr and stdscr match up
describe "initscr" do

  it "should return an FFI::Pointer" do
    begin
      scr = FFI::NCurses.initscr
      scr.class.must_equal FFI::Pointer
      scr.must_equal FFI::NCurses.stdscr
    ensure
      FFI::NCurses.endwin
    end
  end

end
