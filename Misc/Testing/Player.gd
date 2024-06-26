extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var ray1 := $Neck/Camera3D/ray1
@onready var weapon_cam := $SubViewport/WeaponCamera

@onready var lidar_mmi_scene = preload("res://Scenes/lidar_mmi.tscn")
@onready var checkpoint_scene = preload("res://Scenes/Checkpoint.tscn")
var checkpoint
var checkpoint_placed = false

var mmi1
var mm

var max_dots = 100000
var last_dot_id = 0
var dot_despawn_time = 120
var delete_timers = []

var blasters = [null, 'pea_shooter', 'spray_blaster', 'fov_blaster']
var current_blaster_index = 0
var current_blaster = blasters[current_blaster_index]

var rng = RandomNumberGenerator.new()

func _ready():
	for i in range(max_dots):
		delete_timers.append(null)
	setup_first_mmi()

func setup_first_mmi():
	mmi1 = lidar_mmi_scene.instantiate()
	get_parent().add_child(mmi1)
	mm = mmi1.multimesh
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
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-55), deg_to_rad(90))

func delete_dot():
	for i in range(delete_timers.size()):
		if(delete_timers[i]!=null):
			delete_timers[i] = null
			mm.set_instance_transform(i, Transform3D.IDENTITY.scaled(Vector3.ZERO))
			break

func instance_dot(i, pos, normal, col):
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
	#mm.set_instance_color(i, Color(1,1,0))
	delete_timers[i] = Timer.new()
	add_child(delete_timers[i])
	delete_timers[i].one_shot = true
	delete_timers[i].wait_time = dot_despawn_time
	delete_timers[i].start()
	delete_timers[i].timeout.connect(delete_dot)

func shake_camera():
	$Neck/Camera3D.apply_shake()

func _process(_delta):
	# for debug stuff
	if Input.is_action_just_pressed("ui_text_backspace"):
		shake_camera()
	if Input.is_action_pressed("scan"):
		shoot_lidar_points()
	if Input.is_action_just_pressed("checkpoint"):
		place_checkpoint()
	if Input.is_action_just_pressed("change_blaster"):
		if((current_blaster_index+1)==blasters.size()):
			current_blaster_index = 0
		else:
			current_blaster_index+=1
		current_blaster = blasters[current_blaster_index]
		set_blaster()

func place_checkpoint():
	checkpoint = checkpoint_scene.instantiate()
	get_parent().add_child(checkpoint)
	checkpoint.position = Vector3(position.x, position.y+1, position.z)
	checkpoint_placed = true
	
func shoot_lidar_points():
	if current_blaster == "spray_blaster":
		set_spray_blastet()
	if current_blaster == "fov_blaster":
		set_fov_blaster()
	
	for ray in $Neck/Camera3D.get_children():
		if ray is RayCast3D:
			var col = ray.get_collider()
			if(last_dot_id<max_dots):
				if(col!=null):
					if ((col is CSGCombiner3D) or (col is StaticBody3D)):
						if current_blaster == "fov_blaster":
							var fov_ray_len=15
							var origin = ray.global_transform.origin
							var collision_point = ray.get_collision_point()
							var distance = origin.distance_to(collision_point)
							var grad = distance/fov_ray_len
							var color = Color(1,1,0)
							instance_dot(last_dot_id, ray.get_collision_point(), ray.get_collision_normal(), color)
						else:
							instance_dot(last_dot_id, ray.get_collision_point(), ray.get_collision_normal(), Color(1,1,1))
						last_dot_id+=1
					if (col is StaticBody3D):
						if("Trap" in col.get_parent().get_parent().name):
							col.get_parent().get_parent().make_visible()
					if (col is CharacterBody3D):
						if("Enemy" in col.name):
							col.make_visible()
			else:
				if(delete_timers[-1]==null):
					get_parent().remove_child(mmi1)
					setup_first_mmi()
					last_dot_id=0


func set_blaster():
	for c in $Neck/Camera3D.get_children():
		if c is RayCast3D:
			c.enabled = false
	for c in $SubViewport/WeaponCamera.get_children():
		if c is CharacterBody3D:
			c.visible = false
	for f in $Neck/Camera3D.get_children():
		if ((f is RayCast3D) and ('fov' in f.name)):
			f.enabled = false
	if current_blaster == "pea_shooter":
		$SubViewport/WeaponCamera/Blaster_PeaShooter.visible = true
		ray1.enabled = true
		ray1.target_position.x = 50
	elif current_blaster == "spray_blaster":
		$SubViewport/WeaponCamera/Blaster_SprayBlaster.visible = true
		set_spray_blastet()
	elif current_blaster == "fov_blaster":
		$SubViewport/WeaponCamera/Blaster_FOV.visible = true
		set_fov_blaster()
	else:
		for c in $Neck/Camera3D.get_children():
			if c is RayCast3D:
				c.enabled = false

func set_fov_blaster():
	var cam_fov = $Neck/Camera3D.fov
	for c in $Neck/Camera3D.get_children():
		if "fov" in c.name:
			c.enabled = true
			c.rotation = Vector3(0, deg_to_rad(randf_range(-cam_fov-90, cam_fov-90)),deg_to_rad(randf_range(-cam_fov,cam_fov)))

func set_spray_blastet():
	ray1.target_position.x = 5
	for c in $Neck/Camera3D.get_children():
		if ((c is RayCast3D) and ("ray" in c.name)):
			c.rotation = Vector3(0, deg_to_rad(randf_range(-95,-85)),deg_to_rad(randf_range(-5,5)))
			c.enabled = true


func _physics_process(delta) -> void:
	
	if not is_on_floor():
		velocity.y -= gravity * delta

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
