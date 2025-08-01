class_name Data extends Resource

@export var world : int
@export var level : int
@export var coins : int
@export var lives : int
@export var checkpoint : int
@export var has_key : bool



func _init() -> void:
	world = 1
	level = 1
	coins = 0
	lives = 3
	checkpoint = 0
	has_key = false

func retry():
	coins = 0
	lives = 3
	checkpoint = 0
	has_key = false
