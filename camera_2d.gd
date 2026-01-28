extends Camera2D
var direction : Vector2 = Vector2.ZERO
var speed = 100
func _process(_delta: float) -> void:
	direction = Input.get_vector("Left","Right","Jump","Down")
	global_position += direction * speed
