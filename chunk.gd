extends Node2D

var chunk_coords : Vector2i = Vector2i.ZERO
var chunk_size = 32 * 16
var chunk_data : Array = []

var terrain_noise : FastNoiseLite
var terrain_height_variance : int = 20


var chunk_polygon : PackedVector2Array 
func start(_chunk_coords):
	chunk_polygon = [(Vector2(chunk_coords.x,chunk_coords.y) * chunk_size), (Vector2(chunk_coords.x + 1,chunk_coords.y) * chunk_size), (Vector2(chunk_coords.x + 1,chunk_coords.y + 1) * chunk_size), (Vector2(chunk_coords.x,chunk_coords.y + 1) * chunk_size)]
	create_chunk_border()
	if WorldSave.loaded_coords.find(_chunk_coords) == -1 :
		terrain_generation()
		WorldSave.add_chunk(chunk_coords)
	else :
		chunk_data = WorldSave.retrieve_data(chunk_coords)
		for polygon in chunk_data:
			var polygon_instance = Polygon2D.new()
			polygon_instance.polygon = polygon[0]
			polygon_instance.color = polygon[1]
			add_child(polygon_instance)

func save():
	for polygon in get_children():
		var polygon_polygon = polygon.polygon
		var polygon_color = polygon.color
		chunk_data = []
		chunk_data.append([polygon_polygon,polygon_color])
	WorldSave.save_chunk(chunk_coords,chunk_data)
	queue_free()


func terrain_generation():
	var land_with_terrain_height_variance : bool = false
	for x in range(chunk_coords.x * chunk_size, (chunk_coords.x + 1) * chunk_size + 1,32):
		var height = round(terrain_noise.get_noise_1d(x) * terrain_height_variance)
		if height > chunk_coords.y * chunk_size :
			land_with_terrain_height_variance = true
	if land_with_terrain_height_variance == false :
		var land : Polygon2D = Polygon2D.new()
		land.polygon = chunk_polygon
		add_child(land)
		# Check if chunk is below lowest possible height_variance. If so, generate chunk polygon
	
	var land_polygon = Polygon2D.new()
	var land_polygon_points = []
	if land_with_terrain_height_variance == true :
		land_polygon_points.append(Vector2(chunk_coords.x,chunk_coords.y + 1) * chunk_size)
		
		for x in range(chunk_coords.x * chunk_size, (chunk_coords.x + 1) * chunk_size + 1,32):
			var height = round(terrain_noise.get_noise_1d(x) * terrain_height_variance)
			land_polygon_points.append(Vector2(x,height))
		
		land_polygon_points.append(Vector2(chunk_coords.x + 1,chunk_coords.y + 1) * chunk_size)
		land_polygon.polygon = land_polygon_points
		
		for polygon in force_polygon_in_border(land_polygon.polygon) :
			var polygon_child = Polygon2D.new()
			polygon_child.polygon = polygon
			add_child(polygon_child)

##Intersect chunk_polygon with polygon_points. Returning resulting polygon(s) points
func force_polygon_in_border(polygon_points : PackedVector2Array) -> Array[PackedVector2Array]:
	return Geometry2D.intersect_polygons(chunk_polygon,polygon_points)

##Create chunk border and coordinate label, for debug only
func create_chunk_border():
	var label : Label = Label.new()
	label.text = str(chunk_coords)
	label.scale = Vector2(1.5,1.5)
	label.global_position = chunk_coords * chunk_size
	add_child(label,false,Node.INTERNAL_MODE_FRONT)
	var line : Line2D = Line2D.new()
	line.width = 2
	line.add_point(Vector2i(chunk_coords.x,chunk_coords.y) * chunk_size)
	line.add_point(Vector2i(chunk_coords.x + 1,chunk_coords.y) * chunk_size)
	line.add_point(Vector2i(chunk_coords.x + 1,chunk_coords.y + 1) * chunk_size)
	line.add_point(Vector2i(chunk_coords.x,chunk_coords.y + 1) * chunk_size)
	line.add_point(Vector2i(chunk_coords.x,chunk_coords.y) * chunk_size)
	add_child(line,false,Node.INTERNAL_MODE_FRONT)
