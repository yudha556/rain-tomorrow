extends Camera2D
@export var blend_time := 0.6

func _ready() -> void:
	# start dari posisi kamera scene sebelumnya
	global_position = GameState.last_camera_pos

	# matiin smoothing sementara buat transisi awal
	position_smoothing_enabled = false
	await get_tree().process_frame

	var player := get_parent() as Node2D
	if player:
		var tw := create_tween()
		tw.tween_property(self, "global_position", player.global_position, blend_time)
		await tw.finished

	# balik ke setting manual kamera
	position_smoothing_enabled = true
	await Transition.fade_in(0.25)
