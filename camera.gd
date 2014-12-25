
extends Camera2D

# member variables here, example:
# var a=2
# var b="textvar"

var margin = Vector2(2,2)
var smooth = Vector2(4,4)

var camera_max = Vector2(800,240)
var camera_min = Vector2(320,0)

func _ready():
	set_fixed_process(true)

func _fixed_process(dt):
	var player_pos = get_parent().get_node("player").get_pos()
	var camera_pos = get_pos()
	
	var target = Vector2(camera_pos.x, camera_pos.y)
	
	if abs(player_pos.x - camera_pos.x) > margin.x:
		target.x = lerp(camera_pos.x, player_pos.x, smooth.x * dt)
	
	if abs(player_pos.y - camera_pos.y) > margin.y:
		target.y = lerp(camera_pos.y, player_pos.y, smooth.y * dt)

	target.x = clamp(target.x, camera_min.x, camera_max.x)
	target.y = clamp(target.y, camera_min.y, camera_max.y)
	
	set_pos(target)
