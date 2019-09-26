class IMICFPS
  module Scripting
    def on
      Subscription.new(self)
    end

    def component(name)
      Component.get(name)
    end
  end
end