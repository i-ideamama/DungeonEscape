extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var ray := $Neck/Camera3D/RayCast3D
@onready var mmi = get_parent().get_node("MultiMeshInstance3D")
@onready var mm = mmi.multimesh

var max_dots = 10000
var last_dot_id = 0

func _ready():
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

func _physics_process(delta) -> void:
	
	if((ray.get_collider()!=null) and (last_dot_id<max_dots)):
		instance_dot(last_dot_id, ray.get_collision_point(), ray.get_collision_normal())
		last_dot_id+=1

	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
