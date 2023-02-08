extends CharacterBody3D

@export var walk_speed : int = 5
@export var walk_accel : int = 10
@export var fall_accel : int = 3
@export var dodge_speed : int = 200
@export var dodge_accel : int = 8
@export var dodge_jump_strength : int = 8
@export var gravity : int = -30
@export var terminal_velocity : int = -40
@export var jump_strength : int = 15
@export var mesh_rot_speed : float = 0.2

var forward_relative_to_camera : Vector3
var input_dir : Vector3
var state = IDLE
var previous_state = IDLE

enum {
	IDLE,
	WALKING,
	JUMPING,
	FALLING,
	STRAFING,
	DODGING
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func _physics_process(delta):
	match state:
		
		IDLE:
			get_directional_input()
			apply_gravity(delta)
			interpolate_velocity(walk_speed, walk_accel, delta)
			move_and_slide()
			
			if input_dir.length() > 0:
				change_state(WALKING)
				
			if Input.is_action_just_pressed("jump") and is_on_floor():
				change_state(JUMPING)
				
			if Input.is_action_pressed("strafe"):
				change_state(STRAFING)
			
		WALKING:
			get_directional_input()
			align_mesh_to_input_dir()
			apply_gravity(delta)
			interpolate_velocity(walk_speed, walk_accel, delta)
			move_and_slide()
			
			if !is_on_floor():
				change_state(FALLING)
			
			if input_dir.length() <= 0:
				change_state(IDLE)
				
			if Input.is_action_just_pressed("jump") and is_on_floor():
				change_state(JUMPING)
				
			if Input.is_action_pressed("strafe"):
				change_state(STRAFING)
				
		JUMPING:
			velocity.y = jump_strength
			get_directional_input()
			align_mesh_to_input_dir()
			apply_gravity(delta)
			interpolate_velocity(walk_speed, fall_accel, delta)
			move_and_slide()
			
			change_state(FALLING)
			
		FALLING:
			get_directional_input()
			align_mesh_to_input_dir()
			apply_gravity(delta)
			interpolate_velocity(walk_speed, fall_accel, delta)
			move_and_slide()
			
			if is_on_floor() and input_dir.length() > 0:
				change_state(WALKING)
				
			elif is_on_floor() and input_dir.length() <= 0:
				change_state(IDLE)
				
			if Input.is_action_pressed("strafe"):
				change_state(STRAFING)
				
		STRAFING:
			get_directional_input()
			align_mesh_to_input_dir()
			apply_gravity(delta)
			interpolate_velocity(walk_speed, walk_accel, delta)
			move_and_slide()
			
			if Input.is_action_just_released("strafe"):
				change_state(WALKING)
				
			if Input.is_action_just_pressed("jump") and is_on_floor():
				change_state(DODGING)
				
		DODGING:
			get_directional_input()
			align_mesh_to_input_dir()
			apply_gravity(delta)
			interpolate_velocity(dodge_speed, dodge_accel, delta)
			velocity.y = dodge_jump_strength
			move_and_slide()
			change_state(previous_state)
				
	
func get_directional_input():
	forward_relative_to_camera = -get_node("camera_pivot").basis.z
	
	input_dir = Vector3.ZERO
	
	var left_right_axis = Input.get_axis("walk_left", "walk_right")
	var forward_back_axis = Input.get_axis("walk_forward", "walk_backward")
	
	input_dir += forward_relative_to_camera.cross(Vector3.UP) * left_right_axis
	input_dir += -forward_relative_to_camera * forward_back_axis
	
	if input_dir.length() > 1:
		input_dir = input_dir.normalized()

func interpolate_velocity(speed : int, accel : int, delta):
	velocity.x = lerp(velocity.x, input_dir.x * speed, accel * delta)
	velocity.z = lerp(velocity.z, input_dir.z * speed, accel * delta)
	
func apply_gravity(delta):
	velocity.y += gravity * delta
	if velocity.y < terminal_velocity:
		velocity.y = terminal_velocity
	
func align_mesh_to_input_dir():
	
	if state == STRAFING or state == DODGING:
		var current_rot_quat = Quaternion($body_rig.basis.orthonormalized()).normalized()
		var desired_rot_quat = Quaternion($camera_pivot.basis.orthonormalized()).normalized()
		var interpolated_quat = current_rot_quat.slerp(desired_rot_quat, mesh_rot_speed)
		
		$body_rig.basis = Basis(interpolated_quat).orthonormalized()
		
	else:
		if input_dir.length() > 0:
			var input_dir_2d = Vector2(input_dir.x, input_dir.z).normalized()
			var camera_dir_2d = -Vector2($camera_pivot.basis.z.x, $camera_pivot.basis.z.z).normalized()
			var angle_to = -camera_dir_2d.angle_to(input_dir_2d)
			
			var desired_quat = Quaternion($camera_pivot.basis.rotated(Vector3.UP, angle_to).orthonormalized()).normalized()
			var current_quat = Quaternion($body_rig.basis.orthonormalized()).normalized()
			
			var interpolated_quat = current_quat.slerp(desired_quat, mesh_rot_speed)
			
			$body_rig.basis = Basis(interpolated_quat).orthonormalized()

func change_state(new_state):
	previous_state = state
	state = new_state
	
	if state == 0:
		$Label3D.text = "IDLE"
	elif state == 1:
		$Label3D.text = "WALKING"
	elif state == 2:
		$Label3D.text = "JUMPING"
	elif state == 3:
		$Label3D.text = "FALLING"
	elif state == 4:
		$Label3D.text = "STRAFING"
	elif state == 5:
		$Label3D.text = "DODGING"
		
	else:
		$Label3D.text = "IT'S A MAGIC MYSTERY"
	
