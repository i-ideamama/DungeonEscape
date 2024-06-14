extends CharacterBody3D

const SPEED = 4.8
const JUMP_VELOCITY = 4.5

var lower_random_interval = 5
var upper_random_interval = 10

var timer : Timer
var direction : Vector3

@onready var ray := $RayCast3D
var ray_cast_mag = 5

var chasing_player = false
var player_pos

func _ready():
	self.visible = false
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

	if ray.is_colliding():
		
		if(ray.get_collider() is CSGCombiner3D):
			# handle changing direction and stuff
			random_timer_timeout()
	
	$RayCast3D.target_position = direction*ray_cast_mag
	
	var target_pos
	if(chasing_player):
		target_pos = get_parent().get_node("Player").position
		direction = global_position.direction_to(target_pos)
	
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


func _on_area_3d_body_entered(body):
	if(body.name == "Player"):
		if !$ChasePlayer.is_stopped():
			$ChasePlayer.stop()
		player_pos = body.global_position
		ray.target_position = player_pos
		chasing_player = true
		get_parent().play_drums()

func _on_area_3d_body_exited(body):
	$ChasePlayer.start()

func _on_timer_timeout():
	chasing_player = false
	get_parent().stop_drums()

func make_visible():
	self.visible = true
