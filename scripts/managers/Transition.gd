extends CanvasLayer

@onready var fade_tex: TextureRect = $fade/TextureRect
var _is_busy := false

func _ready() -> void:
	fade_tex.modulate = Color(0, 0, 0, 0) # transparan awal
	fade_tex.visible = true

func fade_out(duration: float = 0.25) -> void:
	if _is_busy:
		return
	_is_busy = true
	var tw := create_tween()
	tw.tween_property(fade_tex, "modulate:a", 1.0, duration)
	await tw.finished
	_is_busy = false

func fade_in(duration: float = 0.25) -> void:
	if _is_busy:
		return
	_is_busy = true
	var tw := create_tween()
	tw.tween_property(fade_tex, "modulate:a", 0.0, duration)
	await tw.finished
	_is_busy = false
