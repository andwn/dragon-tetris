require 'app/gui.rb'
require 'app/objects.rb'
require 'app/scenes.rb'

$tick_count = 0
$scene = SceneTitle.new

def tick(args)
  exit(0) if $scene == nil
  $scene.tick(args)
  $tick_count += 1
end
