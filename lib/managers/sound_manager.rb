# frozen_string_literal: true

class IMICFPS
  module SoundManager
    extend CyberarmEngine::Common

    @masters = {}
    @effects = []
    @playlists = {}

    def self.master_volume
      1.0
    end

    def self.music_volume
      0.25 * master_volume
    end

    def self.sfx_volume
      0.5 * master_volume
    end

    def self.load_master(package)
      return if @masters[package]

      yaml = YAML.load_file("#{IMICFPS.assets_path}/#{package}/shared/sound/master.yaml")
      @masters[package] = yaml
    end

    def self.sound(package, name)
      if data = sound_data(package, name.to_s)
        get_sample("#{IMICFPS.assets_path}/#{package}/shared/sound/#{data['path']}")
      else
        raise "Missing sound: '#{name}' in package '#{package}'"
      end
    end

    def self.sound_data(package, name)
      load_master(package)
      if master = @masters[package]
        return master["sounds"].find { |s| s["name"] == name }
      end

      nil
    end

    def self.sound_effect(klass, options)
      @effects << klass.new(options)
    end

    def self.update
      @effects.each { |e| e.update; @effects.delete(e) if e.done? }
    end
  end
end
