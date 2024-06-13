extends Camera3D

@export var strength: float = 1.0
@export var shake_fade: float = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake():
	shake_strength = strength

func random_offset():
	return rng.randf_range(-shake_strength, shake_strength)

func _physics_process(delta):
	if(shake_strength > 0.0):
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
		h_offset = random_offset()
		v_offset = random_offset()
