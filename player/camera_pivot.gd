extends Node3D

var controller_sens = 3


func _process(delta):
	handle_controller_camera(delta)

func handle_controller_camera(delta):
	var left_right = Input.get_axis("controller_camera_left", "controller_camera_right")
	var up_down = Input.get_axis("controller_camera_down", "controller_camera_up")
	
	self.rotate_y(-left_right * delta * controller_sens)
	$SpringArm3D.rotate_x(up_down * delta * controller_sens)
	$SpringArm3D.rotation.x = clamp($SpringArm3D.rotation.x, -1.2, 1.2)
	
	

func _input(event):
	
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * 0.003)
		$SpringArm3D.rotate_x(-event.relative.y * 0.003)
		$SpringArm3D.rotation.x = clamp($SpringArm3D.rotation.x, -1.2, 1.2)
