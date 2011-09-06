# 1.8.6 compatibility
if !1.respond_to?(:ord)
  class Integer
    def ord
      self
    end
  end
end

