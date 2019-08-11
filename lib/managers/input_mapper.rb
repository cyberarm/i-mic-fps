class IMICFPS
  class InputMapper
    @@keymap = {}
    @@keys   = Hash.new(false)

    def self.keydown(id_or_action)
      if id_or_action.is_a?(Integer)
        @@keys[id_or_action] = true
      else
        query = @@keymap.dig(id_or_action)

        if query.is_a?(Integer)
           query
        elsif query.is_a?(Array)
          query.each do |key|
            @@keys[key] = true
          end
        else
          raise "Something unexpected happened."
        end
      end
    end

    def self.keyup(id_or_action)
      if id_or_action.is_a?(Integer)
        @@keys[id_or_action] = false
      else
        query = @@keymap.dig(id_or_action)

        if query.is_a?(Integer)
          query
        elsif query.is_a?(Array)
          query.each do |key|
            @@keys[key] = false
          end
        else
          raise "Something unexpected happened."
        end
      end
    end

    def self.get(action)
      @@keymap.dig(action)
    end

    def self.set(action, key)
      raise "action must be a symbol"    unless action.is_a?(Symbol)
      raise "key must be a whole number or Array of whole numbers, got #{key}" unless key.is_a?(Integer) || key.is_a?(Array)

      warn "InputMapper.set(:#{action}) is already defined as #{@@keymap[action]}" if @@keymap[action]

      @@keymap[action] = key
    end

    def self.down?(action)
      keys = get(action)

      if keys.is_a?(Array)
        keys.detect do |key|
          @@keys[key]
        end
      else
        @@keys[keys]
      end
    end

    def self.is?(action, query_key)
      keys = @@keymap.dig(action)

      if keys.is_a?(Array)
        keys.include?(query_key)
      else
        query_key == keys
      end
    end

    def self.action(key)
      answer = nil
      @@keymap.each do |action, value|
        p action, value

        if value.is_a?(Array)
          if value.include?(key)
            answer = action
            break
          end

        else
          if value == key
            answer = action
            break
          end
        end
      end

      raise "InputMapper.action(#{key}) is nil!" unless answer
      answer
    end

    def self.reset_keys
      @@keys.each do |key, value|
        @@keys[key] = false
      end
    end
  end
end

IMICFPS::InputMapper.set(:forward,      [Gosu::KbUp, Gosu::KbW])
IMICFPS::InputMapper.set(:backward,     [Gosu::KbDown, Gosu::KbS])
IMICFPS::InputMapper.set(:strife_left,  Gosu::KbA)
IMICFPS::InputMapper.set(:strife_right, Gosu::KbD)
IMICFPS::InputMapper.set(:turn_left,    Gosu::KbLeft)
IMICFPS::InputMapper.set(:turn_right,   Gosu::KbRight)
IMICFPS::InputMapper.set(:jump,         Gosu::KbSpace)
IMICFPS::InputMapper.set(:sprint,       [Gosu::KbLeftControl])
IMICFPS::InputMapper.set(:turn_180,     Gosu::KbX)

IMICFPS::InputMapper.set(:ascend,                   Gosu::KbSpace)
IMICFPS::InputMapper.set(:descend,                  Gosu::KbC)
IMICFPS::InputMapper.set(:toggle_first_person_view, Gosu::KbF)

IMICFPS::InputMapper.set(:release_mouse,              [Gosu::KbLeftAlt, Gosu::KbRightAlt])
IMICFPS::InputMapper.set(:capture_mouse,              Gosu::MsLeft)
IMICFPS::InputMapper.set(:increase_mouse_sensitivity, Gosu::KB_NUMPAD_PLUS)
IMICFPS::InputMapper.set(:decrease_mouse_sensitivity, Gosu::KB_NUMPAD_MINUS)
IMICFPS::InputMapper.set(:reset_mouse_sensitivity,    Gosu::KB_NUMPAD_MULTIPLY)

IMICFPS::InputMapper.set(:decrease_view_distance,     Gosu::MsWheelDown)
IMICFPS::InputMapper.set(:increase_view_distance,     Gosu::MsWheelUp)