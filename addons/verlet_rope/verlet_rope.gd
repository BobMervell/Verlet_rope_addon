@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Rope3D","Node3D",preload("res://addons/verlet_rope/rope_simulation.gd"),
		preload("res://addons/verlet_rope/rope_icon.png"))


func _exit_tree():
	remove_custom_type("Rope3D")
