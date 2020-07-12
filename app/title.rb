class TitleTetromino
  def initialize
    reset
  end
  def reset
    @x = rand(1280 - 128)
    @y = 720 + 128
    @tet = Tetromino.new(0, 0, %w[O I J L S Z T].sample)
    @tet.rot_left if [true, false].sample
    @tet.rot_right if [true, false].sample
  end
  def tick(args)
    @y -= 1
    reset if @y <= 0
    @tet.draw(@x, @y-32, args)
  end
end

class SceneTitle
  def initialize
    @menu = Menu.new(-1, 240, 200, -1, [
        MenuItem.new('Game Start', -> { $scene = SceneGame.new }),
        MenuItem.new('High Scores', -> { $scene = SceneScore.new }),
        MenuItem.new('Controls', -> { $scene = SceneHelp.new }),
        MenuItem.new('Credits', -> { $scene = SceneCredits.new }),
        MenuItem.new('Exit', -> { $scene = nil })
      ])
  end
  def tick(args)
    @ticks ||= 0
    @ticks += 1
    @tets ||= [TitleTetromino.new]
    @tets += [TitleTetromino.new] if @tets.length < 30 && (@ticks % 60).zero?
    @tets.each { |t| t.tick(args) }
    args.outputs.labels << [640, 540, 'Tetris!', 32, 1] + MAIN_FONT
    @menu.tick(args)
  end
end
