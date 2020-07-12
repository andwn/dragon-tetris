require 'app/credits.rb'
require 'app/gui.rb'
require 'app/hiscore.rb'
require 'app/objects.rb'
require 'app/game.rb'
require 'app/settings.rb'
require 'app/title.rb'

def timestr(time)
  ss = (time / 60) % 60
  mm = (time / 60 / 60) % 60
  hh = (time / 60 / 60 / 60)
  ('%i' % hh) + ':' + ('%02i' % mm) + ':' + ('%02i' % ss)
end

$gtk.reset
$gtk.set_window_title 'Dragon Tetris'
$tick_count = 0
$scene = SceneTitle.new

def tick(args)
  exit(0) if $scene.nil?
  $scene.tick(args)
  $tick_count += 1
end
