# frozen_string_literal: true

class IMICFPS
  module SoundManager
    extend CyberarmEngine::Common

    @masters = {}
    @effects = []
    @playlists = {}
    @current_playlist = nil
    @current_playlist_package = nil
    @current_playlist_name = nil
    @current_playlist_index = 0

    def self.master_volume
      window.config.get(:options, :audio, :volume_master)
    end

    def self.music_volume
      window.config.get(:options, :audio, :volume_music) * master_volume
    end

    def self.sfx_volume
      window.config.get(:options, :audio, :volume_sound_effects) * master_volume
    end

    def self.load_master(package)
      return if @masters[package]

      hash = JSON.parse(File.read("#{IMICFPS.assets_path}/#{package}/shared/sound/master.json"))
      @masters[package] = hash
    end

    def self.sound(package, name)
      raise "Missing sound: '#{name}' in package '#{package}'" unless (data = sound_data(package, name.to_s))

      get_sample("#{IMICFPS.assets_path}/#{package}/shared/sound/#{data['path']}")
    end

    def self.sound_data(package, name)
      load_master(package)

      if (master = @masters[package])
        return master["sounds"].find { |s| s["name"] == name }
      end

      nil
    end

    def self.sound_effect(klass, options)
      @effects << klass.new(options)
    end

    def self.music(package, name)
      raise "Missing song: '#{name}' in package '#{package}'" unless (data = music_data(package, name.to_s))

      get_song("#{IMICFPS.assets_path}/#{package}/shared/sound/#{data['path']}")
    end

    def self.music_data(package, name)
      load_master(package)

      if (master = @masters[package])
        return master["music"].find { |s| s["name"] == name }
      end

      nil
    end

    def self.playlist_data(package, name)
      load_master(package)

      if (master = @masters[package])
        return master.dig("playlists", name.to_s)
      end

      nil
    end

    def self.play_playlist(package, name)
      return if @current_playlist_name == name.to_s
      return unless (list = playlist_data(package, name.to_s))

      @current_playlist = list
      @current_playlist_package = package
      @current_playlist_name = name.to_s
      @current_playlist_index = 0

      @current_song = music(@current_playlist_package, @current_playlist[@current_playlist_index])
      @current_song.volume = music_volume
      @current_song.play
    end

    def self.update
      @effects.each { |e| e.update; @effects.delete(e) if e.done? }

      return unless @current_playlist

      if !@current_song&.playing? && music_volume > 0.0
        @current_playlist_index += 1
        @current_playlist_index = 0 if @current_playlist_index >= @current_playlist.size

        @current_song = music(@current_playlist_package, @current_playlist[@current_playlist_index])
        @current_song.play
      end

      @current_song&.volume = music_volume
      @current_song&.stop if music_volume < 0.1
    end
  end
end
