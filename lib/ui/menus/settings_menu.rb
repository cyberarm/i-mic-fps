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

        stack(fill: true, height: 1.0) do
          title "Settings", width: 1.0, text_align: :center

          stack(width: 1.0, height: 96) do
            flow(width: 1.0) do
              link I18n.t("menus.back"), width: nil do
                pop_state
              end

              flow(fill: true)

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

          @page_container = stack(width: 1.0, fill: true, scroll: true, padding: 10) do
          end
        end

        stack(width: 0.25, height: 1.0) do
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

      stack(width: 1.0, height: 128) do
        flow(width: 1.0) do
          label "Width", width: 96
          edit_line window.width.to_s, fill: true
        end

        flow(width: 1.0) do
          label "Height", width: 96
          edit_line window.height.to_s, fill: true
        end
      end

      # check_box "Fullscreen", margin_top: 25, margin_bottom: 25, width: 1.0

      stack(width: 1.0, height: 128, margin_top: 20) do
        flow(width: 1.0, fill: true) do
          label "Gamma Correction", width: 256
          @display_gamma_correction = slider range: 0.0..1.0, value: 0.5, fill: true
          @display_gamma_correction.subscribe(:changed) do |_sender, value|
            @display_gamma_correction_label.value = value.round(1).to_s
          end
          @display_gamma_correction_label = label "0.0"
        end

        flow(width: 1.0, fill: true) do
          label "Brightness", width: 256
          @display_brightness = slider range: 0.0..1.0, value: 0.5, fill: true
          @display_brightness.subscribe(:changed) do |_sender, value|
            @display_brightness_label.value = value.round(1).to_s
          end
          @display_brightness_label = label "0.0"
        end

        flow(width: 1.0, fill: true) do
          label "Contrast", width: 256
          @display_contrast = slider range: 0.0..1.0, value: 0.5, fill: true
          @display_contrast.subscribe(:changed) do |_sender, value|
            @display_contrast_label.value = value.round(1).to_s
          end
          @display_contrast_label = label "0.0"
        end
      end
    end

    def page_audio
      label "Audio", text_size: 50
      volumes = %i[master sound_effects music dialogue]

      stack(width: 1.0, height: 48 * volumes.count) do
        volumes.each do |volume|
          config_value = window.config.get(:options, :audio, :"volume_#{volume}")

          flow(width: 1.0, fill: true, margin_bottom: 10) do
            label volume.to_s.split("_").map(&:capitalize).join(" "), width: 172

            instance_variable_set(:"@volume_#{volume}", slider(range: 0.0..1.0, value: config_value, fill: true))
            instance_variable_get(:"@volume_#{volume}").subscribe(:changed) do |_sender, value|
              instance_variable_get(:"@volume_#{volume}_label").value = format("%03.2f%%", value * 100.0)
              window.config[:options, :audio, :"volume_#{volume}"] = value
            end

            instance_variable_set(:"@volume_#{volume}_label", label(format("%03.2f%%", config_value * 100.0), width: 96, text_align: :right))
          end
        end
      end
    end

    def page_controls
      label "Controls", text_size: 50

      InputMapper.keymap.each do |key, values|
        flow(width: 1.0, height: 64) do
          label key.to_s, width: 0.5, max_width: 312

          [values].flatten.each do |value|
            unless (name = Gosu.button_name(value))
              name = Gosu.constants.find { |const| Gosu.const_get(const) == value }
              name = name.to_s.capitalize.split("_").join(" ") if name
            end

            button name, fill: true
          end
        end
      end
    end

    def page_graphics
      label "Graphics", text_size: 50

      check_box "V-Sync (Not Disableable, Yet.)", checked: true, enabled: false, width: 1.0

      flow(width: 1.0, height: 64) do
        label "Field of View", width: 128
        @fov = slider range: 70.0..110.0, fill: true
        @fov.subscribe(:changed) do |_sender, value|
          @fov_label.value = value.round.to_s
        end
        @fov_label = label "90.0"
      end

      flow(width: 1.0, height: 64) do
        label "Detail", width: 128
        list_box items: %i[high medium low], fill: true
      end

      advanced_mode = check_box "Advanced Settings", margin_top: 20, margin_bottom: 20

      advanced_settings = stack(width: 1.0) do |element|
        element.hide

        stack(width: 1.0, height: 64 * 7) do
          flow(width: 1.0, height: 64) do
            label "Geometry Detail", width: 312
            list_box items: %i[high medium low], fill: true
          end
          flow(width: 1.0, height: 64) do
            label "Shadow Detail", width: 312
            list_box items: %i[high medium low off], fill: true
          end
          flow(width: 1.0, height: 64) do
            label "Texture Detail", width: 312
            list_box items: %i[high medium low], fill: true
          end
          flow(width: 1.0, height: 64) do
            label "Particle Detail", width: 312
            list_box items: %i[high medium low off], fill: true
          end
          flow(width: 1.0, height: 64) do
            label "Surface Effect Detail", width: 312
            list_box items: %i[high medium low], fill: true
          end
          flow(width: 1.0, height: 64) do
            label "Lighting Mode", width: 312
            list_box items: %i[per_pixel per_vertex], fill: true
          end
          flow(width: 1.0, height: 64) do
            label "Texture Filtering", width: 312
            list_box items: [:none], fill: true
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

      flow(width: 1.0, height: 64) do
        label "Player Name", width: 172
        edit_line "player-#{SecureRandom.hex(2)}", fill: true
      end

      check_box "Show player names"
    end
  end
end
