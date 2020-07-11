class SceneCredits
  def initialize

  end
  def tick(args)
    @btn_ok ||= Button.new(600, 40, 80, 32, "OK", lambda { $scene = SceneTitle.new })
    args.outputs.labels << [640, 540, "Whom'st've", 32, 1] + MAIN_FONT
    @btn_ok.tick(args)
  end
end

