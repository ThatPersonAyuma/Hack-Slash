extends Node2D

@onready var CutSceneArea = $Area2D
var CutScene1:bool = true
var CutScene2: bool = true
var CutScene3: bool = true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	print("Called")
	if (CutScene1):
		Global.CanCharMove = false
		var layout = Dialogic.start("prolog") # Use the name of the STYLE here
		print(layout.has_signal("timeline_ended"))
		layout.register_character(load("res://Dialog/Character/Nanda.dch"), $Nanda)
		layout.register_character(load("res://Dialog/Character/Suara Misterius.dch"),$Node2D)
		#layout.connect("time")
		$Area2D/CollisionShape2D.queue_free()
		CutScene1 = false
	elif (CutScene2):
		# Play Cutscene
		Global.CanCharMove = false
		Dialogic.start("prolog2") # Use the name of the STYLE here
		$Area2D/CollisionShape2D1.queue_free()
		CutScene2 = false
	elif (CutScene3):
		Global.CanCharMove = false
		Dialogic.start("prolog3") # Use the name of the STYLE here
		#layout.register_character(load("res://Dialog/Character/Nanda.dch"), $CharacterBody2D)
		$Area2D/CollisionShape2D2.queue_free()
		CutScene3 = false

# ini ke map ijo yang running
#	Global.change_scene("res://dalam temple.tscn") # Replace with function body.


# ini ke map menuju desa 
#res://hutan_stage_1.tscn
