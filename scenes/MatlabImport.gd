extends Spatial

#This function will be called when the controller enters in the collision shape of the data
func _on_entered(body):
	
	var label = get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Viewport/GUI/Label")
	get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Quad").visible = true
	
	var data = body.data
	
	label.text = "Z: " + String(body.data)

#This method will be called when the controller exits the collision shape of the data
func _on_exited(body):
	
	get_node("/root/ARVROrigin/Controller1/Text/Gui_in_3D/Quad").visible = false

#This method will be called when a button is pressed on the controller
func _on_button_pressed(button_index):
	
	pass
	#print("Pressed: " + String(button_index))

#This method will be called when a button is released on the controller
func _on_button_released(button_index):
	
	pass
	#print("Released: " + String(button_index))

func get_colormap_color(z, result):
	
	var z_normalized = (z - result["ZDataMin"])/(result["ZDataMax"] - result["ZDataMin"])
	
	var x_col = (z_normalized * (result["ParulaMax"][0] - result["ParulaMin"][0])) + result["ParulaMin"][0]
	var y_col = (z_normalized * (result["ParulaMax"][1] - result["ParulaMin"][1])) + result["ParulaMin"][1]
	var z_col = (z_normalized * (result["ParulaMax"][2] - result["ParulaMin"][2])) + result["ParulaMin"][2]	
	
	return Color(x_col, y_col, z_col)
	
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
	
	var file = File.new()
	
	#This JSON was done with MATLAB
	file.open("res://data/surf.txt", file.READ)
	var line = file.get_as_text()
	file.close()
	var p = JSON.parse(line)
	
	var result = p.result
		
	var m = len(result["XData"])
	var n = len(result["XData"][0])
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var x
	var y
	var z
	var normal
	
	for i in range(m-1):
		for j in range(n-1):
			
			#This will store the coordinates of the rectangle for the CollisionShape
			var rect_coords = PoolVector3Array()
			
			#The color is based on the Z value
			var color_z = (result["ZData"][i][j] + result["ZData"][i][j+1] + result["ZData"][i+1][j] + result["ZData"][i+1][j+1])/4.0
			var colmap_pick = get_colormap_color(color_z, result)
			
			#0
			x = result["XData"][i][j]
			y = result["YData"][i][j]
			z = result["ZData"][i][j]
			
			rect_coords.append(Vector3(x, z, -y))
			
			normal = Vector3(result["VertexNormals"][i][j][0], result["VertexNormals"][i][j][2], -result["VertexNormals"][i][j][1])
			
			st.add_color(colmap_pick)
			st.add_normal(normal)
			st.add_vertex(Vector3(x, z, -y))
			
			#1
			x = result["XData"][i][j+1]
			y = result["YData"][i][j+1]
			z = result["ZData"][i][j+1]
			
			rect_coords.append(Vector3(x, z, -y))
			
			normal = Vector3(result["VertexNormals"][i][j+1][0], result["VertexNormals"][i][j+1][2], -result["VertexNormals"][i][j+1][1])
			
			st.add_color(colmap_pick)
			st.add_normal(normal)
			st.add_vertex(Vector3(x, z, -y))
			
			#6
			x = result["XData"][i+1][j]
			y = result["YData"][i+1][j]
			z = result["ZData"][i+1][j]
			
			rect_coords.append(Vector3(x, z, -y))
			
			normal = Vector3(result["VertexNormals"][i+1][j][0], result["VertexNormals"][i+1][j][2], -result["VertexNormals"][i+1][j][1])
			
			st.add_color(colmap_pick)
			st.add_normal(normal)
			st.add_vertex(Vector3(x, z, -y))

			#1
			x = result["XData"][i][j+1]
			y = result["YData"][i][j+1]
			z = result["ZData"][i][j+1]
			
			normal = Vector3(result["VertexNormals"][i][j+1][0], result["VertexNormals"][i][j+1][2], -result["VertexNormals"][i][j+1][1])
			
			st.add_color(colmap_pick)
			st.add_normal(normal)
			st.add_vertex(Vector3(x, z, -y))
			
			#7
			x = result["XData"][i+1][j+1]
			y = result["YData"][i+1][j+1]
			z = result["ZData"][i+1][j+1]
			
			rect_coords.append(Vector3(x, z, -y))
			
			normal = Vector3(result["VertexNormals"][i+1][j+1][0], result["VertexNormals"][i+1][j+1][2], -result["VertexNormals"][i+1][j+1][1])
			
			st.add_color(colmap_pick)
			st.add_normal(normal)
			st.add_vertex(Vector3(x, z, -y))
			
			#6
			x = result["XData"][i+1][j]
			y = result["YData"][i+1][j]
			z = result["ZData"][i+1][j]
			
			normal = Vector3(result["VertexNormals"][i+1][j][0], result["VertexNormals"][i+1][j][2], -result["VertexNormals"][i+1][j][1])
			
			st.add_color(colmap_pick)
			st.add_normal(normal)
			st.add_vertex(Vector3(x, z, -y))
			
			#CollisionArea
			var CustomArea = preload("res://scenes/CustomArea.gd")
			var coll_area = CustomArea.new()
			coll_area.data = color_z
			var shp = ConvexPolygonShape.new()
			var c_s = CollisionShape.new()
			shp.points = rect_coords
			c_s.shape = shp
			coll_area.add_child(c_s)
			coll_area.collision_layer = 2
			self.add_child(coll_area)
			

	var surface_node = MeshInstance.new()
	surface_node.mesh = st.commit()
	surface_node.name = "Figure"
	
	var material = SpatialMaterial.new()
	surface_node.material_override = material
	surface_node.material_override.vertex_color_use_as_albedo = true
	surface_node.material_override.params_cull_mode = SpatialMaterial.CULL_DISABLED
	
	self.add_child(surface_node)
