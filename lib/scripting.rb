class IMICFPS
  module Scripting
    def on
      # self is a Scripting::SandBox
      Subscription.new(self.entity)
    end

    def component(name)
      Component.get(name)
    end
  end
end