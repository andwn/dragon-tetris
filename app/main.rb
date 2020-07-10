# MenuItem is a label that executes a function when you click it
class MenuItem
  attr_accessor :label, :func
  def initialize(label, func)
    @label = label
    @func = func
  end
end

# Menu has a list of MenuItems it displays vertically in a window
class Menu
  def initialize(x, y, w, h, items)
    @xpos = x
    @ypos = y
    @width = w
    @height = h
    @items = items
    auto_size
    @clicked_index = -1
  end
  def auto_size
    @line_height = 24
    @padding = 2
    @width = 320 if @width < 0
    @height = @items.length * @line_height if @height < 0
    @xpos = 640 - @width / 2 if @xpos < 0
    @ypos = 360 - @height / 2 if @ypos < 0
  end
  def tick(args)
    # Border
    if @width > 0 && @height > 0
      args.outputs.borders << [@xpos-2, @ypos-2, @width+4, @height+4, 255,255,255,255]
      args.outputs.borders << [@xpos-1, @ypos-1, @width+2, @height+2, 255,255,255,255]
      args.outputs.solids << [@xpos, @ypos, @width, @height, 0,128,64,192]
    end
    x = @xpos
    y = @ypos
    mx = args.inputs.mouse.x
    my = args.inputs.mouse.y
    # Draw each option, and check if the mouse is hovering over them
    @items.reverse.each_with_index { |p, i|
      args.outputs.labels << [x + @width / 2, y + @line_height, p.label, 0, 1]
      if mx >= x && mx < x + @width && my >= y && my < y + @line_height
        if args.inputs.mouse.click # Started to click?
          @clicked_index = i
        elsif args.inputs.mouse.up # Released?
          if @clicked_index == i
            p.func.call # Execute this item's function
          end
        end
        @clicked_index == -1 if args.inputs.mouse.up
        # Fade in/out when hovering, make brighter when clicking
        if @clicked_index == i
          args.outputs.solids << [x, y, @width, @line_height, 255, 255, 255, 192]
        else
          args.outputs.solids << [x, y, @width, @line_height, 255, 255, 255, 128 + Math.sin($tick_count / 12) * 64]
        end
      end
      y += @line_height
    }
    # Show message if it's there
    if @msg != nil
      args.outputs.labels << [x, y, @msg, 0]
      y += @line_height
    end
  end
end

# Game objects
class Tetromino
  attr_accessor :x, :y, :type, :flip
  def initialize(x, y, type)
    @x = x
    @y = y
    @type = type
    @flip = 0
  end
end

# Title Screen
class SceneTitle
  def initialize
    @menu = Menu.new(-1, 240, 200, -1, [
        MenuItem.new("Game Start", lambda { $scene = SceneGame.new }),
        MenuItem.new("High Scores", lambda { $scene = SceneScore.new }),
        MenuItem.new("Settings", lambda { $scene = SceneSettings.new }),
        MenuItem.new("Exit", lambda { $scene = nil }),
    ])
    for i in 1..20
      @dragons += [[rand(1280), rand(720), 64 + rand(128), 50 + rand(101), 'dragonruby.png', 0]]
      @speeds += [-7 + rand(16)]
    end
  end
  def tick(args)
    @dragons.each_with_index { |d, i|
      d[5] += @speeds[i]
      args.outputs.sprites << d
    }
    args.outputs.labels << [640, 540, "Tetris", 32, 1]
    @menu.tick(args)
  end
end

# Game Screen
class SceneGame
  def initialize

  end
  def tick(args)
    args.outputs.labels << [640, 540, "IT'S DA GAME!!!", 32, 1]
  end
end

# High Score Screen
class SceneScore
  def initialize

  end
  def tick(args)
    args.outputs.labels << [640, 540, "IT'S DA HIGH SCORES!!!", 32, 1]
  end
end

# Settings Screen
class SceneSettings
  def initialize

  end
  def tick(args)
    args.outputs.labels << [640, 540, "IT'S DA SETTINGS!!!", 32, 1]
  end
end

$tick_count = 0
$scene = SceneTitle.new

def tick(args)
  exit(0) if $scene == nil
  $scene.tick(args)
  $tick_count += 1
end
