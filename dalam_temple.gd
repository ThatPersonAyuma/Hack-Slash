extends Node2D


func _on_zona_duri_body_entered(body: Node2D) -> void:
	if body == Global.Player:
		body.global_position=Vector2(-6465 , 600)
