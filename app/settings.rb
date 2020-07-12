# Shows the controls in some text labels and an OK button
class SceneHelp
  def draw_line(args, y, key, what)
    args.outputs.labels << [400, y, key, 4, 0] + MAIN_FONT
    args.outputs.labels << [880, y, what, 4, 2] + MAIN_FONT
  end

  def tick(args)
    @btn_ok ||= Button.new(580, 128, 120, 48, 'OK', -> { $scene = SceneTitle.new })
    args.outputs.labels << [640, 700, 'Controls', 32, 1] + MAIN_FONT
    draw_line(args, 600, 'Left / Right', 'Move')
    draw_line(args, 560, 'Down', 'Soft Drop')
    draw_line(args, 520, 'Space Bar', 'Hard Drop')
    draw_line(args, 480, 'Z', 'Rotate Left')
    draw_line(args, 440, 'X / Up', 'Rotate Right')
    draw_line(args, 400, 'A / C', 'Hold')
    draw_line(args, 360, 'Enter', 'Pause')
    @btn_ok.tick(args)
  end
end
