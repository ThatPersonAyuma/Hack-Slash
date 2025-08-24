extends CharacterBody2D

@onready var AttackingArea: Area2D = $AttackingArea
@onready var PivotNode: Node2D = $PivotNode
@onready var rayNode2D: Node2D = $PivotNode/RayCastFloor
@onready var rayCastFront: RayCast2D = $PivotNode/RayCast2D
@onready var animatedSprite2D: AnimatedSprite2D = $PivotNode/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer
@onready var meleeArea: Area2D = $PivotNode/MeleeArea
@onready var ranged_raycast = $RayCast2D
@export var Gravity: float = 1000
@export var Speed: float  = 50
@export var Direction: int = 1
@export var WalkingColdown: float = 1.5
@export var dmg_dealt:int = 10
@export var ChargeColdown: float = 8
@export var HP_pool: int = 100
var ChargeRunningColdown: float = 0
var WalkingColdownTimer: float = 0
var AnimatedName: String ="idle"
var IsWalk: bool = false
var IsAttacking: bool = false
var pst: int
var IsRanged: bool = false 
var IsAlive:bool = true
#var attackArea: Area2D { get; set; }
#var body: CollisionShape2D = $Node2D/CharacterBody2D/Body



func _ready():
	rayNode2D.connect("NotCollided", Callable(self, "_on_ray_not_collided"))
	get_node("/root").add_child.call_deferred()

func _physics_process(delta: float) -> void:
	if (IsAlive):
		var Velocity:Vector2 = velocity;
		var IsOnFloorVal:bool = is_on_floor();
		if (!IsOnFloorVal):
			Velocity.y += Gravity * delta
		else:
			#check_player_in_range_area()
			if (abs(Global.Player.global_position.x - global_position.x) <= 15 
			&& !IsAttacking && ChargeRunningColdown >= ChargeColdown):
				#if (Direction==-1 && $EndPointLeft/RayCast2D.is_colliding()):
				pst = (Global.Player.global_position.x - global_position.x) * Direction 
				var direction_result: int = Direction
				if (pst<0):
					direction_result = Direction * -1
				if (pst>-28 && pst<31):
					if (direction_result != Direction):
						_on_ray_not_collided()
				animatedSprite2D.play("meleeAttack")
				Velocity.x = 0;
				IsAttacking = true
				ChargeRunningColdown = 0
				meleeArea.monitorable = true
				var result = meleeArea.get_overlapping_bodies()
				if (result.size() != 0):
					Global.McHealth -= dmg_dealt
					if Global.McHealth < 0 :
						print("Win") # Replace with function body.
				animation_end()
			else:
				ChargeRunningColdown += delta
			if (!IsAttacking):
				if(rayCastFront.is_colliding()):
					_on_ray_not_collided()
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

func animation_end():
	await get_tree().create_timer(1.143).timeout
	IsAttacking = false

func take_damage(dmg_taken: int):
	HP_pool-=dmg_taken
	if (HP_pool<1 && IsAlive):
		IsAlive = false
		$Node2D/BodyArea/Body.visible = false
		animatedSprite2D.play("death");
		await get_tree().create_timer(1.2).timeout
		self.queue_free()


func _on_ray_not_collided():
	if (is_on_floor()):
		Direction*=-1
		PivotNode.scale = Vector2(Direction, 1)

func _on_melee_area_area_entered(area: Area2D) -> void:
	print("Hit") # Replace with function body.
	Global.McHealth -= dmg_dealt
	if Global.McHealth < 0 :
		print("Win") # Replace with function body.
