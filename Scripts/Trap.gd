extends Node3D


func _ready():
	$trap/spikes.visible = false

func _on_area_3d_body_entered(body):
	if(body.name == "Player"):
		$trap/spikes.visible = true
		$AnimationPlayer.play("show")
		get_parent().player_lose()


func _on_area_3d_body_exited(body):
	if(body.name == "Player"):
		$AnimationPlayer.play("hide")
 
func make_visible():
	$trap/spikes.visible = true
