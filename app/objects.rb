class Tetromino
  attr_accessor :x, :y, :type, :blocks, :color
  def self.get_blocks(type)
    case type
    when 'O' then [0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0]
    when 'I' then [0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0]
    when 'J' then [0,1,1,0, 0,1,0,0, 0,1,0,0, 0,0,0,0]
    when 'L' then [0,1,0,0, 0,1,0,0, 0,1,1,0, 0,0,0,0]
    when 'S' then [0,1,1,0, 1,1,0,0, 0,0,0,0, 0,0,0,0]
    when 'Z' then [1,1,0,0, 0,1,1,0, 0,0,0,0, 0,0,0,0]
    when 'T' then [0,1,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0]
    else Array.new(16,0)
    end
  end
  def self.get_color(type)
    case type
    when 'O' then [255,255,0]
    when 'I' then [0,255,255]
    when 'J' then [0,0,255]
    when 'L' then [255,128,0]
    when 'S' then [0,255,0]
    when 'Z' then [255,0,0]
    when 'T' then [128,0,255]
    else [128,128,128]
    end
  end
  def initialize(x, y, type)
    @x = x
    @y = y
    @type = type
    @blocks = Tetromino.get_blocks(type)
    @color = Tetromino.get_color(type)
  end
  def copy
    t = Tetromino.new(@x, @y, @type)
    t.blocks = @blocks.dup
    t
  end
  def rot_left
    newb = Array.new(16, 0)
    size = %w[I O].include?(@type) ? 3 : 2
    for y in 0..size
      for x in 0..size
        newb[y*4 + x] = @blocks[x*4 + (size-y)]
      end
    end
    @blocks = newb
  end
  def rot_right
    newb = Array.new(16, 0)
    size = %w[I O].include?(@type) ? 3 : 2
    for y in 0..size
      for x in 0..size
        newb[y*4 + x] = @blocks[(size-x)*4 + y]
      end
    end
    @blocks = newb
  end
  def draw(xx, yy, args, skip=0, size=32)
    for y in 0..3
      if skip.negative?
        skip += 1
        next
      end
      for x in 0..3
        if @blocks[y*4 + x].positive?
          args.outputs.sprites << [xx+(x+@x)*size, yy-(y+@y)*size, size, size, 'sprites/block.png', 0, 255] + @color
        end
      end
    end
  end
end

# Random Bag - holds 1 of each type of tetromino in a random order
# the game pops each until it is empty, at which point it will refill in random order again
class RandomBag
  def initialize
    refill
  end
  def refill
    @tetrominos = %w[O I J L S Z T].shuffle!
  end
  def peek
    @tetrominos.peek
  end
  def pop
    val = @tetrominos.pop
    refill if @tetrominos.empty?
    val
  end
end
