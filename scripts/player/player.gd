extends CharacterBody2D

const SPEED          = 1220.0
const ACCEL          = 3500.0
const DECEL          = 4000.0
const AIR_ACCEL      = 2400.0
const AIR_DECEL      = 1200.0

const JUMP_FORCE     = -1520.0
const GRAVITY_UP     = 2000.0
const GRAVITY_DOWN   = 2800.0
const JUMP_CUT       = 0.4
const COYOTE_TIME    = 0.1
const JUMP_BUFFER    = 0.1
const MAX_AIR_JUMPS  = 1

const DASH_SPEED     = 3800.0
const DASH_TIME      = 0.125
const DASH_COOLDOWN  = 0.05

var is_dashing       = false
var dash_timer       = 0.0
var dash_used        = false
var dash_cooldown    = 0.0
var dash_direction   = Vector2.ZERO

var coyote_timer     = 0.0
var jump_buffer      = 0.0
var was_on_floor     = false
var is_jump_cut      = false
var air_jumps_left   = MAX_AIR_JUMPS

@onready var anim = $AnimatedSprite2D

# === INTRO AUTO WALK ===
@export var enable_intro := true
@export var intro_target_x := 500.0
@export var intro_speed := 140.0

var can_control := false
var auto_walk := true

# === DEATH ===
var spawn_position   : Vector2
var is_dead          := false


func _ready():
	spawn_position = global_position
	auto_walk = enable_intro
	can_control = not enable_intro


func _physics_process(delta):
	if is_dead:
		return

	var on_floor = is_on_floor()

	# === AUTO WALK INTRO ===
	if auto_walk:
		if not on_floor:
			velocity.y += GRAVITY_DOWN * delta
		else:
			velocity.y = 0.0
			air_jumps_left = MAX_AIR_JUMPS

		velocity.x = move_toward(velocity.x, intro_speed, 200.0 * delta)

		if global_position.x >= intro_target_x:
			auto_walk   = false
			can_control = true
			velocity.x  = 0.0

		move_and_slide()
		was_on_floor = is_on_floor()
		anim.flip_h  = false
		anim.play("walk")
		return
	
	# === CONTROL LOCK ===
	if not can_control:
		move_and_slide()
		was_on_floor = is_on_floor()
		update_animation()
		return

	# === DASH COOLDOWN ===
	if dash_cooldown > 0:
		dash_cooldown -= delta

	# === ISI ULANG DASH DAN DOUBLE JUMP SAAT LANDING ===
	if on_floor:
		air_jumps_left = MAX_AIR_JUMPS

	if on_floor and not was_on_floor:
		dash_used = false

	# === COYOTE TIME ===
	if was_on_floor and not on_floor and not is_dashing:
		coyote_timer = COYOTE_TIME
	if coyote_timer > 0:
		coyote_timer -= delta

	# === JUMP BUFFER ===
	if Input.is_action_just_pressed("ui_up"):
		jump_buffer = JUMP_BUFFER
	if jump_buffer > 0:
		jump_buffer -= delta

	# === GRAVITY ===
	if not on_floor and not is_dashing:
		if velocity.y < 0:
			velocity.y += GRAVITY_UP * delta
		else:
			velocity.y += GRAVITY_DOWN * delta

	# === DASH ===
	if is_dashing:
		dash_timer -= delta
		velocity.x  = dash_direction.x * DASH_SPEED
		velocity.y  = 0.0
		if dash_timer <= 0:
			is_dashing    = false
			dash_cooldown = DASH_COOLDOWN
			velocity.x    = dash_direction.x * SPEED * 0.8
	else:
		# === HORIZONTAL MOVEMENT ===
		var dir = 0
		if Input.is_action_pressed("ui_right"):
			dir += 1
		if Input.is_action_pressed("ui_left"):
			dir -= 1

		var accel = ACCEL if on_floor else AIR_ACCEL
		var decel = DECEL if on_floor else AIR_DECEL

		if dir != 0:
			velocity.x = move_toward(velocity.x, float(dir) * SPEED, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, decel * delta)

		# === JUMP + DOUBLE JUMP ===
		var can_ground_jump = on_floor or coyote_timer > 0
		var can_air_jump = not can_ground_jump and air_jumps_left > 0

		if jump_buffer > 0 and (can_ground_jump or can_air_jump):
			velocity.y = JUMP_FORCE
			jump_buffer = 0.0
			is_jump_cut = false

			if can_ground_jump:
				coyote_timer = 0.0
			else:
				air_jumps_left -= 1

		if Input.is_action_just_released("ui_up") and velocity.y < 0:
			velocity.y *= JUMP_CUT

		# === DASH TRIGGER ===
		if Input.is_action_just_pressed("ui_accept") and not dash_used and dash_cooldown <= 0:
			start_dash(dir)

	move_and_slide()
	was_on_floor = is_on_floor()
	update_animation()


func die():
	if is_dead:
		return
	is_dead = true

	# stop semua gerakan
	velocity = Vector2.ZERO
	is_dashing = false
	dash_used = false
	dash_timer = 0.0
	dash_cooldown = 0.0
	coyote_timer = 0.0
	jump_buffer = 0.0
	air_jumps_left = MAX_AIR_JUMPS

	# optional: kasih efek "mati stop dulu"
	await get_tree().create_timer(0.25).timeout

	# respawn
	global_position = spawn_position

	was_on_floor = false

	# balik ke intro / atau langsung kontrol
	auto_walk = enable_intro
	can_control = not enable_intro

	# kasih delay kecil sebelum bisa gerak lagi
	await get_tree().create_timer(0.15).timeout

	is_dead = false


func start_dash(dir: int):
	if dir == 0:
		dir = -1 if anim.flip_h else 1
	is_dashing     = true
	dash_used      = true
	dash_timer     = DASH_TIME
	dash_direction = Vector2(float(dir), 0.0)


func update_animation():
	if not is_dashing and velocity.x != 0:
		anim.flip_h = velocity.x < 0

	if is_dashing:
		anim.play("dash")
	elif not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("jump")
	elif abs(velocity.x) > 10:
		anim.play("walk")
	else:
		anim.play("idle")
