class HiScore
  attr_accessor :name, :level, :time, :score
  def initialize(name, level, time, score)
    @name = name
    @level = level
    @time = time
    @score = score
  end
  def serialize
    { entity_id: 1, name: name, level: level, time: time, score: score }
  end
  def inspect
    serialize.to_s
  end
  def to_s
    serialize.to_s
  end
end

# High Score Screen
class SceneScore
  MAX_SCORES = 16
  NAME_W = 220
  LEVEL_W = 140
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
    @input_level = level
    @input_time = time
    @input_score = score
    @state = level.positive? ? STATE_ENTRY : STATE_VIEWING
    load
  end

  def save
    $gtk.serialize_state('hiscore.txt', { entity_id: 1, list: @scores })
  end
  def load
    parsed = $gtk.deserialize_state('hiscore.txt')
    if parsed
      @scores = parsed.list
    else
      @scores = Array.new(MAX_SCORES, HiScore.new('Nobody', 1, 60*60, 100))
    end
  end

  def insert_entry(entry)
    for i in 0..MAX_SCORES-1
      if entry.score > @scores[i].score
        make_room(i)
        @scores[i] = entry
        break
      end
    end
  end
  def make_room(index)
    for i in (MAX_SCORES-1).downto(index+1)
      @scores[i] = @scores[i-1]
    end
  end

  def tick(args)
    if @state == STATE_VIEWING
      @btn_ok ||= Button.new(580, 32, 120, 48, 'OK', -> { $scene = SceneTitle.new })
      tick_view(args)
    elsif @state == STATE_ENTRY
      @name_entry ||= TextEntry.new(640-120, 400, 240)
      #@btn_bksp ||= Button.new(800, 480, 120, 48, 'Bksp', -> { @name_entry.bksp })
      @btn_done ||= Button.new(580, 32, 120, 48, 'Done', lambda {
        unless @name_entry.text.empty?
          score = HiScore.new(@name_entry.text, @input_level, @input_time, @input_score)
          insert_entry(score)
          save
        end
        @state = STATE_VIEWING
      })
      tick_entry(args)
    end
  end
  def tick_view(args)
    y = 700
    args.outputs.labels << [640, y, 'High Scores', 16, 1] + MAIN_FONT
    # Columns
    y -= 64
    args.outputs.labels << [NAME_X, y, 'Name', 4, 0] + MAIN_FONT
    args.outputs.labels << [LEVEL_X, y, 'Level', 4, 0] + MAIN_FONT
    args.outputs.labels << [TIME_X, y, 'Time', 4, 0] + MAIN_FONT
    args.outputs.labels << [SCORE_X, y, 'Score', 4, 0] + MAIN_FONT
    # Scores
    y -= 32
    @scores.each_with_index { |s, i|
      args.outputs.solids << [NAME_X, y-32, ALL_W, 32, 
                              0,159+(i.even? ? 64:0),127+(i.even? ? 64:0),255]
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
    args.outputs.labels << [640, 700, 'Name Entry', 16, 1] + MAIN_FONT
    @name_entry.tick(args)
    #@btn_bksp.tick(args)
    @btn_done.tick(args)
  end
end
