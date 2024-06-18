@tool
extends CSGCombiner3D

var room_count
var min_rooms = 4
var max_rooms = 5
var min_room_size = 8
var max_room_size = 15
var room_pos_list = []
var room_pos_list_cpy = []
var pos_range = Vector2(-75,75)
var mesh_resolution = 8


@export var mat : StandardMaterial3D

@export var gen : bool = false : set = setgenerate
func setgenerate(_val:bool) -> void:
	randomize()
	do_the_gen()
	inst_obstacles()

@onready var player_scene = preload("res://Scenes/Player.tscn")
@onready var player_TEST_scene = preload("res://Scenes/Player_TEST.tscn")
var player
@onready var enemy_scene = preload("res://Scenes/enemy.tscn")
var enemy
var enemy_count=0
@onready var trap_scene = preload("res://Scenes/Trap.tscn")
var trap
var trap_count=0
@onready var bottom_of_chasm_scene = preload("res://Scenes/BottomOfChasm.tscn")
var bottom_of_chasm
@onready var goal_scene = preload("res://Scenes/Goal.tscn")
var goal

@export var clear : bool = false : set = setclear

var obstacles = ["enemy", "spikes", "chasm"]

func setclear(_val:bool) -> void:
	for c in get_children():
		c.queue_free()
		room_pos_list.clear()

func _ready():
	randomize()
	do_the_gen()
	player = player_TEST_scene.instantiate()
	get_parent().add_child.call_deferred(player)
	player.position = Vector3(room_pos_list[-2].x ,-1,room_pos_list[-2].z)
	print("player pos = ",Vector3(room_pos_list[room_pos_list.size()-1].x ,-1,room_pos_list[room_pos_list.size()-1].z))
	inst_obstacles()
	
	
	
	goal = goal_scene.instantiate()
	get_parent().add_child.call_deferred(goal)
	goal.position = Vector3(room_pos_list[-1].x ,-1,room_pos_list[-1].z)
	
func do_the_gen():
	get_room_positions()
	place_rooms()
	get_rooms()

func inst_obstacles():
	for i in range(room_pos_list.size()-3):
		var poz = room_pos_list[i]
		obstacles.shuffle()
		if(obstacles[0]=="enemy"):
			place_enemy(poz)
		elif(obstacles[0]=="spikes"):
			place_spikes(poz)
		elif(obstacles[0]=="chasm"):
			place_chasm(poz)

func place_enemy(poz):
	enemy = enemy_scene.instantiate()
	enemy_count+=1
	enemy.name = str("Enemy",enemy_count)
	get_parent().add_child.call_deferred(enemy)
	enemy.position = Vector3(poz.x ,-0.8,poz.z)

func place_chasm(poz):
	var chasm = CSGMesh3D.new()
	var chasm_height = 100
	var chasm_side = 3
	chasm.mesh = BoxMesh.new()
	chasm.name = "chasm"
	chasm.scale = Vector3(chasm_side, chasm_height, chasm_side)
	chasm.flip_faces = true
	chasm.mesh.subdivide_width = chasm.scale.x/mesh_resolution
	chasm.mesh.subdivide_height= chasm.scale.y/mesh_resolution
	chasm.mesh.subdivide_depth = chasm.scale.z/mesh_resolution
	chasm.position = Vector3(poz.x ,(-chasm_height/2)+1, poz.z)
	add_child(chasm)
	bottom_of_chasm = bottom_of_chasm_scene.instantiate()
	get_parent().add_child.call_deferred(bottom_of_chasm)
	bottom_of_chasm.position = Vector3(chasm.position.x,-chasm_height+2,chasm.position.z)

func place_spikes(poz):
	trap = trap_scene.instantiate()
	trap_count+=1
	trap.name = str("Trap",trap_count)
	get_parent().add_child.call_deferred(trap)
	trap.position = Vector3(poz.x ,-1.5, poz.z)

func get_room_positions():
	room_count = randi_range(min_rooms, max_rooms)
	var room_pos
	
	for i in range(room_count):
		room_pos = Vector3(randi_range(pos_range.x,pos_range.y),0,randi_range(pos_range.x,pos_range.y))
		while(!can_place(room_pos)):
			room_pos = Vector3(randi_range(pos_range.x,pos_range.y),0,randi_range(pos_range.x,pos_range.y))
		room_pos_list.append(room_pos)
	room_pos_list.append(Vector3(-pos_range.x, 0, pos_range.y))
	
	room_pos_list.append(Vector3(pos_range.x, 0, -pos_range.y))
	
	for i in range(room_pos_list.size()):
		room_pos_list_cpy.append(room_pos_list[i])


func place_rooms():
	for p in room_pos_list:
		var mesh = CSGMesh3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.name = "dungeon"
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
	
	connect_rooms(room_pos_list[-1], room_pos_list[randi_range(0, room_pos_list_cpy.size()-3)])
	room_pos_list_cpy.erase(room_pos_list[-1])
	
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
