extends Node3D

var win

func start_drums():
	$Drums.play()

func stop_drums():
	$Drums.stop()

func player_win():
	print("winner")
	win = true
	get_tree().change_scene_to_file.call_deferred("res://Scenes/WinScreen.tscn")

func player_lose():
	if (get_node("Player").checkpoint_placed==true):
		get_node("Player").position = get_node("Checkpoint").position
		get_node("Player").checkpoint_placed=false
	else:
		get_node("Player").shake_camera()
		await(get_tree().create_timer(1.3).timeout)
		win = false
		get_tree().change_scene_to_file.call_deferred("res://Scenes/LoseScreen.tscn")
