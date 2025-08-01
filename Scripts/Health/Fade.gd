extends ColorRect

var _black : Color = Color(0, 0, 0, 1)
var _clear : Color = Color(0, 0, 0, 0)
var _color_tween : Tween

func fade(new_color : Color) -> Signal:
	if _color_tween && _color_tween.is_running():
		_color_tween.kill()
	_color_tween =  create_tween()
	_color_tween.tween_property(self, "color", new_color, 1)
	return _color_tween.finished
	
func fade_to_clear() -> Signal:
	return fade(_clear)
	
func fade_to_black() -> Signal:
	return fade(_black)
