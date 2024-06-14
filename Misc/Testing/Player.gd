extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var ray1 := $Neck/Camera3D/ray1
@onready var weapon_cam := $SubViewport/WeaponCamera

var mmi
var mm

var max_dots = 10000
var last_dot_id = 0

var blasters = [null, 'pea_shooter', 'spray_blaster']
var current_blaster_index = 0
var current_blaster = blasters[current_blaster_index]

var rng = RandomNumberGenerator.new()

func _ready():
	mmi = get_parent().get_node('MultiMeshInstance3D')
	mm = mmi.multimesh
	mm.instance_count = max_dots
	mm.visible_instance_count = max_dots

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x*0.01)
			camera.rotate_x(-event.relative.y*0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))

func instance_dot(i, pos, normal):
	var transform = Transform3D()
	transform = transform.translated(pos)
	var other_line = Vector3(0,1,(-normal.y/normal.z))
	if(normal.z!=0):
		transform.basis = Basis().looking_at(other_line, normal)
	elif(normal.y!=0):
		other_line = Vector3(1,(-normal.x/normal.y),0)
		transform.basis = Basis().looking_at(other_line, normal)
	elif(normal.x!=0):
		other_line = Vector3((-normal.z/normal.x),0,1)
		transform.basis = Basis().looking_at(other_line, normal)
	mm.set_instance_transform(i, transform)

func _process(_delta):
	# for debug stuff
	if Input.is_action_just_pressed("ui_text_backspace"):
		$Neck/Camera3D.apply_shake()
	
	if Input.is_action_pressed("scan"):
		shoot_lidar_points()
		
	if Input.is_action_just_pressed("change_blaster"):
		if((current_blaster_index+1)==blasters.size()):
			current_blaster_index = 0
		else:
			current_blaster_index+=1
		current_blaster = blasters[current_blaster_index]
		set_blaster()

func shoot_lidar_points():
	if current_blaster == "spray_blaster":
		set_spray_blastet()
	
	for ray in $Neck/Camera3D.get_children():
		if((ray.get_collider()!=null) and (last_dot_id<max_dots)):
			if (ray.get_collider() is CSGCombiner3D):
				instance_dot(last_dot_id, ray.get_collision_point(), ray.get_collision_normal())
				last_dot_id+=1

func set_blaster():
	for c in $SubViewport/WeaponCamera.get_children():
		if c is CharacterBody3D:
			c.visible = false
	if current_blaster == "pea_shooter":
		$SubViewport/WeaponCamera/Blaster_PeaShooter.visible = true
		for c in $Neck/Camera3D.get_children():
			c.enabled = false
		ray1.enabled = true
		ray1.target_position.x = 50
	elif current_blaster == "spray_blaster":
		$SubViewport/WeaponCamera/Blaster_SprayBlaster.visible = true
		set_spray_blastet()
	else:
		for c in $Neck/Camera3D.get_children():
			c.enabled = false

func set_spray_blastet():
	ray1.target_position.x = 5
	for c in $Neck/Camera3D.get_children():
		c.rotation = Vector3(0, deg_to_rad(randf_range(-95,-85)),deg_to_rad(randf_range(-5,5)))
		c.enabled = true


func _physics_process(delta) -> void:
	

	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
