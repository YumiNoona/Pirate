extends Node

@onready var _character = get_parent()
var _is_enabled : bool

func set_enabled(is_enabled : bool):
	_is_enabled = is_enabled

func _input(event: InputEvent):
	if not _is_enabled:
		return
	if event.is_action_pressed("Jump"):
		_character.jump()
		if event.is_action_released("Jump"):
			_character.stop_jump()


func _process(delta: float) -> void:
	if not _is_enabled:
		return
	_character.run(Input.get_axis("Run_Left", "Run_Right"))
