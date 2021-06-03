module CyberarmEngine
  class Element
    alias enter_original enter

    def enter(_sender)
      if @block && is_a?(CyberarmEngine::Element::Link)
        get_sample("#{IMICFPS::GAME_ROOT_PATH}/static/sounds/ui_hover.ogg").play
      end

      enter_original(_sender)
    end
  end
end