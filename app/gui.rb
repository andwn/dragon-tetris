# Fonts
BLACK_FONT = [0,0,0,255, 'Funstella.ttf'].freeze
WHITE_FONT = [255,255,255,255, 'Funstella.ttf'].freeze
MAIN_FONT = BLACK_FONT

class Widget
  def initialize(x, y, w, h)
    @xpos = x
    @ypos = y
    @width = w
    @height = h
  end
  def draw_back(args, a = 192, r = 0, g = 128, b = 64)
    if @width.positive? && @height.positive?
      args.outputs.sprites << [@xpos,@ypos,@width,@height, 'sprites/white.png',0, a,r,g,b]
    end
  end
end

class Button < Widget
  def initialize(x, y, w, h, label, func)
    super(x, y, w, h)
    @label = label
    @func = func
    @clicked_inside = false
  end
  def tick(args)
    # Draw back & label
    draw_back(args)
    args.outputs.labels << [@xpos + @width / 2, @ypos + @height, @label, 16, 1] + MAIN_FONT
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
        draw_back(args, 192, 255,255,255)
      else
        draw_back(args, 128 + Math.sin($tick_count / 12) * 64, 255,255,255)
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
class Menu < Widget
  def initialize(x, y, w, h, items)
    super(x, y, w, h)
    @items = items
    auto_size
    @clicked_index = -1
  end
  def auto_size
    @line_height = 24
    @padding = 2
    @width = 320 if @width.negative?
    @height = @items.length * @line_height if @height.negative?
    @xpos = 640 - @width / 2 if @xpos.negative?
    @ypos = 360 - @height / 2 if @ypos.negative?
  end
  def tick(args)
    # Background
    draw_back(args)
    mx = args.inputs.mouse.x
    my = args.inputs.mouse.y
    # Draw each option, and check if the mouse is hovering over them
    @items.reverse.each_with_index { |p, i|
      x = @xpos
      y = @ypos + i * @line_height
      args.outputs.labels << [x + @width / 2, y + @line_height, p.label, 0, 1] + MAIN_FONT
      next unless mx >= x && mx < x + @width && my >= y && my < y + @line_height

      if args.inputs.mouse.click # Started to click?
        @clicked_index = i
      elsif args.inputs.mouse.up # Released?
        if @clicked_index == i
          p.func.call # Execute this item's function
        end
      end
      # Fade in/out when hovering, make brighter when clicking
      if @clicked_index == i
        draw_hover(args, i, 192, 255,255,255)
      else
        draw_hover(args, i, 128 + Math.sin($tick_count / 12) * 64, 255,255,255)
      end
    }
    @clicked_index = -1 if args.inputs.mouse.up
  end
  def draw_hover(args, i, a = 192, r = 0, g = 128, b = 64)
    y = @ypos + i * @line_height
    args.outputs.sprites << [@xpos,y,@width,@line_height, 'sprites/white.png',0, a,r,g,b]
  end
end

class TextEntry < Widget
  attr_accessor :text
  def initialize(x, y, w, maxlen = 12, text = '')
    super(x, y, w, 32)
    @maxlen = maxlen
    @text = text
  end
  def bksp
    @text = @text[0..-2] unless @text.empty?
  end
  def tick(args)
    draw_back(args)
    kb = args.inputs.keyboard
    # Text entry
    args.inputs.text.each { |str| @text << str }
    args.inputs.text.clear
    @text = @text[0..@maxlen-1] if @text.length > @maxlen
    # Backspace
    bksp if kb.key_down.backspace
    # Draw text and blinking cursor
    args.outputs.labels << [@xpos, @ypos+32, @text, 4, 0] + MAIN_FONT
    ts = args.gtk.calcstringbox(@text, 4, 'Funstella.ttf')
    if $tick_count % 40 >= 20
      args.outputs.labels << [@xpos + ts.x, @ypos+32, '|', 4, 0] + MAIN_FONT 
    end
  end
end
