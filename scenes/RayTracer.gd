extends Spatial

export var line_width = 0.01

var transmitter
var global_mutex

var active_rays = {}
var active_threads = {}

#This function will be called when the controller enters in the collision shape of the data
func _on_entered(body):
	
	print("I collided with " + body.name)
	body.get_parent().mesh.material.albedo_color = Color(0, 1, 0)
	
	#The node already has a node working on it
	if body.is_computing:
		
		#Put it back to visible
		active_rays[body].show()
		body.is_relevant = true
		
		return
		
	#Flag to check if this node is being touched
	body.is_relevant = true
	
	#Flag that tells us that a thread is working on this node
	body.is_computing = true
	
	var rays_aux = Spatial.new()
	rays_aux.name = "rays"
	active_rays[body] = rays_aux
	get_node("/root/ARVROrigin/RotationHelper/Data").add_child(rays_aux)
	
	var th = Thread.new()
	active_threads[body] = th
	th.start(self, "draw_rays", body, 1)

#This method will be called when the controller exits the collision shape of the data
func _on_exited(body):
	
	print("I decollided with " + body.name)
	
	body.is_relevant = false
	if active_rays.has(body):
		active_rays[body].hide()
	
	#Return its original color
	body.get_parent().mesh.material.albedo_color = body.color

#This method will be called when a button is pressed on the controller
func _on_button_pressed(button_index):
	
	print("Pressed: " + String(button_index))

#This method will be called when a button is released on the controller
func _on_button_released(button_index):
	
	print("Released: " + String(button_index))

#Given a point creates the rays to that point
func draw_rays(node_point):
	
	var point = node_point.data
	
	var node = active_rays[node_point]
	
	var transmitter_position = Vector3(transmitter.x, transmitter.z, -transmitter.y)
	
	for path_index in range(len(point["paths"])):
		
		#Check if the node still exits, because we are playing with threads
		var wr = weakref(node)
		
		if (!wr.get_ref()):
			return
		
		var path = point["paths"][path_index]
		
		#If is direct path
		if len(path["interactions"]) == 0:
			
			draw_line(transmitter_position, Vector3(point.x, point.z, -point.y), Color(0, 0, 0), node)
		
		#If there are interactions
		var prev_interaction = transmitter_position
		
		for interaction_index in range(len(path["interactions"])):
			
			var interaction = path["interactions"][interaction_index]
			
			var color
			
			if interaction["type"] == 'T':
				
				color = Color(1, 0, 0)
			
			elif interaction["type"] == 'R':
				
				color = Color(0, 1, 0)
				
			else:
				
				color = Color(0, 0, 1)
			
			draw_line(prev_interaction, Vector3(interaction.x, interaction.z, -interaction.y), color, node)
			prev_interaction = Vector3(interaction.x, interaction.z, -interaction.y)
			
			#Add the last point
			if interaction_index == (len(path["interactions"]) - 1):
				
				if interaction["type"] == 'T':
					
					color = Color(1, 0, 0)
				
				elif interaction["type"] == 'R':
					
					color = Color(0, 1, 0)
					
				elif interaction["type"] == 'R':
					
					color = Color(0, 0, 1)
					
				draw_line(prev_interaction, Vector3(point.x, point.z, -point.y), color, node)
				
	#We are done computing this node
	node_point.is_computing = false
	
	return

class MinMax:
	
	var min_power
	var max_power

#A helper function to chose the color of the tiles
func normalize_power(data):
	
	var max_power = -INF
	var min_power = INF
	
	var m = len(data["rays"])
	var n = len(data["rays"][0])
		
	for i in range(m):
		for j in range(n):
			
			if typeof(data["power"][i][j]) != TYPE_NIL:
				
				var value = data["power"][i][j]
				
				if value > max_power:
					max_power = value
					
				if value < min_power:
					min_power = value
	
	var minmax = MinMax.new()
	
	minmax.max_power = max_power
	minmax.min_power = min_power
	
	return minmax

