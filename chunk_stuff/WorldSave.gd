extends Node

var loaded_coords : Array = []
var chunk_data : Array = []

func add_chunk(coords : Vector2):
	loaded_coords.append(coords)
	chunk_data.append([])

func save_chunk(coords : Vector2, data):
	chunk_data[loaded_coords.find(coords)] = data

func retrieve_data(coords : Vector2):
	var data = chunk_data[loaded_coords.find(coords)]
	return data
