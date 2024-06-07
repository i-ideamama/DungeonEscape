@tool
extends CSGCombiner3D

var room_count
var min_rooms = 5
var max_rooms = 10

var min_room_size = 8
var max_room_size = 15

var room_pos_list = []

var pos_range = Vector2(-35,35)

var mesh_resolution = 5


@export var mat : StandardMaterial3D

@export var gen : bool = false : set = setgenerate
func setgenerate(_val:bool) -> void:
	randomize()
	do_the_gen()

@export var clear : bool = false : set = setclear
func setclear(_val:bool) -> void:
	for c in get_children():
		c.queue_free()
		room_pos_list.clear()

func _ready():
	randomize()

func do_the_gen():
	get_room_positions()
	place_rooms()

func get_room_positions():
	room_count = randi_range(min_rooms, max_rooms)
	var room_pos
	
	for i in range(room_count):
		room_pos = Vector3(randi_range(pos_range.x,pos_range.y),0,randi_range(pos_range.x,pos_range.y))
		while(!can_place(room_pos)):
			room_pos = Vector3(randi_range(pos_range.x,pos_range.y),0,randi_range(pos_range.x,pos_range.y))
		room_pos_list.append(room_pos)
		
	for p in room_pos_list:
		print(p)

func place_rooms():
	for p in room_pos_list:
		var mesh = CSGMesh3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.scale = Vector3(randi_range(min_room_size, max_room_size), 3, randi_range(min_room_size, max_room_size))
		mesh.flip_faces = true
		mesh.mesh.subdivide_width = mesh.scale.x/mesh_resolution
		mesh.mesh.subdivide_height= mesh.scale.y/mesh_resolution
		mesh.mesh.subdivide_depth = mesh.scale.z/mesh_resolution
		mesh.material = mat
		mesh.position = p
		add_child(mesh)
		
		
func can_place(pos):
	if not room_pos_list:
		return true
	else:
		for p in room_pos_list:
			var dist = pos.distance_to(p)
			if(dist<max_room_size):
				return false
		return true