#This function draws a line between origin and end, it will append them to the node node
func draw_line(origin, end, color, node):
	
	if origin == end:
		
		return
	
	global_mutex.lock()
	var spatial  = Spatial.new()
	
	#Used to rotate the cylinder
	var spatial1 = Spatial.new()
		
	var length = origin.distance_to(end)
	
	var line = MeshInstance.new()
	line.mesh = CylinderMesh.new()
	line.mesh.material = SpatialMaterial.new()
	line.mesh.material.albedo_color = color
	
	line.mesh.top_radius = line_width
	line.mesh.bottom_radius = line_width
	line.mesh.height = length
	line.mesh.radial_segments = 4
	line.mesh.rings = 1
	
	spatial1.add_child(line)
	spatial1.rotate_x(deg2rad(90))
	spatial1.translate(Vector3(0, -length/2, 0))
	spatial.add_child(spatial1)

	spatial.look_at_from_position(origin, end, Vector3(0, 1, 0))
	
	node.add_child(spatial)
	
	global_mutex.unlock()
	
#This function will be on charge of reading the data and creating the geometry
func _ready():
	
	global_mutex = Mutex.new()
	
	set_physics_process(false)
		
	var file = File.new()
	
	#This JSON was done with MATLAB
	file.open("res://data/Raytracer.txt", file.READ)
	
	var line = file.get_as_text()
	
	file.close()
	
	var p = JSON.parse(line)
	
	var result = p.result
	
	var minmax = normalize_power(result)
	
	var m = len(result["rays"])
	var n = len(result["rays"][0])
	
	var CustomStaticBody = preload("res://scenes/CustomArea.gd")
	
	for i in range(m):
		for j in range(n):
			
			var point = result["rays"][i][j]
			
			if typeof(point.id) == TYPE_REAL:
			
				#Create one cube per point
				var mesh_instance = MeshInstance.new()
				var cube_mesh = QuadMesh.new()
				mesh_instance.mesh = cube_mesh
				
				#Set a material so we can change the color
				var mat = SpatialMaterial.new()
				cube_mesh.material = mat
				
				#Create the collision areas for those spheres
				var static_body = CustomStaticBody.new()
				var cube_shape = BoxShape.new()
				var collision_shape = CollisionShape.new()
				collision_shape.shape = cube_shape
				static_body.name = "Point (" + String(i) + ", " + String(j) + ")"
				static_body.add_child(collision_shape)
				mesh_instance.add_child(static_body)
				
				#The minus sign on the y is because the stored data is reversed
				mesh_instance.translate(Vector3(point.x, point.z, -point.y))
				mesh_instance.rotate_x(deg2rad(-90))
				cube_shape.extents = Vector3(0.5, 0.5, 0.01)
				
				#Save the data to the object so it can be read from outside
				static_body.data  = point
				static_body.is_relevant = false
				static_body.is_computing = false
				
				#Move it to the second layer
				static_body.collision_layer = 2
				
				#The color will be depending on the power
				var blue_color = (result["power"][i][j] - float(minmax.min_power))/float(minmax.max_power - minmax.min_power)
				cube_mesh.material.albedo_color = Color(0, 0, blue_color)
				static_body.color = Color(0, 0, blue_color)
				
				self.add_child(mesh_instance)
				
	#Add the transmitter
	transmitter = result["transmitter"]
	var transmitter_mesh = MeshInstance.new()
	transmitter_mesh.name = "Transmitter"
	var sph_mesh = SphereMesh.new()
	transmitter_mesh.mesh = sph_mesh
	var mat = SpatialMaterial.new()
	sph_mesh.material = mat
	sph_mesh.material.albedo_color = Color(1, 1, 0)
	
	transmitter_mesh.translate_object_local(Vector3(transmitter.x, transmitter.z, -transmitter.y))
	transmitter_mesh.scale = Vector3(0.05, 0.05, 0.05)
	
	self.add_child(transmitter_mesh)
	
func _process(delta):
	
	for node in active_rays.keys():
		
		if !node.is_computing and !node.is_relevant:
			
			get_node("/root/ARVROrigin/RotationHelper/Data").remove_child(active_rays[node])
			active_rays.erase(node)
			
			active_threads[node].wait_to_finish()
			active_threads.erase(node)
			