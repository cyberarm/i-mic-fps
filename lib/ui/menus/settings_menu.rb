class IMICFPS
  class SettingsMenu < Menu
    include CommonMethods

    def setup
      @categories = [
        "Display",
        "Graphics",
        "Audio",
        "Controls",
        "Multiplayer"
      ]
      @pages = {}
      @current_page = nil

      label "Settings", text_size: 100, color: Gosu::Color::BLACK

      flow(width: 1.0, height: 1.0) do
        stack(width: 0.25, height: 1.0) do
          @categories.each do |category|
            button category, width: 1.0 do
              show_page(:"#{category}".downcase)
            end
          end

          button "Back", width: 1.0, margin_top: 64 do
            pop_state
          end
        end

        @categories.each do |category|
          stack(width: 0.5, height: 1.0) do |element|
            @pages[:"#{category}".downcase] = element
            element.hide

            if respond_to?(:"create_page_#{category}".downcase)
              self.send(:"create_page_#{category}".downcase)
            end
          end
        end
      end

      show_page(:display)
    end

    def show_page(page)
      if element = @pages.dig(page)
        @current_page.hide if @current_page
        @current_page = element
        element.show
      end
    end

    def create_page_display
      label "Display", text_size: 50

      label "Resolution"
      flow do
        stack do
          label "Width"
          label "Height"
        end
        stack do
          edit_line "#{window.width}"
          edit_line "#{window.height}"
        end
      end

      check_box "Fullscreen", padding_top: 25, padding_top: 25

      flow do
        stack do
          label "Gamma Correction"
          label "Brightness"
          label "Contrast"
        end
        stack do
          slider
          slider
          slider
        end
        stack do
          label "0.0"
          label "0.0"
          label "0.0"
        end
      end
    end

    def create_page_audio
      label "Audio", text_size: 50

      flow do
        stack do
          label "Master Volume"
          label "Sound Effects"
          label "Dialog"
          label "Cinematic"
        end
        stack do
          slider range: 0.0..1.0, value: 1.0
          slider range: 0.0..1.0, value: 1.0
          slider range: 0.0..1.0, value: 1.0
          slider range: 0.0..1.0, value: 1.0
        end
        stack do
          label "0.0"
          label "0.0"
          label "0.0"
          label "0.0"
        end
      end
    end

    def create_page_controls
      label "Controls", text_size: 50

      InputMapper.keymap.each do |key, values|
        flow do
          label "#{key}"

          [values].flatten.each do |value|
            button Gosu.button_id_to_char(value)
          end
        end
      end
    end

    def create_page_graphics
      label "Graphics", text_size: 50

      flow do
        check_box "V-Sync"
        label "(No Supported)"
      end

      flow do
        label "Field of View"
        slider range: 70.0..110.0
        label "90.0"
      end

      flow do
        stack do
          label "Detail"
        end
        stack do
          slider range: 1..3
        end
        stack do
          label "High"
        end
      end

      advanced_mode = check_box "Advanced Mode"

      advanced_settings = stack do |element|
        element.hide

        flow do
          stack do
            label "Geometry Detail"
            label "Shadow Detail"
            label "Texture Detail"
            label "Particle Detail"
            label "Surface Effect Detail"
          end
          stack do
            slider
            slider
            slider
            slider
            slider
          end
          stack do
            label "High"
            label "High"
            label "High"
            label "High"
            label "High"
          end
        end

        flow do
          stack do
            label "Lighting Mode"
            edit_line ""
          end
          stack do
            label "Texture Filtering"
            edit_line ""
          end
        end
      end

      advanced_mode.subscribe(:changed) do |element, value|
        advanced_settings.show if value
        advanced_settings.hide unless value
      end
    end

    def create_page_multiplayer
      label "Multiplayer", text_size: 50

      check_box "Show player names"
    end
  end
end