# frozen_string_literal: true

class IMICFPS
  class SettingsMenu < Menu
    include CommonMethods

    def self.set_defaults
      if CyberarmEngine::Window.instance.config.get(:options, :audio, :volume_master).nil?
        CyberarmEngine::Window.instance.config[:options, :audio, :volume_master]    = 1.0
      end

      if CyberarmEngine::Window.instance.config.get(:options, :audio, :volume_sound_effects).nil?
        CyberarmEngine::Window.instance.config[:options, :audio, :volume_sound_effects]    = 1.0
      end

      if CyberarmEngine::Window.instance.config.get(:options, :audio, :volume_music).nil?
        CyberarmEngine::Window.instance.config[:options, :audio, :volume_music]    = 0.7
      end

      if CyberarmEngine::Window.instance.config.get(:options, :audio, :volume_dialogue).nil?
        CyberarmEngine::Window.instance.config[:options, :audio, :volume_dialogue] = 0.7
      end
    end

    def setup
      @pages = {}
      @current_page = nil

      flow(width: 1.0, height: 1.0) do
        stack(width: 0.25, height: 1.0) do
        end

        stack(width: 0.5, height: 1.0) do
          stack(width: 1.0, height: 0.25) do
            title "Settings"

            flow(width: 1.0) do
              link I18n.t("menus.back"), width: nil do
                pop_state
              end

              button get_image("#{GAME_ROOT_PATH}/static/icons/settings_display.png"),     image_width: 64, tip: I18n.t("settings.display") do
                show_page(:display)
              end

              button get_image("#{GAME_ROOT_PATH}/static/icons/settings_graphics.png"),    image_width: 64, tip: I18n.t("settings.graphics") do
                show_page(:graphics)
              end

              button get_image("#{GAME_ROOT_PATH}/static/icons/settings_audio.png"),       image_width: 64, tip: I18n.t("settings.audio") do
                show_page(:audio)
              end

              button get_image("#{GAME_ROOT_PATH}/static/icons/settings_controls.png"),    image_width: 64, tip: I18n.t("settings.controls") do
                show_page(:controls)
              end

              button get_image("#{GAME_ROOT_PATH}/static/icons/settings_multiplayer.png"), image_width: 64, tip: I18n.t("settings.multiplayer") do
                show_page(:multiplayer)
              end
            end
          end

          @page_container = stack(width: 1.0, height: 0.75, scroll: true) do
          end
        end
      end

      #   @categories.each do |category|
      #     stack(width: 0.5, height: 1.0) do |element|
      #       @pages[:"#{category}".downcase] = element
      #       element.hide

      #       send(:"create_page_#{category}".downcase) if respond_to?(:"create_page_#{category}".downcase)
      #     end
      #   end
      # end

      show_page(:display)
    end

    def show_page(page)
      @page_container.clear do
        send(:"page_#{page}")
      end

      @page_container.scroll_top = 0
    end

    def page_display
      label "Display", text_size: 50

      label "Resolution"
      flow do
        stack do
          label "Width"
          label "Height"
        end
        stack do
          edit_line window.width.to_s
          edit_line window.height.to_s
        end
      end

      check_box "Fullscreen", margin_top: 25, margin_bottom: 25

      stack do
        longest_string = "Gamma Correction"
        flow do
          label "Gamma Correction".ljust(longest_string.length, " ")
          @display_gamma_correction = slider range: 0.0..1.0, value: 0.5
          @display_gamma_correction.subscribe(:changed) do |_sender, value|
            @display_gamma_correction_label.value = value.round(1).to_s
          end
          @display_gamma_correction_label = label "0.0"
        end
        flow do
          label "Brightness".ljust(longest_string.length, " ")
          @display_brightness = slider range: 0.0..1.0, value: 0.5
          @display_brightness.subscribe(:changed) do |_sender, value|
            @display_brightness_label.value = value.round(1).to_s
          end
          @display_brightness_label = label "0.0"
        end
        flow do
          label "Contrast".ljust(longest_string.length, " ")
          @display_contrast = slider range: 0.0..1.0, value: 0.5
          @display_contrast.subscribe(:changed) do |_sender, value|
            @display_contrast_label.value = value.round(1).to_s
          end
          @display_contrast_label = label "0.0"
        end
      end
    end

    def page_audio
      label "Audio", text_size: 50
      longest_string = "Dialogue".length
      volumes = %i[master sound_effects music dialogue]

      stack(width: 1.0) do
        volumes.each do |volume|
          config_value = window.config.get(:options, :audio, :"volume_#{volume}")

          flow(width: 1.0, margin_bottom: 10) do
            flow(width: 0.25) do
              label volume.to_s.split("_").map(&:capitalize).join(" ").ljust(longest_string, " ")
            end

            flow(width: 0.5) do
              instance_variable_set(:"@volume_#{volume}", slider(range: 0.0..1.0, value: config_value, width: 1.0))
              instance_variable_get(:"@volume_#{volume}").subscribe(:changed) do |_sender, value|
                instance_variable_get(:"@volume_#{volume}_label").value = format("%03.2f%%", value * 100.0)
                window.config[:options, :audio, :"volume_#{volume}"] = value
              end
            end

            flow(width: 0.25) do
              instance_variable_set(:"@volume_#{volume}_label", label(format("%03.2f%%", config_value * 100.0)))
            end
          end
        end
      end
    end

    def page_controls
      label "Controls", text_size: 50

      InputMapper.keymap.each do |key, values|
        flow do
          label key.to_s

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

    def page_graphics
      label "Graphics", text_size: 50

      longest_string = "Surface Effect Detail"

      flow do
        check_box "V-Sync (Not Disableable, Yet.)", checked: true, enabled: false
      end

      flow do
        label "Field of View".ljust(longest_string.length, " ")
        @fov = slider range: 70.0..110.0
        @fov.subscribe(:changed) do |_sender, value|
          @fov_label.value = value.round.to_s
        end
        @fov_label = label "90.0"
      end

      flow do
        label "Detail".ljust(longest_string.length, " ")
        list_box items: %i[high medium low], width: 250
      end

      label ""
      advanced_mode = check_box "Advanced Settings"
      label ""

      advanced_settings = stack width: 1.0 do |element|
        element.hide

        stack do
          flow do
            label "Geometry Detail".ljust(longest_string.length, " ")
            list_box items: %i[high medium low], width: 250
          end
          flow do
            label "Shadow Detail".ljust(longest_string.length, " ")
            list_box items: %i[high medium low off], width: 250
          end
          flow do
            label "Texture Detail".ljust(longest_string.length, " ")
            list_box items: %i[high medium low], width: 250
          end
          flow do
            label "Particle Detail".ljust(longest_string.length, " ")
            list_box items: %i[high medium low off], width: 250
          end
          flow do
            label "Surface Effect Detail".ljust(longest_string.length, " ")
            list_box items: %i[high medium low], width: 250
          end
          flow do
            label "Lighting Mode".ljust(longest_string.length, " ")
            list_box items: %i[per_pixel per_vertex], width: 250
          end
          flow do
            label "Texture Filtering".ljust(longest_string.length, " ")
            list_box items: [:none], width: 250
          end
        end
      end

      advanced_mode.subscribe(:changed) do |_element, value|
        advanced_settings.show if value
        advanced_settings.hide unless value
      end
    end

    def page_multiplayer
      label "Multiplayer", text_size: 50

      flow do
        label "Player Name"
        edit_line "player-#{SecureRandom.hex(2)}"
      end
      check_box "Show player names"
    end
  end
end
