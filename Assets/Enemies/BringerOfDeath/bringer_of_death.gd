extends CharacterBody2D

@onready var AttackingArea: Area2D = $PivotNode/AreaAttackStart
@onready var PivotNode: Node2D = $PivotNode
@onready var rayNode2D: Node2D = $PivotNode/RayCastFloor
@onready var animatedSprite2D: AnimatedSprite2D = $PivotNode/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $PivotNode/AnimationPlayer
@onready var rangedAnimatedSprited: AnimatedSprite2D = $ranged_attack
@onready var rangedAttackArea: Area2D = $ranged_attack/ranged_area
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
var IsAlive: bool = true
#var attackArea: Area2D { get; set; }
#var body: CollisionShape2D = $Node2D/CharacterBody2D/Body

func _ready():
	rayNode2D.connect("NotCollided", Callable(self, "_on_ray_not_collided"))
	rangedAnimatedSprited.get_parent().remove_child(rangedAnimatedSprited)
	get_node("/root").add_child.call_deferred(rangedAnimatedSprited)

func _physics_process(delta: float) -> void:
	if IsAlive:
		var Velocity:Vector2 = velocity;
		var IsOnFloorVal:bool = is_on_floor();
		if (!IsOnFloorVal):
			Velocity.y += Gravity * delta
		else:
			Velocity.x = 0
			Velocity.y = 0
			if (BodyEntered && !IsAttacking && ChargeRunningColdown >= ChargeColdown):
				#if (Direction==-1 && $EndPointLeft/RayCast2D.is_colliding()):
				pst = (Global.Player.global_position.x - global_position.x) * Direction 
				if (pst<0):
					change_direction()
				IsAttacking = true
				animation_player.play("melee_Attack")
			else:
				ChargeRunningColdown += delta
			if (!IsAttacking):
				if(!BodyEntered):
					if (abs(Global.Player.global_position.y - global_position.y)<=20):
						pst = (Global.Player.global_position.x - global_position.x) * Direction 
						if (pst<0):
							change_direction()
						animatedSprite2D.play("walk");
						Velocity.x = Speed*Direction;
					else:
						if (WalkingColdownTimer > 0):
							WalkingColdownTimer -= delta
						else:
							IsWalk = !IsWalk;
							WalkingColdownTimer = WalkingColdown;
						if (IsWalk):
							Velocity.x = Direction * Speed;
							AnimatedName = "walk";
						else:
							Velocity.x = 0;
							AnimatedName = "idle";
						#check_player_in_range_area()
						animatedSprite2D.play(AnimatedName);
				else:
					animatedSprite2D.play("idle")
		velocity = Velocity;
				#print("Direction: ", Direction," left: ", $EndPointLeft/RayCast2D.is_colliding(), " right: ", $EndPointRight/RayCast2D.is_colliding())
		move_and_slide();
	#print(Global.McHealth)

func check_player_in_range_area():
	var distance = global_position.distance_to(Global.Player.global_position)
	ranged_raycast.rotate((Global.Player.global_position - global_position).angle() - ranged_raycast.rotation)
	var collider = ranged_raycast.get_collider()
	if collider == Global.Player && !IsRanged:
		pst = (Global.Player.global_position.x - global_position.x) * Direction 
		if (pst<0):
			change_direction()
		IsAttacking = true
		AnimatedName = "range_attack"
		print("Run Animation")
		await get_tree().create_timer(1.286).timeout
		print("end of animation")
		IsAttacking = false
		print("in range")
		IsRanged = true
		rangedAnimatedSprited.visible = true
		rangedAnimatedSprited.play("range_attack")
		rangedAnimatedSprited.global_position = Vector2(Global.Player.global_position.x+5, Global.Player.global_position.y-30)
		# 2 detik
		await get_tree().create_timer(0.875).timeout
		rangedAttackArea.monitoring = true
		await get_tree().create_timer(0.625).timeout
		rangedAttackArea.monitoring = false
		await get_tree().create_timer(0.5).timeout
		rangedAnimatedSprited.stop()
		rangedAnimatedSprited.visible = false
		rangedAnimatedSprited.global_position = global_position
		IsRanged = false

func _on_attacking_area_body_entered(body: Node2D) -> void:
	BodyEntered = true # Replace with function body.

func _on_ray_not_collided():
	if (is_on_floor()):
		change_direction()
		
func change_direction():
	PivotNode.scale = Vector2(Direction, 1)
	Direction*=-1
	global_position = Vector2(global_position.x + Direction*70, global_position.y)

func take_damage(dmg_taken: int):
	HP_pool-=dmg_taken
	if (HP_pool<1 && IsAlive):
		IsAlive = false
		$PivotNode/Area2D.visible = false
		animatedSprite2D.play("death");
		await get_tree().create_timer(2.0).timeout
		self.queue_free()

func _on_attacking_area_body_exited(_body: Node2D) -> void:
	BodyEntered = false # Replace with function body.


func _on_attack_range_body_entered(_body: Node2D) -> void:
	print("Hit") # Replace with function body.
	Global.McHealth -= dmg_dealt
	if Global.McHealth < 0 :
		print("Win")

func _on_ranged_area_body_entered(body: Node2D) -> void:
	print(body.name)
	print("Hit by ranged attack") # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	IsAttacking = false # Replace with function body.
