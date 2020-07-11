# Fonts
BLACK_FONT = [0,0,0,255, 'Funstella.ttf']
WHITE_FONT = [255,255,255,255, 'Funstella.ttf']
MAIN_FONT = BLACK_FONT

class Button
  def initialize(x, y, w, h, label, func)
    @xpos = x
    @ypos = y
    @width = w
    @height = h
    @label = label
    @func = func
    @clicked_inside = false
  end
  def tick(args)
    # Border & back
    if @width > 0 && @height > 0
      args.outputs.borders << [@xpos-1, @ypos-1, @width+2, @height+2, 255,255,255,255]
      args.outputs.solids << [@xpos, @ypos, @width, @height, 0,128,64,192]
    end
    # Label
    args.outputs.labels << [@xpos + @width / 2, @ypos + 24, @label, 0, 1] + MAIN_FONT
    # Check hover/click
    mx = args.inputs.mouse.x
    my = args.inputs.mouse.y
    if mx >= @xpos && mx < @xpos+@width && my >= @ypos && my < @ypos+@height
      if args.inputs.mouse.click # Started to click?
        @clicked_inside = true
      elsif args.inputs.mouse.up # Released?
        @func.call if @clicked_inside
      end
      # Fade in/out when hovering, make brighter when clicking
      if @clicked_inside
        args.outputs.solids << [@xpos, @ypos, @width, @height, 255, 255, 255, 192]
      else
        args.outputs.solids << [@xpos, @ypos, @width, @height, 255, 255, 255, 128 + Math.sin($tick_count / 12) * 64]
      end
    end
    @clicked_inside = false if args.inputs.mouse.up
  end
end

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
      args.outputs.labels << [x + @width / 2, y + @line_height, p.label, 0, 1] + MAIN_FONT
      if mx >= x && mx < x + @width && my >= y && my < y + @line_height
        if args.inputs.mouse.click # Started to click?
          @clicked_index = i
        elsif args.inputs.mouse.up # Released?
          if @clicked_index == i
            p.func.call # Execute this item's function
          end
        end
        # Fade in/out when hovering, make brighter when clicking
        if @clicked_index == i
          args.outputs.solids << [x, y, @width, @line_height, 255, 255, 255, 192]
        else
          args.outputs.solids << [x, y, @width, @line_height, 255, 255, 255, 128 + Math.sin($tick_count / 12) * 64]
        end
      end
      y += @line_height
    }
    @clicked_index = -1 if args.inputs.mouse.up
    # Show message if it's there
    if @msg != nil
      args.outputs.labels << [x, y, @msg, 0]
      y += @line_height
    end
  end
end
