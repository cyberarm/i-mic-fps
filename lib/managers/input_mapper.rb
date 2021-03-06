# frozen_string_literal: true

class IMICFPS
  class InputMapper
    @@keymap = {}
    @@keys   = Hash.new(false)

    def self.keymap
      @@keymap
    end

    def self.keys
      @@keys
    end

    def self.keydown(id_or_action)
      if id_or_action.is_a?(Integer)
        @@keys[id_or_action] = true
      else
        query = @@keymap[id_or_action]

        case query
        when Integer
          query
        when Array
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
        query = @@keymap[id_or_action]

        case query
        when Integer
          query
        when Array
          query.each do |key|
            @@keys[key] = false
          end
        else
          raise "Something unexpected happened."
        end
      end
    end

    def self.get(action)
      @@keymap[action]
    end

    def self.set(action, key)
      raise "action must be a symbol" unless action.is_a?(Symbol)
      unless key.is_a?(Integer) || key.is_a?(Array)
        raise "key must be a whole number or Array of whole numbers, got #{key}"
      end

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
      keys = @@keymap[action]

      if keys.is_a?(Array)
        keys.include?(query_key)
      else
        query_key == keys
      end
    end

    def self.actions(key)
      @@keymap.select do |action, value|
        case value
        when Array
          action if value.include?(key)
        when key
          action
        end
      end.map { |keymap| keymap.first.is_a?(Symbol) ? keymap.first : keymap.first.first }
    end

    def self.reset_keys
      @@keys.each do |key, _value|
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
IMICFPS::InputMapper.set(:sneak,        [Gosu::KbLeftShift])
IMICFPS::InputMapper.set(:sprint,       [Gosu::KbLeftControl])
IMICFPS::InputMapper.set(:turn_180,     Gosu::KbX)

IMICFPS::InputMapper.set(:interact, Gosu::KbE)

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
