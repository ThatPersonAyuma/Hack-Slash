extends Node

var CanCharMove :bool = true

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
func _on_timeline_ended():
	CanCharMove = true
