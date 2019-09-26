if RUBY_VERSION < "2.5.0"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
  puts "|NOTICE| Ruby is #{RUBY_VERSION} not 2.5.0+..............................|Notice|"
  puts "|NOTICE| Monkey Patching Numeric to add required '.clamp' method.|Notice|"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
  puts
  class Numeric
    def clamp(min, max)
      if self < min
        min
      elsif self > max
        max
      else
        return self
      end
    end
  end
end