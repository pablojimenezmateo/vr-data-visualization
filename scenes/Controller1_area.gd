extends Area

#The node that holds all the data
onready var data_node = get_node("/root/ARVROrigin/Data")
onready var root = get_node("/root/ARVROrigin")

func _ready():

	get_parent().connect("button_pressed", data_node, "_on_button_pressed")
	get_parent().connect("button_release", data_node, "_on_button_released")
	get_parent().connect("button_pressed", root, "_on_button_pressed")
	get_parent().connect("button_release", root, "_on_button_released")
	connect("area_entered", data_node, "_on_entered")
	connect("area_exited", data_node, "_on_exited")
	self.collision_mask = 2
	#set_process_input(true)
	#set_physics_process(true)

#func _process(delta):

	#if get_parent().is_button_pressed(15):

		#data_node.rotation_degrees = get_parent().rotation_degrees
		#node.transform = get_parent().transform
		#node.translation = get_parent().translation

