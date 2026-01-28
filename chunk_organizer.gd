extends Node

@onready var camera_2d: Camera2D = $"../Camera2D"
const CHUNKNODE = preload("uid://dmq218nhlotxm")
#var world_width : int = 32
#var world_average_depth : int = 32

var terrain_noise : FastNoiseLite = FastNoiseLite.new()
var terrain_height_variance : int = 4096 #How tall and deep surface land can be
var terrain_frequency : int = 20 #Reccomended range(1,20)

var active_coords : Array = []
var active_chunks : Array = []


var current_chunk : Vector2i = Vector2i.ZERO
var previous_chunk : Vector2i = Vector2i.ZERO
var chunk_loaded : bool = false

func _ready() -> void:
	randomize()
	terrain_noise.seed = randi()
	terrain_noise.fractal_octaves = 8
	terrain_noise.frequency = terrain_frequency / 100000.0
	current_chunk = get_player_chunk()
	load_chunks()

func _process(_delta: float) -> void:
	current_chunk = get_player_chunk()
	if previous_chunk != current_chunk:
		if !chunk_loaded:
			load_chunks()
	else :
		chunk_loaded = false
	previous_chunk = current_chunk



func load_chunks():
	var render_bounds = (float(2)*2.0)+1
	var loading_coords : Array = []
	for x in range(render_bounds):
		for y in range(render_bounds):
			var _x = (x+1) - (round(render_bounds/2.0)) + current_chunk.x
			var _y = (y+1) - (round(render_bounds/2.0)) + current_chunk.y
			
			var chunk_coords : Vector2 = Vector2i(_x,_y)
			loading_coords.append(chunk_coords)
			if active_coords.find(chunk_coords) == -1:
				var chunk = CHUNKNODE.instantiate()
				
				chunk.chunk_coords = chunk_coords
				chunk.terrain_noise = terrain_noise
				chunk.terrain_height_variance = terrain_height_variance
				
				active_chunks.append(chunk)
				active_coords.append(chunk_coords)
				chunk.start(chunk_coords)
				add_child(chunk)
	var deleting_chunks : Array = []
	for x in active_coords:
		if loading_coords.find(x) == -1:
			deleting_chunks.append(x)
	for x in deleting_chunks:
		var index = active_coords.find(x)
		active_chunks[index].save()
		active_chunks.remove_at(index)
		active_coords.remove_at(index)
	
	chunk_loaded = true

func get_player_chunk() -> Vector2i:
	var pos : Vector2 = camera_2d.global_position / 32.0 / 16.0
	if pos.x < 0 : pos.x -= 1
	if pos.y < 0 : pos.y -= 1
	return pos
