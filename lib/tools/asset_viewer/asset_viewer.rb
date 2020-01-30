require_relative "lib/main_menu"
require_relative "lib/turn_table"

class AssetViewerWindow < IMICFPS::Window
  def initialize(*args)
    super(*args)

    push_state(IMICFPS::AssetViewerTool::MainMenu)
  end
end

AssetViewerWindow.new.show