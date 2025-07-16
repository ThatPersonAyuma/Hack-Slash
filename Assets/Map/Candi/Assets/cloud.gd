extends ParallaxLayer

@export var CLOUD_SPEED: float = -20

func _process(delta: float) -> void:
	self.motion_offset.x+= CLOUD_SPEED * delta
