extends Area3D


func _on_body_entered(body):
	if(body.name == "Player"):
		print("ded")
