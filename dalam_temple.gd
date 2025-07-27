extends Node2D


func _on_zona_duri_body_entered(body: Node2D) -> void:
	if body == Global.Player:
		get_tree().change_scene("res://dalam_temple.tscn") # Replace with function body.
