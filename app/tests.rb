# For advanced users:
# You can put some quick verification tests here, any method
# that starts with the `test_` will be run when you save this file.
#
# ./dragonruby.exe tetris --eval app/tests.rb
# Press ~ to check the console

# Verify O block (4x4) is unchanged when rotating in both directions
def test_rot_O(args, assert)
  tet = Tetromino.new(0, 0, 'O')
  tet.rot_left
  assert.true! tet.blocks == [0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0], "FAIL: O block rot_left"
  tet.rot_right
  assert.true! tet.blocks == [0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0], "FAIL: O block rot_right"
  puts "PASS: O block rotation"
end

# Make sure I block (4x4) is rotated correctly
def test_rot_I(args, assert)
  tet = Tetromino.new(0, 0, 'I')
  tet.rot_left
  assert.true! tet.blocks == [0,0,0,0, 0,0,0,0, 1,1,1,1, 0,0,0,0], "FAIL: I block rot_left 1\n -> " + tet.blocks.to_s
  tet.rot_left
  assert.true! tet.blocks == [0,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0], "FAIL: I block rot_left 2\n -> " + tet.blocks.to_s
  tet.rot_left
  assert.true! tet.blocks == [0,0,0,0, 1,1,1,1, 0,0,0,0, 0,0,0,0], "FAIL: I block rot_left 3\n -> " + tet.blocks.to_s
  tet.rot_left
  assert.true! tet.blocks == [0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0], "FAIL: I block rot_left 4\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,0,0,0, 1,1,1,1, 0,0,0,0, 0,0,0,0], "FAIL: I block rot_right 1\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0], "FAIL: I block rot_right 2\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,0,0,0, 0,0,0,0, 1,1,1,1, 0,0,0,0], "FAIL: I block rot_right 3\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0], "FAIL: I block rot_right 4\n -> " + tet.blocks.to_s
  puts "PASS: I block rotation"
end

# Make sure T block (3x3) is rotated correctly
def test_rot_T(args, assert)
  tet = Tetromino.new(0, 0, 'T')
  tet.rot_left
  assert.true! tet.blocks == [0,1,0,0, 1,1,0,0, 0,1,0,0, 0,0,0,0], "FAIL: T block rot_left 1\n -> " + tet.blocks.to_s
  tet.rot_left
  assert.true! tet.blocks == [0,0,0,0, 1,1,1,0, 0,1,0,0, 0,0,0,0], "FAIL: T block rot_left 2\n -> " + tet.blocks.to_s
  tet.rot_left
  assert.true! tet.blocks == [0,1,0,0, 0,1,1,0, 0,1,0,0, 0,0,0,0], "FAIL: T block rot_left 3\n -> " + tet.blocks.to_s
  tet.rot_left
  assert.true! tet.blocks == [0,1,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0], "FAIL: T block rot_left 4\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,1,0,0, 0,1,1,0, 0,1,0,0, 0,0,0,0], "FAIL: T block rot_right 1\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,0,0,0, 1,1,1,0, 0,1,0,0, 0,0,0,0], "FAIL: T block rot_right 2\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,1,0,0, 1,1,0,0, 0,1,0,0, 0,0,0,0], "FAIL: T block rot_right 3\n -> " + tet.blocks.to_s
  tet.rot_right
  assert.true! tet.blocks == [0,1,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0], "FAIL: T block rot_right 4\n -> " + tet.blocks.to_s
  puts "PASS: T block rotation"
end

puts "running tests"
$gtk.reset 100
#$gtk.log_level = :off
$gtk.tests.start
