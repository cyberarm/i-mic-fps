# frozen_string_literal: true

begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

class Window < Gosu::Window
  def initialize
    super(Gosu.screen_width, Gosu.screen_height, fullscreen: true)
    CyberarmEngine::Window.instance = self
    @size = 50
    @slope = 250
    @color_step = 10
    @base_color = Gosu::Color.rgb(255, 127, 0)
    @title = CyberarmEngine::Text.new("I-MIC FPS", color: Gosu::Color.rgb(255, 127, 0), size: 100, x: 0, y: 15, alignment: :center)
    @singleplayer = CyberarmEngine::Text.new("Singleplayer", color: Gosu::Color.rgb(0, 127, 127), size: 50, x: 0, y: 150, alignment: :center)
  end

  def draw
    @background ||= Gosu.record(Gosu.screen_width, Gosu.screen_height) do
      ((Gosu.screen_height + @slope) / @size).times do |i|
        fill_quad(
          0, i * @size,
          0, @slope + (i * @size),
          Gosu.screen_width / 2, (-@slope) + (i * @size),
          Gosu.screen_width / 2, i * @size,
          Gosu::Color.rgba(@base_color.red - i * @color_step, @base_color.green - i * @color_step, @base_color.blue - i * @color_step, 200)
        )
        fill_quad(
          Gosu.screen_width, i * @size,
          Gosu.screen_width, @slope + (i * @size),
          Gosu.screen_width / 2, (-@slope) + (i * @size),
          Gosu.screen_width / 2, i * @size,
          Gosu::Color.rgba(@base_color.red - i * @color_step, @base_color.green - i * @color_step, @base_color.blue - i * @color_step, 200)
        )
      end
    end

    @background.draw(0, 0, 0)

    # Box
    draw_rect(
      Gosu.screen_width / 4, 0,
      Gosu.screen_width / 2, Gosu.screen_height,
      Gosu::Color.rgba(100, 100, 100, 150)
      # Gosu::Color.rgba(@base_color.red+@color_step, @base_color.green+@color_step, @base_color.blue+@color_step, 200)
    )

    # Texts
    @title.draw
    @singleplayer.draw

    # Cursor
    fill_quad(
      mouse_x, mouse_y,
      mouse_x + 16, mouse_y + 16,
      mouse_x, mouse_y + 16,
      mouse_x, mouse_y + 16,
      Gosu::Color::RED, Float::INFINITY
    )
  end

  def fill_quad(x1, y1, x2, y2, x3, y3, x4, y4, color = Gosu::Color::WHITE, z = 0, mode = :default)
    draw_quad(
      x1, y1, color,
      x2, y2, color,
      x3, y3, color,
      x4, y4, color,
      z, mode
    )
  end

  def button_up(id)
    close if id == Gosu::KbEscape
  end

  def needs_cursor?
    false
  end
end

Window.new.show
