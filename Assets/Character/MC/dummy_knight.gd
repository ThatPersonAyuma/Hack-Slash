extends CharacterBody2D

@export var Speed: int = 200
@export var DashSpeed: int = 400
@export var JumpVelocity: float = -400.0
@export var Gravity: float = 1000.0
@export var ShakeAmount: float = 500.0
@export var DashEnergy: float = 100.0
@export var CamLimitLeft: int = -10000000
@export var CamLimitTop: int = -10000000
@export var CamLimitRight: int = 10000000
@export var CamLimitBottom: int = 10000000
@export var ZoomValue: float = 1.0
@export var dmg_dealt: int = 15

var can_change_animate = false
var animated_sprite_name = "idle"
var flips_h = [Vector2(1, 1), Vector2(-1, 1)]
var is_attacking = false
var is_double_attacking = false
var toggle = 1
var is_dash = false

var attack_area: Area2D
var sprite: AnimatedSprite2D
var noise := FastNoiseLite.new()
var cam: Camera2D
var dash_energy_bar: ProgressBar
var cam_base_position: Vector2

func _ready():
	sprite = $AnimatedSprite2D
	attack_area = $Area2D
	cam = $Camera2D
	dash_energy_bar = cam.get_node("CanvasLayer/ProgressBar")
	cam.limit_left = CamLimitLeft
	cam.limit_top = CamLimitTop
	cam.limit_right = CamLimitRight
	cam.limit_bottom = CamLimitBottom
	cam.zoom = Vector2(ZoomValue, ZoomValue)
	Global.Player = self

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += Gravity * delta
		if velocity.y > 0:
			animated_sprite_name = "fall"
			can_change_animate = false
		move_and_slide()

	if Global.CanCharMove:
		if Input.is_action_just_pressed("dash") and DashEnergy >= 25:
			DashEnergy -= 25
			dash_input()
		if not is_dash:
			attack_input()
			if not is_attacking:
				character_move(delta)
		else:
			move_and_slide()
	else:
		animated_sprite_name = "idle"

	sprite.play(animated_sprite_name)
	dash_energy_bar.value = Global.McHealth

func dash_input() -> void:
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	is_dash = true
	animated_sprite_name = "dash"
	if direction != 0:
		sprite.flip_h = direction < 0
	velocity.x = -DashSpeed if sprite.flip_h else DashSpeed
	move_and_slide()
	await get_tree().create_timer(0.2).timeout
	velocity.x = 0
	is_dash = false

func character_move(delta):
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if is_on_floor():
		if Input.is_action_pressed("ui_accept"):
			can_change_animate = false
			velocity.y = JumpVelocity
			animated_sprite_name = "jump"
		else:
			can_change_animate = true
	if dir != 0:
		attack_area.scale = flips_h[1] if dir < 0 else flips_h[0]
		sprite.flip_h = dir < 0
	velocity.x = dir * Speed
	if can_change_animate:
		animated_sprite_name = "run" if dir != 0 else "idle"
	move_and_slide()

func attack_input():
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			attack()
			velocity.x = 0
		else:
			is_double_attacking = true

func attack():
	animated_sprite_name = "attackComboNoMove"
	is_attacking = true
	attack_area.monitoring = true
	check_attack_area()
	await get_tree().create_timer(0.4).timeout
	if is_double_attacking:
		check_attack_area()
		await get_tree().create_timer(0.4).timeout
		attack_area.monitoring = false
		is_attacking = false
		is_double_attacking = false
	else:
		attack_area.monitoring = false
		is_attacking = false

func check_attack_area():
	var overlapped = attack_area.get_overlapping_areas()
	print("checked ", overlapped.size())
	if overlapped.size() > 0:
		#shake_effect_async()
		print("Hitted enemy")
#
#func _on_area_2d_body_area(body: Node2D):
	#shake_effect_async()


#func shake_effect_async():
	#freeze_scene(0.005, 0.1)
#
#func freeze_scene(time_scale: float, duration: float):
	#Engine.time_scale = time_scale
	#var timer = get_tree().create_timer(duration * time_scale)
	#var t = 0
	#while t < duration:
		#cam.offset = Vector2(cam.position.x + 3 * toggle, cam.position.y + 3 * toggle)
		#toggle *= -1
		#await get_tree().create_timer(0.075).timeout
		#t += 0.075
	#cam.offset = Vector2.ZERO
	#Engine.time_scale = 1.0


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	area.get_parent().get_parent().call("take_damage", dmg_dealt)
	print("Area name: ", area.get_parent().get_parent().name)
	print("Hitted enemy") # Replace with function body.
