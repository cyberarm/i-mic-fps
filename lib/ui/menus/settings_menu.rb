class IMICFPS
  class SettingsMenu < Menu
    include CommonMethods

    def self.set_defaults
      $window.config[:options, :audio, :volume_sound]    = 1.0 if $window.config.get(:options, :audio, :volume_sound).nil?
      $window.config[:options, :audio, :volume_music]    = 0.7 if $window.config.get(:options, :audio, :volume_music).nil?
      $window.config[:options, :audio, :volume_dialogue] = 0.7 if $window.config.get(:options, :audio, :volume_dialogue).nil?
    end

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

          button I18n.t("menus.back"), width: 1.0, margin_top: 64 do
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

      check_box "Fullscreen", padding_top: 25, padding_bottom: 25

      stack do
        longest_string = "Gamma Correction"
        flow do
          label "Gamma Correction".ljust(longest_string.length, " ")
          @display_gamma_correction = slider range: 0.0..1.0, value: 0.5
          @display_gamma_correction.subscribe(:changed) do |sender, value|
            @display_gamma_correction_label.value = value.round(1).to_s
          end
          @display_gamma_correction_label = label "0.0"
        end
        flow do
          label "Brightness".ljust(longest_string.length, " ")
          @display_brightness = slider range: 0.0..1.0, value: 0.5
          @display_brightness.subscribe(:changed) do |sender, value|
            @display_brightness_label.value = value.round(1).to_s
          end
          @display_brightness_label = label "0.0"        end
        flow do
          label "Contrast".ljust(longest_string.length, " ")
          @display_contrast = slider range: 0.0..1.0, value: 0.5
          @display_contrast.subscribe(:changed) do |sender, value|
            @display_contrast_label.value = value.round(1).to_s
          end
          @display_contrast_label = label "0.0"
        end
      end
    end

    def create_page_audio
      label "Audio", text_size: 50
      longest_string = "Dialogue".length
      volumes = [:sound, :music, :dialogue]

      stack do
        volumes.each do |volume|
          config_value = window.config.get(:options, :audio, :"volume_#{volume}")

          flow do
            label volume.to_s.split("_").join(" ").capitalize.ljust(longest_string, " ")
            instance_variable_set(:"@volume_#{volume}", slider(range: 0.0..1.0, value: config_value))
            instance_variable_get(:"@volume_#{volume}").subscribe(:changed) do |sender, value|
              instance_variable_get(:"@volume_#{volume}_label").value = "%03.2f%%" % [value * 100.0]
              window.config[:options, :audio, :"volume_#{volume}"] = value
            end
            instance_variable_set(:"@volume_#{volume}_label", label("%03.2f%%" % [config_value * 100.0]))
          end
        end
      end
    end

    def create_page_controls
      label "Controls", text_size: 50

      InputMapper.keymap.each do |key, values|
        flow do
          label "#{key}"

          [values].flatten.each do |value|
            if name = Gosu.button_name(value)
            else
              name = Gosu.constants.find { |const| Gosu.const_get(const) == value }
              name = name.to_s.capitalize.split("_").join(" ") if name
            end
            button name
          end
        end
      end
    end

    def create_page_graphics
      label "Graphics", text_size: 50

      longest_string = "Surface Effect Detail"

      flow do
        check_box "V-Sync (Not Disableable, Yet.)", checked: true, enabled: false
      end

      flow do
        label "Field of View".ljust(longest_string.length, " ")
        @fov = slider range: 70.0..110.0
        @fov.subscribe(:changed) do |sender, value|
          @fov_label.value = value.round.to_s
        end
        @fov_label = label "90.0"
      end

      flow do
        label "Detail".ljust(longest_string.length, " ")
        list_box items: [:high, :medium, :low], width: 250
      end

      label ""
      advanced_mode = check_box "Advanced Settings"
      label ""

      advanced_settings = stack width: 1.0 do |element|
        element.hide

        stack do
          flow do
            label "Geometry Detail".ljust(longest_string.length, " ")
            list_box items: [:high, :medium, :low], width: 250
          end
          flow do
            label "Shadow Detail".ljust(longest_string.length, " ")
            list_box items: [:high, :medium, :low, :off], width: 250
          end
          flow do
            label "Texture Detail".ljust(longest_string.length, " ")
            list_box items: [:high, :medium, :low], width: 250
          end
          flow do
            label "Particle Detail".ljust(longest_string.length, " ")
            list_box items: [:high, :medium, :low, :off], width: 250
          end
          flow do
            label "Surface Effect Detail".ljust(longest_string.length, " ")
            list_box items: [:high, :medium, :low], width: 250
          end
          flow do
            label "Lighting Mode".ljust(longest_string.length, " ")
            list_box items: [:per_pixel, :per_vertex], width: 250
          end
          flow do
            label "Texture Filtering".ljust(longest_string.length, " ")
            list_box items: [:none], width: 250
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

      flow do
        label "Player Name"
        edit_line "player-#{SecureRandom.hex(2)}"
      end
      check_box "Show player names"
    end
  end
end