@tool
extends CSGCombiner3D

var room_count
var min_rooms = 5
var max_rooms = 10

var min_room_size = 8
var max_room_size = 15

var room_pos_list = []
var room_pos_list_cpy = []

var pos_range = Vector2(-50,50)

var mesh_resolution = 5


@export var mat : StandardMaterial3D

@export var gen : bool = false : set = setgenerate
func setgenerate(_val:bool) -> void:
	randomize()
	do_the_gen()

@export var clear : bool = false : set = setclear

@onready var player = get_node("Player")

func setclear(_val:bool) -> void:
	for c in get_children():
		c.queue_free()
		room_pos_list.clear()

func _ready():
	randomize()
	do_the_gen()
	#player.position = room_pos_list[0]

func do_the_gen():
	get_room_positions()
	place_rooms()
	get_rooms()

func get_room_positions():
	room_count = randi_range(min_rooms, max_rooms)
	var room_pos
	
	for i in range(room_count):
		room_pos = Vector3(randi_range(pos_range.x,pos_range.y),0,randi_range(pos_range.x,pos_range.y))
		while(!can_place(room_pos)):
			room_pos = Vector3(randi_range(pos_range.x,pos_range.y),0,randi_range(pos_range.x,pos_range.y))
		room_pos_list.append(room_pos)
	
	room_pos_list_cpy = room_pos_list


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

func get_rooms():
	var room1
	var room2
	while room_pos_list_cpy.size() > 2:
		room1 = room_pos_list_cpy[randi_range(0, room_pos_list_cpy.size()-1)]
		room2 = room_pos_list_cpy[randi_range(0, room_pos_list_cpy.size()-1)]
		
		while room1==room2:
			room2 = room_pos_list_cpy[randi_range(0, room_pos_list_cpy.size()-1)]
			
		connect_rooms(room1, room2)
		room_pos_list_cpy.erase(room1)

	if room_pos_list_cpy.size()==2:
		room1 = room_pos_list_cpy[0]
		room2 = room_pos_list_cpy[1]
		connect_rooms(room1, room2)
	
func connect_rooms(room1, room2):
	var dir1 = room2.x - room1.x
	var dir2 = room2.z - room1.z
	
	var mesh1 = CSGMesh3D.new()
	mesh1.mesh = BoxMesh.new()
	mesh1.scale = Vector3(abs(dir1)+3, 3, 3)
	mesh1.mesh.subdivide_width = mesh1.scale.x/mesh_resolution
	mesh1.mesh.subdivide_height = mesh1.scale.y/mesh_resolution
	mesh1.mesh.subdivide_depth = mesh1.scale.z/mesh_resolution
	mesh1.position = room1 + Vector3(dir1/2, 0, 0)
	mesh1.material = mat
	mesh1.flip_faces = true
	add_child(mesh1)
	
	var mesh2 = CSGMesh3D.new()
	mesh2.mesh = BoxMesh.new()
	mesh2.scale = Vector3(3, 3, abs(dir2)+3)
	mesh2.mesh.subdivide_width = mesh2.scale.x/mesh_resolution
	mesh2.mesh.subdivide_height = mesh2.scale.y/mesh_resolution
	mesh2.mesh.subdivide_depth = mesh2.scale.z/mesh_resolution
	mesh2.position = room2 - Vector3(0, 0, dir2/2)
	mesh2.material = mat
	mesh2.flip_faces = true
	add_child(mesh2)












