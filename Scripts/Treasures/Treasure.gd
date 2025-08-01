class_name Treasure extends CollisionObject2D


@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
var _character : Character


func _on_body_entered(body: Node) -> void:
	_sfx.play()
	if not body is Character:
		return
	_character = body
	_collect()
	collision_mask = 0
	_sprite.play("Effect")
	await _sprite.animation_finished
	queue_free()

func _collect():
	pass
