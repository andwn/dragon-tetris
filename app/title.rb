class SceneTitle
  def initialize
    @menu = Menu.new(-1, 240, 200, -1, [
        MenuItem.new("Game Start", lambda { $scene = SceneGame.new }),
        MenuItem.new("High Scores", lambda { $scene = SceneScore.new }),
        MenuItem.new("Settings", lambda { $scene = SceneSettings.new }),
        MenuItem.new("Credits", lambda { $scene = SceneCredits.new }),
        MenuItem.new("Exit", lambda { $scene = nil }),
    ])
    for i in 1..20
      @dragons += [[rand(1280), rand(720),
                    64 + rand(128), 50 + rand(101), 'dragonruby.png', 0]]
      @speeds += [-7 + rand(16)]
    end
  end
  def tick(args)
    @dragons.each_with_index { |d, i|
      d[5] += @speeds[i]
      args.outputs.sprites << d
    }
    args.outputs.labels << [640, 540, "Tetris!", 32, 1] + MAIN_FONT
    @menu.tick(args)
  end
end
