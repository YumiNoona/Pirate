extends Area2D

@onready var _area: CollisionShape2D = $CollisionShape2D
@onready var _half_size: Vector2 = _area.shape.get_rect().size/2
var _checkpoints : Array[Node]


func _ready():
	_checkpoints = $Checkpoints.get_children()
	for i in _checkpoints.size():
		if _checkpoints[i] is Checkpoint:
			_checkpoints[i].id = i

func get_checkpoints_position(checkpoint_id : int) -> Vector2:
	if checkpoint_id >= 0 && checkpoint_id < _checkpoints.size():
		return _checkpoints[checkpoint_id].global_position
	return Vector2.ZERO



func get_minimum() -> Vector2:
	return _area.position - _half_size
	
func get_maximum() -> Vector2:
	return _area.position + _half_size
