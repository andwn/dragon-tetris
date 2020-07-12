# Just displays some text and an OK button
class SceneCredits
  def draw_line(args, y, key, what)
    args.outputs.labels << [200, y, key, 4, 0] + MAIN_FONT
    args.outputs.labels << [1080, y, what, 4, 2] + MAIN_FONT
  end

  def tick(args)
    @btn_ok ||= Button.new(580, 128, 120, 48, 'OK', -> { $scene = SceneTitle.new })
    args.outputs.labels << [640, 700, "Whom'st've", 32, 1] + MAIN_FONT
    draw_line(args, 600, 'Wrote the codes', '@donutgrind')
    draw_line(args, 560, 'Composed the BGM', '@algebrandon')
    draw_line(args, 520, 'Made the block sprite', '@KenneyNL')
    draw_line(args, 480, 'Created this font', '@Sikthehedgehog')
    draw_line(args, 440, "Please don't sue me", '@Tetris_Official')
    draw_line(args, 400, 'Dragons', 'dragonruby.org')
    @btn_ok.tick(args)
  end
end
