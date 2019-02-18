class IMICFPS
  class InputMapper
    @@keymap = {}
    @@keys   = Hash.new(false)

    def self.keydown(id)
      @@keys[id] = true
    end

    def self.keyup(id)
      @@keys[id] = false
    end

    def self.get(category, action)
      key = @@keymap.dig(category, action)
    end

    def self.set(category, action, key)
      raise "category must be a symbol"  unless category.is_a?(Symbol)
      raise "action must be a symbol"    unless action.is_a?(Symbol)
      raise "key must be a whole number or Array of whole numbers, got #{key}" unless key.is_a?(Integer) || key.is_a?(Array)

      @@keymap[category] ||= {}

      warn "InputMapper.set(:#{category}, :#{action}) is already defined as #{@@keymap[category][action]}" if @@keymap[category][action]

      @@keymap[category][action] = key
    end

    def self.down?(category, action)
      keys = get(category, action)

      if keys.is_a?(Array)
        keys.detect do |key|
          @@keys[key]
        end
      else
        @@keys[keys]
      end
    end

    def self.is?(category, action, query_key)
      keys = get(category, action)

      if keys.is_a?(Array)
        keys.detect do |key|
          query_key == key
        end
      else
        query_key == keys
      end
    end
  end
end