extends Area2D

@export var _is_open : bool
@export var _is_locked : bool
@export_range(0, 99) var _total_value : int = 1
@export var _silver_coin : PackedScene
@export var _padlock : PackedScene
@export var _gold_coin : PackedScene

@onready var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _booty : Array[Treasure] = []

func _ready():
	while _total_value > 10:
		_total_value -= 10
		_booty.push_back(_gold_coin.instantiate())
	while _total_value > 0:
		_total_value -= 1
		_booty.push_back(_silver_coin.instantiate())

func plunder():
	for item in _booty:
		item.global_position = global_position + Vector2.UP * Global.pixelpertile
		item.freeze = false
		item.apply_impulse(
			Vector2.UP * Global.pixelpertile * _rng.randf_range(5, 10) +
			Vector2.RIGHT * Global.pixelpertile * _rng.randf_range(-1, 1)
		)
		get_parent().add_child(item)
	_booty.clear()

func throw_padlock():
	var padlock: RigidBody2D = _padlock.instantiate()
	padlock.global_position = global_position + Vector2(-4, 9)
	padlock.apply_impulse(
		Vector2.UP * Global.pixelpertile +
		Vector2.RIGHT * Global.pixelpertile * _rng.randf_range(-1, 1)
	)
	get_parent().add_child(padlock)

func _on_body_entered(body: Node2D):
	if body is Character:
		if _is_locked and Unit.data.has_key:
			_is_locked = false
			$/root/Game.use_key()
		if not _is_locked:
			_is_open = true
