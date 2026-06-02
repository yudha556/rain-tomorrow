extends Area2D

@export_file("*.tscn") var next_scene: String = "res://scenes/ch01/scene2.tscn"
var packed_next: PackedScene

func _ready() -> void:
	packed_next = load(next_scene)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	var cam := get_viewport().get_camera_2d()
	#if cam:
		#GameState.last_camera_pos = cam.global_position

	await Transition.fade_out(0.25)
	get_tree().change_scene_to_packed(packed_next)
