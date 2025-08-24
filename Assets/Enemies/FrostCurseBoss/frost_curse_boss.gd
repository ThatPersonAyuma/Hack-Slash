extends CharacterBody2D
@onready var AttackingArea: Area2D = $AttackingArea
@onready var PivotNode: Node2D = $Node2D
@onready var rayNode2D: Node2D = $RayCastFloor
@onready var animatedSprite2D: AnimatedSprite2D = $Node2D/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer
@onready var rangedAnimatedSprited: AnimatedSprite2D = $RangedAttack/AnimatedSprite2D2
@onready var rangedAttackArea: Area2D = $AttackingArea
@onready var ranged_raycast = $RayCast2D
@export var Gravity: float = 1000
@export var Speed: float  = 50
@export var Direction: int = -1
@export var WalkingColdown: float = 1.5
@export var dmg_dealt:int = 10
@export var ChargeColdown: float = 8
@export var HP_pool: int = 100
var ChargeRunningColdown: float = 0
var WalkingColdownTimer: float = 0
var AnimatedName: String ="idle"
var IsWalk: bool = false
var IsAttacking: bool = false
var BodyEntered: bool = false
var pst: int
var IsRanged: bool = false 
var IsAlive:bool = true
#var attackArea: Area2D { get; set; }
#var body: CollisionShape2D = $Node2D/CharacterBody2D/Body



func _ready():
	rayNode2D.connect("NotCollided", Callable(self, "_on_ray_not_collided"))
	rangedAnimatedSprited.get_parent().remove_child(rangedAnimatedSprited)
	get_node("/root").add_child.call_deferred(rangedAnimatedSprited)

func _physics_process(delta: float) -> void:
	if (IsAlive):
		var Velocity:Vector2 = velocity;
		var IsOnFloorVal:bool = is_on_floor();
		if (!IsOnFloorVal):
			Velocity.y += Gravity * delta
		else:
			#check_player_in_range_area()
			if (BodyEntered && !IsAttacking && ChargeRunningColdown >= ChargeColdown/2):
				#if (Direction==-1 && $EndPointLeft/RayCast2D.is_colliding()):
				pst = (Global.Player.global_position.x - global_position.x) * Direction 
				var direction_result: int = Direction
				if (pst<0):
					direction_result = Direction * -1
				print(pst)
				if (pst>-28 && pst<31):
					if (direction_result != Direction):
						_on_ray_not_collided()
					animation_player.play("meleeAttack")
					Velocity.x = 0;
					IsAttacking = true
					ChargeRunningColdown = 0
				elif ((direction_result==-1 && $EndPointLeft/RayCast2D.is_colliding()) || (direction_result==1&&$EndPointRight/RayCast2D.is_colliding())):
					if (direction_result != Direction):
						_on_ray_not_collided()
					animation_player.play("attack")
					Velocity.x = 0;
					IsAttacking = true
					ChargeRunningColdown = 0
			else:
				ChargeRunningColdown += delta
			if (!IsAttacking):
				if (WalkingColdownTimer > 0):
					WalkingColdownTimer -= delta
				else:
					IsWalk = !IsWalk;
					WalkingColdownTimer = WalkingColdown;
				if (IsWalk):
					Velocity.x = Direction * Speed;
					AnimatedName = "run";
				else:
					Velocity.x = 0;
					AnimatedName = "idle";
				animatedSprite2D.play(AnimatedName);
		velocity = Velocity;
		#print("Body: ", BodyEntered);
		#print("Direction: ", Direction," left: ", $EndPointLeft/RayCast2D.is_colliding(), " right: ", $EndPointRight/RayCast2D.is_colliding())
		move_and_slide();
	#print(Global.McHealth)

func check_player_in_range_area():
	var distance = global_position.distance_to(Global.Player.global_position)
	ranged_raycast.rotate((Global.Player.global_position - global_position).angle() - ranged_raycast.rotation)
	var collider = ranged_raycast.get_collider()
	if collider == Global.Player && !IsRanged:
		print("in range")
		IsRanged = true
		rangedAnimatedSprited.visible = true
		rangedAnimatedSprited.play("ranged_attack")
		rangedAnimatedSprited.global_position = Global.Player.global_position
		await get_tree().create_timer(0.625).timeout
		rangedAttackArea.monitoring = true
		await get_tree().create_timer(0,375).timeout
		rangedAttackArea.monitoring = false
		await get_tree().create_timer(0.375).timeout
		rangedAnimatedSprited.stop()
		rangedAnimatedSprited.visible = false
		rangedAnimatedSprited.global_position = global_position
		IsRanged = false

func take_damage(dmg_taken: int):
	HP_pool-=dmg_taken
	if (HP_pool<1 && IsAlive):
		IsAlive = false
		$Node2D/BodyArea/Body.visible = false
		animatedSprite2D.play("death");
		await get_tree().create_timer(1.2).timeout
		self.queue_free()

func _on_attacking_area_body_entered(body: Node2D) -> void:
	BodyEntered = true # Replace with function body.

func _on_ray_not_collided():
	if (is_on_floor()):
		Direction*=-1
		rayNode2D.position = Vector2(rayNode2D.position.x*-1, rayNode2D.position.y)
		PivotNode.scale = Vector2(Direction, 1)


func _on_attacking_area_body_exited(_body: Node2D) -> void:
	BodyEntered = false # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	IsAttacking = false
	if (anim_name == "attack"):
		global_position = Vector2(global_position.x+70*Direction, global_position.y)
	 # Replace with function body.


func _on_attack_range_body_entered(_body: Node2D) -> void:
	print("Hit") # Replace with function body.
	Global.McHealth -= dmg_dealt
	if Global.McHealth < 0 :
		print("Win")

func _on_ranged_attack_body_entered(body: Node2D) -> void:
	print(body.name)
	print("Hit by ranged attack")
	pass # Replace with function body.
