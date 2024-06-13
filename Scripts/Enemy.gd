extends CharacterBody3D

const SPEED = 4.8
const JUMP_VELOCITY = 4.5

var lower_random_interval = 5
var upper_random_interval = 10

var timer : Timer
var direction : Vector3

var ray_cast_mag = 5

func _ready():
	create_random_timer()

func create_random_timer() -> void:
	randomize()
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.autostart = true
	var wait_time = randi_range(lower_random_interval, upper_random_interval)
	timer.timeout.connect(random_timer_timeout)
	timer.start(wait_time)

func _physics_process(delta) -> void:
	if $RayCast3D.is_colliding():
		random_timer_timeout()
	
	$RayCast3D.target_position = direction*ray_cast_mag
	#$RayCast3D.poin
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func random_timer_timeout() -> void:
	timer.wait_time = randi_range(lower_random_interval, upper_random_interval)
	direction = Vector3(randf_range(-1.0,1.0),0,randf_range(-1.0,1.0))
