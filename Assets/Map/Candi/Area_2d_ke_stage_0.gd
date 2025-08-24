extends Area2D

var entered = false
 
func _on_body_entered(body: Node2D) -> void:
	entered = true
	


func _on_body_exited(body: Node2D) -> void:
	entered = false # Replace with function body.
