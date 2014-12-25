extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"

export var Accel = Vector2(0,0)
var v = Vector2(0,0)

var vmax = Vector2(200,200)

var g = 500
var friction = 1600
var air_friction = 50
var facing = 1.0 # setget facing_set

func facing_set(val):
	facing = val
	get_node("AnimatedSprite").set_flip_h(facing < 0)

func _ready():
	get_node("AnimationPlayer").set_current_animation("stand")
	set_fixed_process(true)
	
func in_air():
	var anim = get_node("AnimationPlayer").get_current_animation()
	return anim == "jump" or anim == "pre-jump" or anim == "fall" or anim == "pre-fall"

func _fixed_process(dt):
	#get_node("AnimationPlayer").set_current_animation("stand")
	#pass
	v.y += dt * g
	
	var animation_player = get_node("AnimationPlayer")

	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var down = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_pressed("jump")

	var anim = animation_player.get_current_animation()
	
	# on_process
	if (left or right) and anim == "stand":
		animation_player.set_current_animation("walk")
	if in_air():
		if right:
			facing_set(1)
			v.x += 6
		if left:
			facing_set(-1)
			v.x -= 6

	# on_ctrl_down
	if down and (anim == "stand" or anim == "walk"):
		animation_player.set_current_animation("pre-crouch")
	
	# on_process_crouch
	if anim == "crouch":
		if not down:
			animation_player.set_current_animation("post-crouch")

	# on_process_walk
	if anim == "walk":
		if not left and not right:
			animation_player.set_current_animation("stand")
		else:
			if right:
				facing_set(1)
			if left:
				facing_set(-1)

	# on_ctrl_jump
	if jump and (anim == "stand" or anim == "walk"):
		animation_player.set_current_animation("pre-jump")
	
	# on_process_jump
	if anim == "jump" or anim == "pre-jump":
		if v.y >= 0:
			animation_player.set_current_animation("pre-fall")
		if jump:
			v.y -= 600
		else:
			animation_player.set_current_animation("pre-fall")
	
	# handle kinematics

	v.x += Accel.x * facing * dt
	anim = animation_player.get_current_animation()

	var s = Vector2(sign(v.x), sign(v.y))
	# friction
	if in_air():
		v.y = max(abs(v.y)-air_friction*dt, 0)*s.y
		v.x = max(abs(v.x)-air_friction*dt, 0)*s.x
	else:
		v.x = max(abs(v.x)-friction*dt, 0)*s.x

	v.x = min(abs(v.x), abs(vmax.x))*s.x
	v.y = min(abs(v.y), abs(vmax.y))*s.y

	
	var collide_feet = false

	var dr = v * dt
	dr = move(dr)
	if (is_colliding()):
		var n = get_collision_normal()
		dr = n.slide(dr) 
		v = n.slide(v)
		move(dr)
		collide_feet = n.y < -0.9

	# on_collide_feet
	if (anim == "pre-fall" or anim == "fall") and collide_feet:
		animation_player.set_current_animation("stand")
