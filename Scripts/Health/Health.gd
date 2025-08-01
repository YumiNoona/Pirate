extends Control

@onready var _fill: TextureRect = $Fill
@export var _max_pixels : int = 75


func set_value (percentage : float):
	_fill.size.x = _max_pixels * percentage
	
