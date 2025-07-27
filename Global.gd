extends Node

@export var McHeatlh: int = 100
var CanCharMove :bool = true
var Player: CharacterBody2D

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
func _on_timeline_ended():
	CanCharMove = true
