extends Spatial

export var min_sphere_radius = 0.01
export var radius_factor = 0.02
export var inner_scale   = 100
var is_pressed

var colors = ["#1de8b5", "#42a5f5", "#ef5350", "#ffca28", "#7986cb", "#664733", "#332b26", "#ff8800", "#995200", "#e5b073", "#33260d", "#b28f00", "#999673", "#eeff00", "#57661a", "#b8d9a3", "#4ba629", "#00e600", "#003307", "#00f2c2", "#269982", "#394b4d", "#73cfe6", "#297ca6", "#004b8c", "#001b33", "#40a6ff", "#1a2466", "#8979f2", "#b4ace6", "#534d66", "#5200cc", "#290033", "#ca00d9", "#a653a0", "#ffbffb", "#73005c", "#e60099", "#ff0066", "#73002e", "#331a20", "#994d57"]

#This function will be called when the controller enters in the collision shape of the data
func _on_entered(body):
	
	print("I collided with " + body.name)
	body.get_parent().mesh.material.albedo_color = Color(0, 1, 0)
	
	var label = get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Viewport/GUI/Label")
	get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Quad").visible = true
	
	var data = body.data
	
	label.text = data.country + '\n' + data.continent + '\nGDP: ' + String(data.gdp) + '\nDebt: ' +  String(data.debt) + '\nPopulation: ' +  String(data.population) + '\nMin. wage: ' +  String(data.wage)
	#queue_free()

#This method will be called when the controller exits the collision shape of the data
func _on_exited(body):
	
	print("I decollided with " + body.name)
	body.get_parent().mesh.material.albedo_color = body.color
	get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Quad").visible = false
	#queue_free()

#This method will be called when a button is pressed on the controller
func _on_button_pressed(button_index):
	
	is_pressed = true
	
	print("Pressed: " + String(button_index))

#This method will be called when a button is released on the controller
func _on_button_released(button_index):
	
	is_pressed = false
	print("Released: " + String(button_index))


#Inner classes to help with this data
class Data:
	
	var raw_data = []
	var normalized_data = []

class Entry:
	
	var continent = ""
	var country = ""
	var gdp = 0
	var debt = 0
	var wage = 0
	var population = 0

class MaxMin:
	
	var _var1

	var gdp
	var debt
	var wage
	var population
	
	func _init(var1):
	
		self.gdp        = var1
		self.debt       = var1
		self.wage       = var1
		self.population = var1

func read_csv(csv_path):
	
	var data = Data.new()
	
	#This data structures will hold the maximum
	#and minimum of the values
	var max_data = MaxMin.new(0)
	var min_data = MaxMin.new(9999999)
	
	var is_header = true
	
	var file = File.new()
	file.open(csv_path, file.READ)
	
	#Normal read loop
	var line = file.get_csv_line()
	
	while line.size() != 0:
		
		if is_header:
			
			is_header = false
			line = file.get_csv_line()
			continue
			
		var entry = Entry.new()
		entry.continent  = line[0]
		entry.country    = line[1]
		entry.gdp        = float(line[2])
		entry.debt       = float(line[3])
		entry.wage       = float(line[4])
		entry.population = int(line[5])
		
		#TODO: This is horrible
		#Check for maximum and minimum
		if float(entry.gdp) > max_data.gdp:
			
			max_data.gdp = float(entry.gdp)
		
		if float(entry.gdp) < min_data.gdp:
			
			min_data.gdp = float(entry.gdp)
			
		if float(entry.debt) > max_data.debt:
			
			max_data.debt = float(entry.debt)
		
		if float(entry.debt) < min_data.debt:
			
			min_data.debt = float(entry.debt)
			
		if float(entry.wage) > max_data.wage:
			
			max_data.wage = float(entry.wage)
		
		if float(entry.wage) < min_data.wage:
			
			min_data.wage = float(entry.wage)
			
		if int(entry.population) > max_data.population:
			
			max_data.population = int(entry.population)
		
		if int(entry.population) < min_data.population:
			
			min_data.population = int(entry.population)
		
		data.raw_data.append(entry)
			
		line = file.get_csv_line()
	
	file.close()
	
	#Normalize the data
	for raw_entry in data.raw_data:
		 
		var entry = Entry.new()
		entry.continent       = raw_entry.continent
		entry.country           = raw_entry.country
		entry.gdp = (raw_entry.gdp - float(min_data.gdp))/float(max_data.gdp - min_data.gdp)
		entry.debt = (raw_entry.debt - float(min_data.debt))/float(max_data.debt - min_data.debt)
		entry.wage    = (raw_entry.wage - float(min_data.wage))/float(max_data.wage - min_data.wage)
		entry.population     = (raw_entry.population - float(min_data.population))/float(max_data.population - min_data.population)
	
		data.normalized_data.append(entry)
		
	return data
	
#This function will be on charge of reading the data and creating the geometry
func _ready():
	
	#I will instance a "Text" node and put it on the controller
	var text_node = Spatial.new()
	text_node.name = "Text"
	var text_scn = preload("res://scenes/Text.tscn")
	text_node.add_child(text_scn.instance())
	get_node("/root/ARVROrigin/Controller1").add_child(text_node)
	get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Quad").visible = false
	get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Quad").translation = Vector3(0, 0.1, -0.04)
	get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Quad").scale = Vector3(0.1, 0.1, 0.1)
	
	var data = read_csv("res://data/Countries.csv")
	
	var color_dict = {}
	var color
	var color_index = 0
	
	for entry in range(data.raw_data.size()):
		
		#Check if we already have a color for this continent
		if color_dict.has(data.raw_data[entry].continent):
			
			color = color_dict[data.raw_data[entry].continent]
		else:
			
			color = colors[color_index]
			color_dict[data.raw_data[entry].continent] = color
			color_index = color_index + 1
		
		#Instance the mesh container, then create the SphereMesh to add to it
		
		#Create a new sphere for each continent
		var mesh_instance = MeshInstance.new()
		var sph_mesh = SphereMesh.new()
		mesh_instance.mesh = sph_mesh
		
		#Set a material so we can change the color
		var mat = SpatialMaterial.new()
		sph_mesh.material = mat
		sph_mesh.material.albedo_color = Color(color)
		
		#Create the collision areas for those spheres
		var CustomArea = preload("res://scenes/CustomArea.gd")
		var kinematic_body = CustomArea.new()
			
		var sph_shape = SphereShape.new()
		var collision_shape = CollisionShape.new()
		
		collision_shape.shape = sph_shape
		kinematic_body.collision_layer = 2
		kinematic_body.name = data.raw_data[entry].country
		kinematic_body.add_child(collision_shape)
		mesh_instance.add_child(kinematic_body)
		
		mesh_instance.translate_object_local(Vector3(inner_scale*data.normalized_data[entry].gdp, data.normalized_data[entry].debt, inner_scale*data.normalized_data[entry].population))
		mesh_instance.scale = Vector3(min_sphere_radius + data.normalized_data[entry].wage * radius_factor, min_sphere_radius + data.normalized_data[entry].wage * radius_factor, min_sphere_radius + data.normalized_data[entry].wage * radius_factor)
		
		#Save the data to the object so it can be read from outside
		kinematic_body.data  = data.raw_data[entry]
		kinematic_body.color = Color(color)
				
		self.add_child(mesh_instance)
		
