class_name Character
extends CharacterBody2D


signal changed_direction(is_facing_left: bool)
signal landed(floor_height : float)
signal health_changed(percentage : float)
signal dead()

@export_category("Locomotion")

@export var _speed : float = 8.0
@export var _acceleration : float = 16.0
@export var _deceleration : float = 32.0


@export_category("Jump")

@export var _jump_height : float = 2.5
@export var _air_control : float = 0.5
@export var _jump_dust : PackedScene


@export_category("Sprite")

@onready var _sprite: Sprite2D = $Sprite2D
@export var _is_facing_left : bool
@export var _sprite_face_left : bool
var _was_on_floor : bool

@export_category("Swim")

@export var _density : float = 0.1
@export var _drag : float = 0.5
var _water_surface_height : float
var _is_in_water : bool
var _is_below_surface : bool

@export_category("Health")

@onready var _current_health : int = _max_health
@onready var _hurt_box : Area2D = $HurtBox
@export_range(1, 100) 
var _max_health : int = 5
var _invincible_time : Timer

@export_category("Combat")

@export_range(0,5)  var _invincible_duration : float
@export_range(0,5)  var _attack_damage : int = 1
@export var _is_hit : bool
@export var _is_dead : bool
@export var _wants_to_attack : bool


var _collision_mask : int = collision_mask
var _collision_layer : int = collision_layer


var _direction : float
var _jump_velocity : float
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var _maximum : Vector2
var _minimum : Vector2
var _is_bound : bool


func  _ready():
	_speed *= Global.pixelpertile
	_acceleration *= Global.pixelpertile
	_deceleration *= Global.pixelpertile
	_jump_height *= Global.pixelpertile
	_jump_velocity = sqrt(_jump_height * gravity * 2) * -1
	face_left() if _is_facing_left else face_right()
	if _invincible_duration != 0:
		_invincible_time = $HurtBox/Invincible


func attack():
	_wants_to_attack = true



func take_damage(amount : int, direction : Vector2):
	_current_health = max(_current_health - amount, 0)
	health_changed.emit(float (_current_health) / _max_health)
	velocity = direction * Global.pixelpertile * 5
	print(_current_health)
	if _current_health == 0:
		_die()
	else:
		_is_hit = true
		if _invincible_duration != 0:
			become_invincible(_invincible_duration)


func recover(amount : int):	
	_current_health = min(_current_health + amount, _max_health)
	health_changed.emit(float (_current_health) / _max_health)

func become_invincible (duration : float):
	_hurt_box.set_deferred("monitorable", false)
	_invincible_time.start(duration)
	await _invincible_time.timeout
	_hurt_box.monitorable = true



func set_bounds(_maximum_boundary : Vector2, _minimum_boundary : Vector2):
	var sprite_size : Vector2 = _sprite.get_rect().size
	_is_bound = true
	_maximum = _maximum_boundary
	_minimum = _minimum_boundary
	
	_minimum.x += sprite_size.x / 2
	_maximum.x -= sprite_size.x / 2
	
	_minimum.y += sprite_size.y



func face_left():
	if _is_dead:
		return
	_is_facing_left = true
	_sprite.flip_h = not _sprite_face_left
	changed_direction.emit(_is_facing_left)



func face_right():
	if _is_dead:
		return
	_is_facing_left = false
	_sprite.flip_h = _sprite_face_left
	changed_direction.emit(_is_facing_left)


func run(direction : float):
	if _is_dead:
		return
	_direction = direction


func jump():
	if _is_dead:
		return
	if _is_in_water:
		if _is_below_surface:
			velocity.y = _jump_velocity * _drag
			landed.emit(position.y)
		else:
			velocity.y = _jump_velocity
	elif is_on_floor():
		velocity.y = _jump_velocity
		_spawn_dust(_jump_dust)


func stop_jump():
	if _is_dead:
		return
	if velocity.y < 0  && not _is_in_water:
		velocity.y = 0



func enter_water(water_surface_height : float):
	_water_surface_height = water_surface_height
	_is_in_water = true
	_is_below_surface = false
	landed.emit(position.y)
	if velocity.y > 0:
		velocity.y *= _drag


func exit_water():
	_is_in_water = false

func dive():
	_is_below_surface = true
	



func _physics_process(delta: float):
	if not _is_facing_left && sign(_direction) == -1:
		face_left()
	elif _is_facing_left && sign(_direction) == 1:
		face_right()
	if _is_in_water:
		_water_physics(delta)
	elif is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
		_was_on_floor = is_on_floor()
	
	move_and_slide()

	if not _was_on_floor and is_on_floor():
		_landed()

	if _is_bound:
		position.x = clamp(position.x, _minimum.x, _maximum.x)
		position.y = clamp(position.y, _minimum.y, _maximum.y)




func _water_physics(delta : float):
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0, _deceleration * _drag * delta)
	else:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _drag * delta)
	if _is_below_surface || _density > 0:
		velocity.y = move_toward(velocity.y, gravity * _density * _drag, gravity * _drag * delta)
	elif position.y - float(Global.pixelpertile) / 4 < _water_surface_height:
		velocity.y = move_toward(velocity.y, gravity * _density * _drag, gravity * _drag * delta)
	else:
		velocity.y = move_toward(velocity.y, gravity * _density * _drag * -1, gravity * _drag * delta)




func _ground_physics(delta : float):
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)
	elif velocity.x == 0 || sign(_direction) == sinh(velocity.x):
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, _direction * _speed, _deceleration * delta)



func _air_physics(delta : float):
	velocity += get_gravity() * delta
	if _direction:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _air_control * delta)


func _landed():
	landed.emit(position.y)

func _spawn_dust(dust : PackedScene):
	var _dust = dust.instantiate()
	_dust.position = position
	_dust.flip_h = _sprite.flip_h
	get_parent().add_child(_dust)


func revive():
	_is_dead = false
	_current_health = _max_health
	_hurt_box.monitorable = true
	collision_layer = _collision_layer
	collision_mask = _collision_mask
	landed.emit(global_position.y)
	health_changed.emit(float(_current_health) / _max_health)

func _die():
	_is_dead = true
	dead.emit()
	_hurt_box.set_deferred("monitorable", false)
	collision_layer = 0 
	collision_mask = 1
	_direction = 0
	
