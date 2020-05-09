class IMICFPS
  module SoundManager
    extend CyberarmEngine::Common

    MASTERS = {}
    EFFECTS = []
    PLAYLISTS = {}

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
      return if MASTERS.dig(package)

      yaml = YAML.load_file( "#{IMICFPS.assets_path}/#{package}/shared/sound/master.yaml" )
      MASTERS[package] = yaml
    end

    def self.sound(package, name)
      if data = sound_data(package, name.to_s)
        get_sample("#{IMICFPS.assets_path}/#{package}/shared/sound/#{data["path"]}")
      else
        raise "Missing sound: '#{name}' in package '#{package}'"
      end
    end

    def self.sound_data(package, name)
      load_master(package)
      if master = MASTERS.dig(package)
        return master["sounds"].find { |s| s["name"] == name }
      end

      return nil
    end

    def self.sound_effect(klass, options)
      EFFECTS << klass.new(options)
    end

    def self.update
      EFFECTS.each { |e| e.update; EFFECTS.delete(e) if e.done? }
    end
  end
end