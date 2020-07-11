class HiScore
  attr_accessor :name, :level, :time, :score
  def initialize(name, level, time, score)
    @name = name
    @level = level
    @time = time
    @score = score
  end
end

# High Score Screen
class SceneScore
  MAX_SCORES = 16

  NAME_W = 180
  LEVEL_W = 180
  TIME_W = 180
  SCORE_W = 240
  ALL_W = NAME_W + LEVEL_W + TIME_W + SCORE_W

  NAME_X = 240
  LEVEL_X = NAME_X + NAME_W
  TIME_X = LEVEL_X + LEVEL_W
  SCORE_X = TIME_X + TIME_W

  STATE_VIEWING = 0
  STATE_ENTRY = 1

  def initialize(level = 0, time = 0, score = 0)
    @state = STATE_VIEWING
    @input_name = ''
    @input_level = level
    @input_time = time
    @input_score = score
    if level > 0
      @state = STATE_ENTRY
    end
    load
  end
  def save
    $gtk.serialize_state('hiscore.txt', @scores)
  end
  def load
    @scores = $gtk.deserialize_state('hiscore.txt')
    default unless @scores
  end
  def default
    @scores = Array.new(MAX_SCORES, HiScore.new('AAA', 1, 60*60, 1000))
  end
  def tick(args)
    if @state == STATE_VIEWING
      @btn_ok ||= Button.new(600, 40, 80, 32, "OK", lambda { $scene = SceneTitle.new })
      tick_view(args)
    elsif @state == STATE_ENTRY
      @btn_done ||= Button.new(600, 40, 80, 32, "Done", lambda { @state = STATE_VIEWING })
      tick_entry(args)
    end
  end
  def tick_view(args)
    y = 700
    # Title
    args.outputs.labels << [640, y, "High Scores", 16, 1] + MAIN_FONT
    # Columns
    y -= 64
    args.outputs.labels << [NAME_X, y, "Name", 4, 0] + MAIN_FONT
    args.outputs.labels << [LEVEL_X, y, "Level", 4, 0] + MAIN_FONT
    args.outputs.labels << [TIME_X, y, "Time", 4, 0] + MAIN_FONT
    args.outputs.labels << [SCORE_X, y, "Score", 4, 0] + MAIN_FONT
    # Scores
    y -= 32
    @scores.each_with_index { |s, i|
      args.outputs.solids << [NAME_X, y-32, ALL_W, 32, 0,159+(i.even??64:0),127+(i.even??64:0),255]
      args.outputs.labels << [NAME_X, y, s.name, 4, 0] + MAIN_FONT
      args.outputs.labels << [LEVEL_X, y, s.level.to_s, 4, 0] + MAIN_FONT
      args.outputs.labels << [TIME_X, y, timestr(s.time), 4, 0] + MAIN_FONT
      args.outputs.labels << [SCORE_X, y, s.score.to_s, 4, 0] + MAIN_FONT
      y -= 32
    }
    # OK Button
    @btn_ok.tick(args)
  end
  def tick_entry(args)
    args.outputs.labels << [640, 700, "Name Entry", 16, 1] + MAIN_FONT
    # Done Button
    @btn_done.tick(args)
  end
end

