@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"Gun",
		"Node2D",
		preload("gun.gd"),
		preload("res://icon.png")
	)


func _exit_tree():
	remove_custom_type("Gun")
