extends Treasure

@export var _amount_recovered : int = 3

func _collect():
	_character.recover(_amount_recovered)
