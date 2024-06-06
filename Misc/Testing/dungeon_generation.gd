@tool
extends CSGCombiner3D


@export var generate : bool = false : set = set_generate
func set_generate(_val:bool) -> void:
	generate_dungeon()
@export var create_hallways : bool = false : set = set_connect
func set_connect(_val:bool) -> void:
	get_rooms_to_connect()
@export var delete : bool = false : set = set_delete
func set_delete(_val:bool) -> void:
	delete_dungeon()

@export var size : int = 100
@export var room_amount : int = 3
@export var min_room_size : int = 1
@export var max_room_size : int = 5
@export var mesh_resolution : int = 5
@export var mat : StandardMaterial3D

var dungeon :  Array
var connections : Array
var dungeon_connections : Array

func generate_dungeon():
	print("rooms")
	for i in range(room_amount):
		var randpos = Vector3(randi_range(-size,size), 0, randi_range(-size,size))
		if(can_place(randpos)):
			var mesh = CSGMesh3D.new()
			mesh.mesh = BoxMesh.new()
			mesh.scale = Vector3(randi_range(min_room_size,max_room_size), 3, randi_range(min_room_size,max_room_size))
			mesh.mesh.subdivide_width = mesh.scale.x/mesh_resolution
			mesh.mesh.subdivide_height = mesh.scale.y/mesh_resolution
			mesh.mesh.subdivide_depth = mesh.scale.z/mesh_resolution
			mesh.position = randpos
			mesh.material = mat
			mesh.flip_faces = true
			
			add_child(mesh)
			dungeon.append(mesh)
			dungeon_connections.append(mesh)
			
func can_place(pos):
	if not dungeon:
		return true
	else:
		for d in dungeon:
			var distance = pos.distance_to(d.position)
			if(distance<max_room_size):
				return false
		return true

func get_rooms_to_connect():
	pass
	
	

func connect_rooms(room1, room2):
	print("hallways")

func delete_dungeon():
	print("delete")
	for i in dungeon:
		i.queue_free()
	dungeon.clear()
	
	for i in connections:
		i.queue_free()
	connections.clear()
	
	for i in dungeon_connections:
		i.queue_free()
	dungeon_connections.clear()
