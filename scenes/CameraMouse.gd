extends Camera

func _ready():

	set_process(true)
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#This is used to translate the camera around
func _process(delta):

	var camSpeed
	
	if Input.is_action_pressed("ui_sprint"):
		camSpeed = 15
	elif Input.is_action_pressed("ui_slow"):
		camSpeed = 1
	else:
		camSpeed = 5
	
	if Input.is_action_pressed("ui_up"):
		set_translation(get_translation() - get_transform().basis[2] * delta* camSpeed)
		
	if Input.is_action_pressed("ui_down"):
		set_translation(get_translation() + get_transform().basis[2] * delta* camSpeed)
		
	if Input.is_action_pressed("ui_left"):
		set_translation(get_translation() - get_transform().basis[0] * delta* camSpeed)
		
	if Input.is_action_pressed("ui_right"):
		set_translation(get_translation() + get_transform().basis[0] * delta* camSpeed)
		
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()
		
#Horizontal movement
var yaw = 0

#Vertical movement
var pitch = 0

#This function is used to rotate the camera
func _input(event):

	var view_sensitivity = 0.003
	
	if (event is InputEventMouseMotion):
		
		var relative_x = event.relative.x
		var relative_y = event.relative.y
		#Calculate the rotation angle
		yaw = yaw - relative_x * view_sensitivity 
		pitch = pitch - relative_y * view_sensitivity
	
		#Yeah!, maths!
		
		#The basic explanation with examples can be found here
		#http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToQuaternion/steps/index.htm
		var q  = Quat()
		var c1 = cos(yaw/2)
		var c2 = 1
		var c3 = cos(pitch/2)
		var s1 = sin(yaw/2)
		var s2 = 0
		var s3 = sin(pitch/2)
		
		q.w = c1 * c2 * c3 - s1 * s2 * s3
		q.x = s1 * s2 * c3 + c1 * c2 * s3
		q.y = s1 * c2 * c3 + c1 * s2 * s3
		q.z = c1 * s2 * c3 - s1 * c2 * s3
		q = q.normalized()
		
		#The transformation moves the camera to the origin, so we need to store its previous position to move it back
		var trans = get_translation()
		
		#Rotate the camera
		set_transform(Transform(q))
		
		#Move it back
		set_translation(trans)