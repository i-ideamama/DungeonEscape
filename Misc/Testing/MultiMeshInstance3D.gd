extends MultiMeshInstance3D

var mm = self.multimesh

func _ready():
	var count = 4
	mm.instance_count = count
	mm.visible_instance_count = count
	for i in mm.visible_instance_count:
		instance_mm(i)

func instance_mm(i):
	var position = Transform3D()
	position = position.translated(Vector3(-7+i, 1, 0.5))
	mm.set_instance_transform(i, position)
