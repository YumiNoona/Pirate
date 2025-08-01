extends Node2D

@export_range(1, 100) var _damage : int = 1


func _on_hit_box_area_entered(area: Area2D):
	area.get_parent().take_damage(_damage, (area.global_position - global_position).normalized())
	
