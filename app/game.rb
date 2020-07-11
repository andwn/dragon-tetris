class SceneGame
  # Size of the stage, note that tetrominos can exist higher than the top of the stage
  STAGE_W = 10
  STAGE_H = 20
  # Number of lines to clear before going to the next level
  LINES_PER_LEVEL = 20
  # Gravity for level 1, it's the number of frames until the tetromino falls 1 block width
  INITIAL_GRAVITY = 60
  # Gravity while holding down
  DROP_GRAVITY = 4
  # Minimum time to wait when a tetromino is about to hit the ground
  LOCK_DELAY = 30
  # Delayed auto shift: There is an initial SHIFT_DELAY when holding left/right before
  # the tetromino continues to move left/right every SHIFT_SPEED frames
  # Similar to when you hold a key in a text editor and have to wait for the first repetition
  SHIFT_DELAY = 20
  SHIFT_SPEED = 4
  # Score rewards
  SCORE_SINGLE = 100
  SCORE_DOUBLE = 300
  SCORE_TRIPLE = 500
  SCORE_TETRIS = 800
  SCORE_EZ_TSPIN = 100
  SCORE_EZ_TSPIN_SINGLE = 200
  SCORE_TSPIN = 400
  SCORE_TSPIN_SINGLE = 800
  SCORE_TSPIN_DOUBLE = 1200
  # Points for these two are awarded per block before hitting the ground that was dropped
  SCORE_SOFT_DROP = 1
  SCORE_HARD_DROP = 2
  # Game states
  STATE_PLAYING = 0
  STATE_PAUSED = 1
  STATE_GAMEOVER = 2

  def initialize
    reset_game
  end
  def reset_game
    @state = STATE_PLAYING
    @stage = Array.new(STAGE_W) { Array.new(STAGE_H, ' ') }
    @bag = RandomBag.new
    @queue = Array.new(5)
    for i in 0..4
      @queue[i] = Tetromino.new(0, 0, @bag.pop)
    end
    @hold = nil

    @time = 0
    @fall_ticks = 0
    @score = 0
    @level = 1
    @lines_cleared = 0
    @total_lines = 0

    @just_held = false
    @dropping = false
    @autoshift = SHIFT_DELAY
    @shiftdir = 0
    reset_speed
    next_tetromino
  end
  # Handle moving tetrominos
  def move_tetromino_left
    t = @tet.copy
    t.x -= 1
    if validate_tetromino(t)
      @tet = t
      @fall_ticks = 0 if check_lock(@tet)
    end
  end
  def move_tetromino_right
    t = @tet.copy
    t.x += 1
    if validate_tetromino(t)
      @tet = t
      @fall_ticks = 0 if check_lock(@tet)
    end
  end
  def move_tetromino_down
    if check_lock(@tet)
      lock_tetromino
    else
      @tet.y += 1
      @score += SCORE_SOFT_DROP if @dropping
    end
    @fall_ticks = 0
  end
  # Handle rotating tetrominos
  def rotate_tetromino_left
    t = @tet.copy
    t.rot_left
    if validate_tetromino(t) || wall_kick(t)
      @tet = t
      @fall_ticks = 0 if check_lock(@tet)
    end
  end
  def rotate_tetromino_right
    t = @tet.copy
    t.rot_right
    if validate_tetromino(t) || wall_kick(t)
      @tet = t
      @fall_ticks = 0 if check_lock(@tet)
    end
  end

  def hard_drop
    until check_lock(@tet)
      @tet.y += 1
      @score += SCORE_HARD_DROP
    end
    lock_tetromino
  end

  def hold_tetromino
    return if @just_held
    if @hold
      temp = @tet
      @tet = Tetromino.new(3, -2, @hold.type)
      @hold = Tetromino.new(0, 0, temp.type)
    else
      @hold = Tetromino.new(0, 0, @tet.type)
      next_tetromino
    end
    @just_held = true
  end
  # Place tetromino to the stage
  def lock_tetromino
    # Copy blocks over to the stage grid
    for y in 0..3
      for x in 0..3
        if @tet.blocks[y*4 + x] > 0
          next if @tet.y+y < 0 # Don't overflow top
          @stage[@tet.x+x][@tet.y+y] = @tet.type
        end
      end
    end
    # Clear completed rows
    rows_cleared = 0
    for y in 0..STAGE_H-1
      filled = 0
      for x in 0..STAGE_W-1
        filled += 1 if @stage[x][y] != ' '
      end
      if filled == STAGE_W
        clear_row(y)
        rows_cleared += 1
      end
    end
    # Calculate score rewards
    reward = 0
    # 3-corner T-spin?
    if @tet.type == 'T' && detect_tspin(@tet)
      reward += SCORE_TSPIN * @level if rows_cleared == 0
      reward += SCORE_TSPIN_SINGLE * @level if rows_cleared == 1
      reward += SCORE_TSPIN_DOUBLE * @level if rows_cleared == 2
    else
      # Immobile (EZ) T-spin?
      if @tet.type == 'T' && wall_kick(@tet.dup)
        reward += SCORE_EZ_TSPIN * @level if rows_cleared == 0
        reward += SCORE_EZ_TSPIN_SINGLE * @level if rows_cleared == 1
      else
        # No T-spin
        reward += SCORE_SINGLE * @level if rows_cleared == 1
        reward += SCORE_DOUBLE * @level if rows_cleared == 2
        reward += SCORE_TRIPLE * @level if rows_cleared == 3
        reward += SCORE_TETRIS * @level if rows_cleared == 4
      end
    end
    @score += reward
    # Update lines cleared total and level
    @lines_cleared += rows_cleared
    @total_lines += rows_cleared
    if @lines_cleared >= LINES_PER_LEVEL
      @lines_cleared -= LINES_PER_LEVEL
      @level += 1
    end
    next_tetromino
  end
  # Checks if the given tetromino is overlapping anything
  def validate_tetromino(t)
    for y in 0..3
      for x in 0..3
        next unless t.blocks[y*4 + x] > 0
        xx = t.x + x
        yy = t.y + y
        return false if xx < 0 || xx >= STAGE_W || yy >= STAGE_H
        return false if yy >= 0 && @stage[xx][yy] != ' '
      end
    end
    true
  end
  # Check if the given tetromino can be moved down any further
  def check_lock(t)
    p = t.dup
    p.y += 1
    !validate_tetromino(p)
  end

  def detect_tspin(t)
    corners = 0
    corners += 1 if @stage[t.x, t.y] != ' '
    corners += 1 if @stage[t.x+2, t.y] != ' '
    corners += 1 if @stage[t.x+2, t.y+2] != ' '
    corners += 1 if @stage[t.x, t.y+2] != ' '
    corners == 3
  end

  def wall_kick(t)
    # Left
    t.x -= 1
    return true if validate_tetromino(t)
    # Right
    t.x += 2
    return true if validate_tetromino(t)
    # Up
    t.x -= 1
    t.y -= 1
    return true if validate_tetromino(t)
    # Unable to wall kick, all directions invalid
    t.y += 1
    false
  end

  def reset_speed
    @fall_time = INITIAL_GRAVITY - (@level * 5)
    @fall_time = DROP_GRAVITY if @fall_time < DROP_GRAVITY
  end

  def phantom_tetromino(t)
    p = t.dup
    p.y += 1 until check_lock(p)
    p.color = Tetromino.get_color(' ')
    p
  end

  def clear_row(row)
    # Collapse rows down
    if row >= 1
      for y in row.downto(1)
        for x in 0..STAGE_W-1
          @stage[x][y] = @stage[x][y-1]
        end
      end
    end
    # Clear first row
    for x in 0..STAGE_W-1
      @stage[x][0] = ' '
    end
  end

  def next_tetromino
    @tet = @queue.pop
    @queue.unshift(Tetromino.new(0, 0, @bag.pop))
    @tet.x = 3
    @tet.y = -2
    @just_held = false
    # New tetromino overlaps with a block? Game over!
    @state = STATE_GAMEOVER unless validate_tetromino(@tet)
    reset_speed
  end

  def start_music(args)
    @music_playing ||= false
    unless @music_playing
      # Hey, wanna listen to some tunes?
      args.outputs.sounds << 'sound/tetris.ogg'
      @music_playing = true
    end
  end
  def stop_music(args)
    @music_playing ||= false
    if @music_playing
      # BUT HOW???
      @music_playing = false
    end
  end

  def tick(args)
    if @state == STATE_PLAYING
      tick_playing(args)
    elsif @state == STATE_PAUSED
      tick_paused(args)
    elsif @state == STATE_GAMEOVER
      tick_gameover(args)
    end
    draw_hud(args)
    draw_stage(args)
  end
  def tick_playing(args)
    @time += 1
    kb = args.inputs.keyboard
    if kb.key_down.enter
      @state = STATE_PAUSED
    else
      start_music(args)
      # Moving left and right
      if kb.key_down.left
        move_tetromino_left
        @shiftdir = -1
        @autoshift = SHIFT_DELAY
      elsif kb.key_down.right
        move_tetromino_right
        @shiftdir = 1
        @autoshift = SHIFT_DELAY
      end
      # Delayed auto shift
      if (kb.right ? 1:0) - (kb.left ? 1:0) == @shiftdir
        @autoshift -= 1
        if @autoshift == 0
          @autoshift = SHIFT_SPEED
          move_tetromino_left if kb.left
          move_tetromino_right if kb.right
        end
      end
      # Rotation
      rotate_tetromino_left if kb.key_down.z
      rotate_tetromino_right if kb.key_down.x
      rotate_tetromino_right if kb.key_down.up
      # Hard drop
      hard_drop if kb.key_down.space
      # Hold
      hold_tetromino if kb.key_down.shift
      # Soft drop
      if kb.key_down.down
        @fall_time = DROP_GRAVITY
        @dropping = true
        move_tetromino_down
      elsif kb.key_up.down
        reset_speed
        @dropping = false
      end
      # Push tetromino down according to current gravity
      @fall_ticks += 1
      if @fall_ticks >= @fall_time
        # If the tetromino is about to lock, always wait at least a half second
        if !check_lock(@tet) || @fall_ticks >= LOCK_DELAY || kb.down
          move_tetromino_down
        end
      end
    end
  end
  def tick_paused(args)
    if args.inputs.keyboard.key_down.enter
      @state = STATE_PLAYING
    else
      args.outputs.labels << [640, 540, "PAUSED", 32, 1] + WHITE_FONT
    end
  end
  def tick_gameover(args)
    stop_music(args)
    @btn_ok ||= Button.new(600, 40, 80, 32, "OK",
                           lambda { $scene = SceneScore.new(@level, @time, @score) })
    args.outputs.labels << [640, 540, "GAME OVER!", 32, 1] + WHITE_FONT
    @btn_ok.tick(args)
  end

  STAGE_X = 640-160
  STAGE_Y = 32
  def draw_stage(args)
    # Background / border
    args.outputs.borders << [STAGE_X-1, STAGE_Y-1, STAGE_W*32+2, STAGE_H*32+2, 255,255,255,255]
    args.outputs.solids << [STAGE_X, STAGE_Y, STAGE_W*32, STAGE_H*32, 31,31,31,255]
    # Blocks
    for y in 0..STAGE_H-1
      for x in 0..STAGE_W-1
        if @stage[x][y] != ' '
          color = Tetromino.get_color(@stage[x][y])
          args.outputs.sprites << [STAGE_X+x*32, STAGE_Y+(STAGE_H-y)*32-32,
                                   32, 32, 'sprites/block.png', 0, 255] + color
        end
      end
    end
    # Phantom tetromino
    phantom_tetromino(@tet).draw(STAGE_X, STAGE_Y+STAGE_H*32-32, args)
    # Current tetromino
    @tet.draw(STAGE_X, STAGE_Y+STAGE_H*32-32, args, @tet.y) if @tet
  end

  HOLD_X = STAGE_X - 240
  HOLD_Y = 700
  SCORE_X = STAGE_X - 240
  SCORE_Y = 500
  NEXT_X = STAGE_X + STAGE_W*32 + 32
  NEXT_Y = 700
  def draw_hud(args)
    # Hold
    args.outputs.labels << [HOLD_X, HOLD_Y, "HOLD:", 4, 0] + MAIN_FONT
    @hold.draw(HOLD_X, HOLD_Y-64, args) if @hold
    # Score & High Score
    args.outputs.labels << [SCORE_X,     SCORE_Y, "SCORE:", 4, 0] + MAIN_FONT
    args.outputs.labels << [SCORE_X+200, SCORE_Y-32, @score.to_s, 4, 2] + MAIN_FONT
    #args.outputs.labels << [SCORE_X,     SCORE_Y-128, "HI SCORE:", 4, 0] + MAIN_FONT
    #args.outputs.labels << [SCORE_X+200, SCORE_Y-176, @hiscore.to_s, 4, 2] + MAIN_FONT
    # Level & Lines
    args.outputs.labels << [SCORE_X,     SCORE_Y-80, "LEVEL:", 4, 0] + MAIN_FONT
    args.outputs.labels << [SCORE_X+200, SCORE_Y-112, @level.to_s, 4, 2] + MAIN_FONT
    args.outputs.labels << [SCORE_X,     SCORE_Y-144, "NEXT:", 4, 0] + MAIN_FONT
    args.outputs.labels << [SCORE_X+200, SCORE_Y-176, (LINES_PER_LEVEL - @lines_cleared).to_s, 4, 2] + MAIN_FONT
    args.outputs.labels << [SCORE_X,     SCORE_Y-208, "TOTAL:", 4, 0] + MAIN_FONT
    args.outputs.labels << [SCORE_X+200, SCORE_Y-240, @total_lines.to_s, 4, 2] + MAIN_FONT
    args.outputs.labels << [SCORE_X,     SCORE_Y-272, "TIME:", 4, 0] + MAIN_FONT
    args.outputs.labels << [SCORE_X+200, SCORE_Y-304, timestr(@time), 4, 2] + MAIN_FONT
    # Next
    args.outputs.labels << [NEXT_X, NEXT_Y, "NEXT:", 4, 0] + MAIN_FONT
    y = NEXT_Y - 64
    @queue.reverse_each { |t|
      xoff = 0
      yoff = 0
      tt = t.dup
      tt.rot_right if ['I'].include?(tt.type)
      tt.rot_left if ['L', 'J'].include?(tt.type)
      xoff -= 12 if ['O'].include?(tt.type)
      yoff += 12 if ['O', 'I'].include?(tt.type)
      tt.draw(NEXT_X+xoff, y+yoff, args, 0, 24)
      y -= 72
    }
  end
end
