# frozen_string_literal: true

class IMICFPS
  module Scripting
    def on
      # self is a Scripting::SandBox
      Subscription.new(entity)
    end

    def component(name)
      Component.get(name)
    end

    def map
      $window.director.map
    end
  end
end
