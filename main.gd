extends ARVROrigin

var camera
var moving
var first_move
var scaling
var first_scale
var relative_rotation
var relative_translation
var relative_scaling
#onready var scaling = false
export onready var debug = false
export onready var scaling_factor = 0.1

onready var root = get_node("/root/ARVROrigin")
onready var data = get_node("/root/ARVROrigin/Data")

func _ready():

	var arvr_interface = ARVRServer.find_interface("OpenVR")
	
	#If VR detected
	if (arvr_interface and arvr_interface.initialize()):

		camera = ARVRCamera.new()
		
		get_viewport().arvr = true
		get_viewport().hdr  = false
		
	#No VR, implemented because in Porto I don't have access to the headset
	else:
		
		#Setup a new camera with movements (WASD + Mouse + Ctr or Shift to control speed)
		camera = Camera.new()
		camera.script = preload("res://scenes/CameraMouse.gd")
		
		#Create a touch surface to debug
		var area = Area.new()
		var collision_shape = CollisionShape.new()
		var collision_mesh = MeshInstance.new()
		var sphere_mesh = SphereMesh.new()

		collision_mesh.mesh = sphere_mesh
		collision_shape.add_child(collision_mesh)
		collision_shape.shape = SphereShape.new()

		area.add_child(collision_shape)
		camera.add_child(area)
		
		#Move to mask 2
		area.collision_mask = 2

		#Let's move the surface so that it doesn't collide with the camera
		area.translate_object_local(Vector3(0, 0, -0.3))
		area.scale_object_local(Vector3(0.01, 0.01, 0.01))
		
		#Connect the functions
		area.connect("area_entered", data, "_on_entered")
		area.connect("area_exited", data, "_on_exited")

	camera.name = "ARVRCamera"
	self.add_child(camera)
	
	get_node("/root/ARVROrigin").remove_child(data)
	
	var rot_origin = Spatial.new()
	rot_origin.add_child(data)
	rot_origin.name = "RotationHelper"
	get_node("/root/ARVROrigin").add_child(rot_origin)
	
	#Debug
	if debug:
		var dbg_mesh = MeshInstance.new()
		dbg_mesh.mesh = CubeMesh.new()
		dbg_mesh.mesh.material = SpatialMaterial.new()
		dbg_mesh.mesh.material.albedo_color = Color(1, 0, 0)
		dbg_mesh.scale = Vector3(0.1, 0.1, 0.1)
		rot_origin.add_child(dbg_mesh)
		
#This method will be called when a button is pressed on the controller
func _on_button_pressed(button_index):
		
	if button_index == 15:
		
		Input.action_press("ui_grab")
		
	elif button_index == 14:
		
		scaling = !scaling

#This method will be called when a button is released on the controller
func _on_button_released(button_index):
	
	if button_index == 15:
		
		Input.action_release("ui_grab")
		
#The map button needs to be mapped in the Project settings
func _process(delta):
	
	#IDs https://docs.unity3d.com/Manual/OpenVRControllers.html
	
	var pivot      = get_node("/root/ARVROrigin/Controller1")
	var rot_helper = get_node("/root/ARVROrigin/RotationHelper")
	
	if Input.is_action_just_pressed("ui_grab"):
		first_move = true
		moving     = true
		
	if Input.is_action_just_released("ui_grab"):
		
		moving = false
		
	#This is for the scale function
	#print("DBG: ", pivot.get_joystick_axis(1))
	if scaling:
		
		if pivot.get_joystick_axis(1) == 0:
			first_scale = true
			relative_scaling = null
		
		if first_scale:
			
			if pivot.get_joystick_axis(1) != 0:
				
				relative_scaling = (pivot.get_joystick_axis(1) + 1)/2.0
				first_scale = false
				
		
		if !first_scale and relative_scaling != null:
			
			print(relative_scaling)
			
			var scale_val = (pivot.get_joystick_axis(1) + 1)/2.0 - relative_scaling
			
			print(scale_val)
			
			rot_helper.scale = rot_helper.scale + Vector3(scale_val, scale_val, scale_val)
			relative_scaling = (pivot.get_joystick_axis(1) + 1)/2.0
	
	#This happens when the user presses the grab button
	if first_move:
		
		var original_transform = data.global_transform
		rot_helper.set_translation(pivot.get_translation())
		rot_helper.set_rotation(pivot.get_rotation())
		data.global_transform = original_transform
		
		first_move = false
		relative_translation = pivot.get_translation()
		relative_rotation    = pivot.get_rotation()
		
		return
	
	#This happens while the user keeps the grab button
	if moving:
		
		var rot_diff = pivot.get_rotation()    - relative_rotation
		var tra_diff = pivot.get_translation() - relative_translation
		
		rot_helper.set_rotation(rot_helper.get_rotation() + rot_diff)
		rot_helper.set_translation(rot_helper.get_translation() + tra_diff)
		
		relative_translation = pivot.get_translation()
		relative_rotation    = pivot.get_rotation()
		