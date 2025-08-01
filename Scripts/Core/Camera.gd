extends Camera2D

@export_category("Reference")
@export var _subject : Node2D
@export var _offset : Vector2

@export_category("Transitions")
@export var _look_ahead_trans_type : Tween.TransitionType
@export var _look_ahead_ease_type : Tween.EaseType
@export var _floor_height_trans_type : Tween.TransitionType
@export var _floor_height_ease_type : Tween.EaseType

@export_category("Parameters")
@export var _look_ahead_duration : float = 1.0
@export var _floor_height_duration : float = 1.0
@onready var _look_ahead_distance : float = _offset.x
@onready var _floor_height : float = _subject.position.y


var _look_ahead_tween : Tween
var _floor_height_tween : Tween

var _maximum : Vector2
var _minimum : Vector2
var _is_bound : bool

func _ready():
	_offset *= Global.pixelpertile



func set_bounds(_maximum_boundary : Vector2, _minimum_boundary : Vector2):
	var half_zoomed_size = get_viewport_rect().size / zoom / 2
	_is_bound = true
	_maximum = _maximum_boundary
	_minimum = _minimum_boundary
	_minimum += half_zoomed_size
	_maximum -= half_zoomed_size



func _process(_delta: float):
	position.x  = _subject.position.x + _look_ahead_distance
	position.y  = _floor_height + _offset.y
	if _is_bound:
		position.x = clamp(position.x, _minimum.x, _maximum.x)
		position.y = clamp(position.y, _minimum.y, _maximum.y)
	


func _on_subject_changed_direction(is_facing_left: bool):
	if _floor_height_tween && _floor_height_tween.is_running():
		_look_ahead_tween.kill()
	_look_ahead_tween = create_tween().set_trans(_look_ahead_trans_type).set_ease(_look_ahead_ease_type)
	_look_ahead_tween.tween_property(self, "_look_ahead_distance",_offset.x * (-1 if is_facing_left else 1),_look_ahead_duration)

func _on_subject_landed(floor_height: float):	
	if _floor_height_tween && _look_ahead_tween.is_running():
		_floor_height_tween.kill()
	_floor_height_tween = create_tween().set_trans(_floor_height_trans_type).set_ease(_floor_height_ease_type)
	_floor_height_tween.tween_property(self, "_floor_height",floor_height,_floor_height_duration)
