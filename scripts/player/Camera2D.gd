extends Camera2D
@export var blend_time := 0.6

func _ready() -> void:
	var player := get_parent() as Node2D
	var target_position := player.global_position if player else global_position
	#var previous_camera_position := GameState.last_camera_pos
	#var has_previous_camera := previous_camera_position != Vector2.ZERO

	position_smoothing_enabled = false
	#if has_previous_camera:
		#global_position = previous_camera_position
	#else:
		#global_position = target_position

	await get_tree().process_frame

	#if has_previous_camera:
		#var tw := create_tween()
		#tw.tween_property(self, "global_position", target_position, blend_time)
		#await tw.finished

	position_smoothing_enabled = true
	await Transition.fade_in(0.25)
