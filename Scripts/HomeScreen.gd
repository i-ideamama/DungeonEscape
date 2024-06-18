extends Node3D


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")

func _on_quit_pressed():
	get_tree().quit()
