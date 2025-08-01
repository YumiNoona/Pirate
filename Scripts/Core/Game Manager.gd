extends Node2D

@onready var _player_character: Character = $Roger
@onready var _player: Node = $Roger/Player
@onready var _camera: Camera2D = $Camera2D
@onready var _level: Area2D = $Level
@onready var _coin_counter : Control = $GameUI/CoinCounter
@onready var _lives_counter : Control = $GameUI/LivesCounter
@onready var _key_icon: TextureRect = $GameUI/KeyIcon
@onready var _fade: ColorRect = $GameUI/Fade
@onready var _sound: AudioStreamPlayer2D = $Victory
@onready var game_over: Control = $GameUI/GameOver



@export_category("AUDIO")

@export var _finished : AudioStream
@export var _death : AudioStream
@export var _gameover : AudioStream

func _ready():
	_fade.visible = true
	_init_boundaries
	_init_ui
	_spawn_player()
	await _fade.fade_to_clear()
	_player.set_enabled(true)


func _spawn_player():
	_player_character.global_position = _level.get_checkpoints_position(Unit.data.checkpoint)
	_player_character.velocity = Vector2.ZERO


func  _init_boundaries():
	var minimum_boundary : Vector2 = _level.get_minimum
	var maximum_boundary : Vector2 = _level.get_maximum
	_camera.set_bounds(minimum_boundary, maximum_boundary)
	_player_character.set_bounds(minimum_boundary, maximum_boundary)


func _init_ui():
	_coin_counter.set_value(Unit.data.coins)
	_lives_counter.set_value(Unit.data.lives)
	game_over.visible = false


func collect_map():
	_player.set_enabled(false)
	_sound.stream = _finished
	_sound.play()
	await _sound.finished
	await _fade.fade_to_black()



func collect_coin(value : int):
	Unit.data.coins += value
	if Unit.data.coins >= 100:
		Unit.data.coins -= 100
		Unit.data.lives += 1
		_lives_counter.set_value(Unit.data.lives)
	_coin_counter.set_value(Unit.data.coins)


func collect_skull():
	Unit.data.lives += 1
	_lives_counter.set_value(Unit.data.lives)


func collect_key():
	Unit.data.has_key = true
	_key_icon.visible = true



func use_key():
	Unit.data.has_key = false
	_key_icon.visible = false


func _on_player_dead() -> void:
	if Unit.data.lives == 0:
		_game_over()
	else:
		Unit.data.lives -= 1
		_lives_counter.set_value(Unit.data.lives)
		_sound.stream = _death
		_sound.play()
		_return_to_last_checkpoint



func _return_to_last_checkpoint():
	_player.set_enabled(false)
	await _fade.fade_to_black()
	_spawn_player()
	_player_character.revive()
	await _fade.fade_to_clear()
	_player.set_enabled(true)


func _game_over():
	print("GAME OVER")
	_sound.stream = _gameover
	_sound.play()
	game_over.visible = true


func _on_btn_retry_pressed() -> void:
	game_over.visible = false
	await  _fade.fade_to_black()
	Unit.data.retry()
	_level.queue_free()
	_level = load("res://Scenes/Levels/Level " + str (Unit.data.world) + "" + str(Unit.data.level) + ".tscn").instantiate()
	add_child(_level)
	_spawn_player()
	_player.set_enabled(false)
	_player_character.revive()
	await  _fade.fade_to_clear()
	_player.set_enabled(true)
	
	
func _on_btn_level_select_pressed() -> void:
	game_over.visible = false
	await  _fade.fade_to_black()
	Unit.data.retry()
	print("Return To Level Selection")



func _on_btn_quit_pressed() -> void:
	game_over.visible = false
	await  _fade.fade_to_black()
	get_tree().quit()
	print("Return To Main Menu Selection")
