class_name Player
extends CharacterBody2D

# player.gd — Controlador del Héroe (Lucian) para Heroes Lore: Zero Port
# Incorpora el sistema canónico de los 6 Slots de Acción:
#   Slot 1: Habilidad de Clase 1 (Golpe Brutal · 12 MP) [Tecla 1 / LB]
#   Slot 2: Habilidad de Clase 2 (Embestida · 15 MP) [Tecla 2 / RB]
#   Slot 3: Habilidad Elemental 1 (Onda Ígnea · 10 MP) [Tecla 3 / LT]
#   Slot 4: Habilidad Elemental 2 (Rayo de Choque 360° · 14 MP) [Tecla 4 / RT]
#   Slot 5: Consumible Recuperación HP (Poción · +50 HP) [Tecla 5 o Q / D-Pad Arriba]
#   Slot 6: Consumible Recuperación MP (Poción · +25 MP) [Tecla 6 o R / D-Pad Abajo]

signal hp_changed(current: int, max_hp: int)
signal sp_changed(current: int, max_sp: int)
signal ep_changed(current: int, max_ep: int)
signal exp_gained(amount: int, current_exp: int, next_exp: int)
signal level_up(new_level: int)
signal died()
signal interacted_with(target: Node)
signal slot_cooldown_updated(slot_idx: int, current_cd: float, max_cd: float)
signal potions_updated(hp_count: int, mp_count: int)

enum State {
	IDLE,
	MOVE,
	ATTACK,
	SKILL_CAST,
	HURT,
	DEAD
}

enum Direction {
	DOWN = 0,
	UP = 1,
	LEFT = 2,
	RIGHT = 3
}

# --- Atributos de Personaje (Clase Asesino · Lucian) ---
@export var character_name: String = "Lucian"
@export var character_class: String = "Asesino"
@export var level: int = 1
@export var max_hp: int = 110
@export var current_hp: int = 110
@export var max_sp: int = 35     # Habilidades de Clase (Barra Azul)
@export var current_sp: int = 35
@export var max_ep: int = 50     # Habilidades Elementales (Barra Verde)
@export var current_ep: int = 50
@export var base_atk: int = 16
@export var base_def: int = 8
@export var crit_rate: float = 0.18   # 18% Crítico base de Asesino
@export var evasion_rate: float = 0.20 # 20% Evasión base de Asesino
@export var current_exp: int = 0
@export var next_level_exp: int = 70

# Compatibilidad con código anterior
var current_mp: int:
	get: return current_sp
	set(v): current_sp = v
var max_mp: int:
	get: return max_sp
	set(v): max_sp = v

# --- Inventario de Consumibles ---
@export var inventory_potions_hp: int = 3
@export var inventory_potions_mp: int = 3

# --- Tiempos de Enfriamiento Máximos (Cooldowns en segundos) ---
const CD_MAX_SLOT_1: float = 2.0  # Golpe Brutal (Clase)
const CD_MAX_SLOT_2: float = 3.5  # Embestida (Clase)
const CD_MAX_SLOT_3: float = 2.5  # Onda Ígnea (Elemental)
const CD_MAX_SLOT_4: float = 4.0  # Rayo 360° (Elemental)
const CD_MAX_SLOT_5: float = 1.0  # Poción HP
const CD_MAX_SLOT_6: float = 1.0  # Poción SP

# --- Costes de SP (Clase) y EP (Elemental) ---
const SP_COST_SLOT_1: int = 12
const SP_COST_SLOT_2: int = 15
const EP_COST_SLOT_3: int = 10
const EP_COST_SLOT_4: int = 14

# Tiempos de enfriamiento actuales
var cd_timer_1: float = 0.0
var cd_timer_2: float = 0.0
var cd_timer_3: float = 0.0
var cd_timer_4: float = 0.0
var cd_timer_5: float = 0.0
var cd_timer_6: float = 0.0

# Movimiento (42 px/s * 4 = 168 px/s a escala 4x)
const BASE_SPEED_4X: float = 168.0

var current_state: State = State.IDLE
var current_dir: Direction = Direction.DOWN
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0
var move_dir: Vector2 = Vector2.ZERO

# Texturas direccionales ilustradas de Lucian
var tex_down: Texture2D
var tex_up: Texture2D
var tex_side: Texture2D

# Variables para animación de paso, balanceo y respiración
var walk_anim_timer: float = 0.0
var idle_anim_timer: float = 0.0
var step_dust_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Polygon2D = $Shadow
@onready var slash_vfx: Sprite2D = $SlashVFX
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: CollisionShape2D = $CollisionShape2D

var fireball_scene: PackedScene


func _ready() -> void:
	fireball_scene = load("res://scenes/Fireball.tscn")
	
	# Cargar sprites direccionales ilustrados
	var down_path := "res://art_samples/hero_lucian_down.png"
	if ResourceLoader.exists(down_path):
		tex_down = load(down_path) as Texture2D
	elif ResourceLoader.exists("res://art_samples/hero_lucian_idle.png"):
		tex_down = load("res://art_samples/hero_lucian_idle.png") as Texture2D
		
	var up_path := "res://art_samples/hero_lucian_up.png"
	if ResourceLoader.exists(up_path):
		tex_up = load(up_path) as Texture2D
		
	var side_path := "res://art_samples/hero_lucian_side.png"
	if ResourceLoader.exists(side_path):
		tex_side = load(side_path) as Texture2D
		
	if tex_down:
		sprite.texture = tex_down
	
	var slash_path := "res://art_samples/vfx_sword_slash.png"
	if ResourceLoader.exists(slash_path):
		var slash_tex := load(slash_path) as Texture2D
		if slash_tex:
			slash_vfx.texture = slash_tex
	slash_vfx.visible = false
	
	GameClock.game_tick.connect(_on_game_tick)
	
	emit_signal("hp_changed", current_hp, max_hp)
	emit_signal("sp_changed", current_sp, max_sp)
	emit_signal("ep_changed", current_ep, max_ep)
	emit_signal("potions_updated", inventory_potions_hp, inventory_potions_mp)


func _on_game_tick(tick_count: int) -> void:
	if current_state == State.DEAD:
		return
	# Regeneración natural de EP (Verde) durante la batalla: +2 EP cada segundo (14 ticks)
	if tick_count % 14 == 0 and current_ep < max_ep:
		current_ep = mini(max_ep, current_ep + 2)
		emit_signal("ep_changed", current_ep, max_ep)
		
	# Regeneración leve de SP (Azul): +1 SP cada 2 segundos (28 ticks)
	if tick_count % 28 == 0 and current_sp < max_sp:
		current_sp = mini(max_sp, current_sp + 1)

func _process(delta: float) -> void:
	# Actualizar enfriamientos de los 6 slots
	if cd_timer_1 > 0.0:
		cd_timer_1 = maxf(0.0, cd_timer_1 - delta)
		emit_signal("slot_cooldown_updated", 1, cd_timer_1, CD_MAX_SLOT_1)
	if cd_timer_2 > 0.0:
		cd_timer_2 = maxf(0.0, cd_timer_2 - delta)
		emit_signal("slot_cooldown_updated", 2, cd_timer_2, CD_MAX_SLOT_2)
	if cd_timer_3 > 0.0:
		cd_timer_3 = maxf(0.0, cd_timer_3 - delta)
		emit_signal("slot_cooldown_updated", 3, cd_timer_3, CD_MAX_SLOT_3)
	if cd_timer_4 > 0.0:
		cd_timer_4 = maxf(0.0, cd_timer_4 - delta)
		emit_signal("slot_cooldown_updated", 4, cd_timer_4, CD_MAX_SLOT_4)
	if cd_timer_5 > 0.0:
		cd_timer_5 = maxf(0.0, cd_timer_5 - delta)
		emit_signal("slot_cooldown_updated", 5, cd_timer_5, CD_MAX_SLOT_5)
	if cd_timer_6 > 0.0:
		cd_timer_6 = maxf(0.0, cd_timer_6 - delta)
		emit_signal("slot_cooldown_updated", 6, cd_timer_6, CD_MAX_SLOT_6)

	if is_invulnerable:
		invulnerable_timer -= delta
		sprite.modulate.a = 0.4 if fmod(invulnerable_timer * 10.0, 1.0) > 0.5 else 1.0
		if invulnerable_timer <= 0.0:
			is_invulnerable = false
			sprite.modulate.a = 1.0


func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
		
	# Movimiento direccional
	move_dir = InputManager.get_movement_vector()
	
	if current_state != State.ATTACK and current_state != State.SKILL_CAST and current_state != State.HURT:
		if move_dir.length() > 0.05:
			current_state = State.MOVE
			_update_facing_direction(move_dir)
			velocity = move_dir.normalized() * BASE_SPEED_4X
			move_and_slide()
			
			# Ciclo de animación de caminata / trote dinámico (Walking Bob & Sway)
			walk_anim_timer += delta * 14.0
			var bob := absf(sin(walk_anim_timer)) * 4.5
			sprite.offset.y = -64.0 - bob
			
			# Balanceo corporal rítmico (inclinación de peso entre pies)
			if current_dir == Direction.LEFT or current_dir == Direction.RIGHT:
				var lean_dir := 1.0 if current_dir == Direction.RIGHT else -1.0
				sprite.rotation = lean_dir * (0.04 + sin(walk_anim_timer) * 0.035)
			else:
				sprite.rotation = sin(walk_anim_timer * 0.5) * 0.045
				
			# Compresión y estiramiento dinámico (Squash & Stretch de impacto)
			var squash := sin(walk_anim_timer * 2.0) * 0.03
			sprite.scale = Vector2(1.0 + squash, 1.0 - squash)
			
			# Sombra adaptativa al elevar los pies
			shadow.scale = Vector2.ONE * (1.0 - (bob / 4.5) * 0.15)
			
			# Emisión de polvo ligero en las pisadas
			step_dust_cooldown -= delta
			if sin(walk_anim_timer) < -0.85 and step_dust_cooldown <= 0.0:
				_spawn_step_dust()
				step_dust_cooldown = 0.22
		else:
			current_state = State.IDLE
			velocity = Vector2.ZERO
			
			# Animación de respiración / guardia (Idle Breathing)
			idle_anim_timer += delta * 2.5
			walk_anim_timer = 0.0
			
			sprite.offset.y = lerpf(sprite.offset.y, -64.0, delta * 12.0)
			sprite.rotation = lerpf(sprite.rotation, 0.0, delta * 12.0)
			
			var breath := sin(idle_anim_timer) * 0.015
			sprite.scale = Vector2(1.0 - breath * 0.5, 1.0 + breath)
			shadow.scale = Vector2.ONE
	elif current_state != State.SKILL_CAST and current_state != State.HURT:
		velocity = Vector2.ZERO
		
	# Ataque Básico Melee
	if Input.is_action_just_pressed("attack") and _can_act():
		perform_attack()
		
	# Los 6 Slots de Acción
	if Input.is_action_just_pressed("slot_1_skill") and _can_act():
		use_slot_1_skill()
	elif Input.is_action_just_pressed("slot_2_skill") and _can_act():
		use_slot_2_skill()
	elif Input.is_action_just_pressed("slot_3_elem") and _can_act():
		use_slot_3_elem()
	elif Input.is_action_just_pressed("slot_4_elem") and _can_act():
		use_slot_4_elem()
	elif Input.is_action_just_pressed("slot_5_item_hp") and current_state != State.DEAD:
		use_slot_5_item_hp()
	elif Input.is_action_just_pressed("slot_6_item_mp") and current_state != State.DEAD:
		use_slot_6_item_mp()
	elif Input.is_action_just_pressed("interact") and current_state != State.DEAD:
		_try_interact()


func _can_act() -> bool:
	return current_state != State.ATTACK and current_state != State.SKILL_CAST and current_state != State.HURT and current_state != State.DEAD


func _update_facing_direction(input: Vector2) -> void:
	if absf(input.x) > absf(input.y) * 0.8:
		current_dir = Direction.RIGHT if input.x > 0 else Direction.LEFT
		if tex_side:
			sprite.texture = tex_side
		sprite.flip_h = (current_dir == Direction.LEFT)
	else:
		if input.y > 0:
			current_dir = Direction.DOWN
			if tex_down:
				sprite.texture = tex_down
			sprite.flip_h = false
		else:
			current_dir = Direction.UP
			if tex_up:
				sprite.texture = tex_up
			sprite.flip_h = false


func _get_dir_vector() -> Vector2:
	match current_dir:
		Direction.DOWN: return Vector2.DOWN
		Direction.UP: return Vector2.UP
		Direction.LEFT: return Vector2.LEFT
		Direction.RIGHT: return Vector2.RIGHT
	return Vector2.DOWN


## SLOT 1: Habilidad de Clase 1 — Golpe Brutal (Guerrero · Consume SP Azul)
func use_slot_1_skill() -> void:
	if cd_timer_1 > 0.0:
		_spawn_floating_text("¡En recarga!", Color(0.8, 0.8, 0.8))
		return
	if current_sp < SP_COST_SLOT_1:
		_spawn_floating_text("¡Sin SP suficiente!", Color(0.3, 0.6, 1.0))
		return
		
	current_sp -= SP_COST_SLOT_1
	cd_timer_1 = CD_MAX_SLOT_1
	emit_signal("sp_changed", current_sp, max_sp)
	current_state = State.ATTACK
	
	_spawn_floating_text("¡ATAQUE SORPRESA!", Color(0.85, 0.4, 1.0))
	_spawn_afterimage()
	
	# Efecto visual sombrío ampliado y 180% de daño
	var dir_vec := _get_dir_vector()
	attack_area.position = dir_vec * 56
	slash_vfx.position = dir_vec * 56
	slash_vfx.rotation = dir_vec.angle()
	slash_vfx.modulate = Color(1.6, 0.5, 1.8, 1.0)
	slash_vfx.scale = Vector2(1.6, 1.6)
	slash_vfx.visible = true
	
	var tween := create_tween()
	tween.tween_property(sprite, "offset", Vector2(0, -64) + dir_vec * 24.0, 0.08)
	tween.parallel().tween_property(sprite, "scale", Vector2(1.25, 0.85), 0.08)
	tween.parallel().tween_property(slash_vfx, "modulate:a", 0.0, 0.25)
	tween.tween_property(sprite, "offset", Vector2(0, -64), 0.12)
	tween.parallel().tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.12)
	tween.tween_callback(func():
		slash_vfx.visible = false
		slash_vfx.scale = Vector2(1.0, 1.0)
		if current_state == State.ATTACK: current_state = State.IDLE
	)
	
	for body in attack_area.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):
			var heavy_dmg := int(base_atk * 1.8)
			body.take_damage(heavy_dmg, true, global_position)


## SLOT 2: Habilidad de Clase 2 — Danza Sombría (Asesino · Consume SP Azul)
func use_slot_2_skill() -> void:
	if cd_timer_2 > 0.0:
		_spawn_floating_text("¡En recarga!", Color(0.8, 0.8, 0.8))
		return
	if current_sp < SP_COST_SLOT_2:
		_spawn_floating_text("¡Sin SP suficiente!", Color(0.3, 0.6, 1.0))
		return
		
	current_sp -= SP_COST_SLOT_2
	cd_timer_2 = CD_MAX_SLOT_2
	emit_signal("sp_changed", current_sp, max_sp)
	current_state = State.SKILL_CAST
	
	_spawn_floating_text("¡DANZA SOMBRÍA!", Color(0.5, 0.9, 1.0))
	_spawn_afterimage()
	
	var dir_vec := _get_dir_vector()
	velocity = dir_vec * 550.0 # Embestida supersónica
	
	var dash_tween := create_tween()
	dash_tween.tween_property(sprite, "modulate", Color(1.2, 0.8, 1.8), 0.05)
	dash_tween.tween_interval(0.10)
	dash_tween.tween_callback(_spawn_afterimage)
	dash_tween.tween_interval(0.10)
	dash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.08)
	dash_tween.tween_callback(func():
		velocity = Vector2.ZERO
		if current_state == State.SKILL_CAST: current_state = State.IDLE
	)
	
	var check_time := 0.20
	var timer := get_tree().create_timer(check_time)
	timer.timeout.connect(func():
		var space := get_world_2d().direct_space_state
		var query := PhysicsShapeQueryParameters2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 48.0
		query.shape = circle
		query.transform = global_transform
		query.collide_with_bodies = true
		for res in space.intersect_shape(query):
			var b = res.collider
			if b != self and b.has_method("take_damage"):
				b.take_damage(int(base_atk * 1.5), true, global_position)
				if b.has_method("spawn_floating_text"):
					b.spawn_floating_text("¡ATURDIDO!", Color(1.0, 0.9, 0.2))
	)


## SLOT 3: Habilidad Elemental 1 — Onda Ígnea (Consume EP Verde)
func use_slot_3_elem() -> void:
	if cd_timer_3 > 0.0:
		_spawn_floating_text("¡En recarga!", Color(0.8, 0.8, 0.8))
		return
	if current_ep < EP_COST_SLOT_3:
		_spawn_floating_text("¡Sin EP suficiente!", Color(0.2, 0.9, 0.4))
		return
		
	current_ep -= EP_COST_SLOT_3
	cd_timer_3 = CD_MAX_SLOT_3
	emit_signal("ep_changed", current_ep, max_ep)
	
	_spawn_floating_text("¡ONDA ÍGNEA!", Color(1.0, 0.4, 0.1))
	
	# Disparar bola de fuego en la dirección que mira Lucian
	if fireball_scene:
		var fb: Node2D = fireball_scene.instantiate() as Node2D
		var dir_vec := _get_dir_vector()
		fb.set("direction", dir_vec)
		fb.global_position = global_position + dir_vec * 32.0 + Vector2(0, -32)
		get_parent().add_child(fb)


## SLOT 4: Habilidad Elemental 2 — Rayo de Choque 360° (Consume EP Verde)
func use_slot_4_elem() -> void:
	if cd_timer_4 > 0.0:
		_spawn_floating_text("¡En recarga!", Color(0.8, 0.8, 0.8))
		return
	if current_ep < EP_COST_SLOT_4:
		_spawn_floating_text("¡Sin EP suficiente!", Color(0.2, 0.9, 0.4))
		return
		
	current_ep -= EP_COST_SLOT_4
	cd_timer_4 = CD_MAX_SLOT_4
	emit_signal("ep_changed", current_ep, max_ep)
	
	_spawn_floating_text("¡DESCARGA ELÉCTRICA!", Color(0.4, 0.9, 1.0))
	
	# Anillo de energía expansivo 360°
	var ring := Polygon2D.new()
	var points := PackedVector2Array()
	var segments := 24
	var radius := 160.0
	for idx in range(segments):
		var ang := (idx / float(segments)) * TAU
		points.append(Vector2(cos(ang) * radius, sin(ang) * radius))
	ring.polygon = points
	ring.color = Color(0.3, 0.85, 1.0, 0.6)
	ring.position = Vector2(0, -32)
	add_child(ring)
	
	var ring_tween := create_tween()
	ring.scale = Vector2(0.1, 0.1)
	ring_tween.tween_property(ring, "scale", Vector2(1.0, 1.0), 0.18)
	ring_tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.25)
	ring_tween.tween_callback(ring.queue_free)
	
	# Daño radial a todos los enemigos en 160px
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	query.shape = circle
	query.transform = global_transform
	query.collide_with_bodies = true
	
	for res in space.intersect_shape(query):
		var target: Node = res.collider
		if target != self and target.has_method("take_damage"):
			target.take_damage(22, true, global_position)
			if target.has_method("spawn_floating_text"):
				target.spawn_floating_text("¡ELECTROCUTADO!", Color(0.4, 0.9, 1.0))


## SLOT 5: Objeto de Recuperación HP (Poción de Vida)
func use_slot_5_item_hp() -> void:
	if cd_timer_5 > 0.0: return
	if inventory_potions_hp <= 0:
		_spawn_floating_text("¡Sin pociones de HP!", Color(1.0, 0.4, 0.4))
		return
	if current_hp >= max_hp:
		_spawn_floating_text("¡HP al máximo!", Color(0.7, 0.9, 0.7))
		return
		
	cd_timer_5 = CD_MAX_SLOT_5
	inventory_potions_hp -= 1
	var heal: int = 50
	current_hp = mini(max_hp, current_hp + heal)
	emit_signal("hp_changed", current_hp, max_hp)
	emit_signal("potions_updated", inventory_potions_hp, inventory_potions_mp)
	_spawn_floating_text("+%d HP" % heal, Color(0.2, 1.0, 0.4))


## SLOT 6: Objeto de Recuperación SP (Poción de Maná/SP)
func use_slot_6_item_mp() -> void:
	if cd_timer_6 > 0.0: return
	if inventory_potions_mp <= 0:
		_spawn_floating_text("¡Sin pociones de SP!", Color(0.4, 0.6, 1.0))
		return
	if current_sp >= max_sp:
		_spawn_floating_text("¡SP al máximo!", Color(0.6, 0.8, 1.0))
		return
		
	cd_timer_6 = CD_MAX_SLOT_6
	inventory_potions_mp -= 1
	var sp_heal: int = 25
	current_sp = mini(max_sp, current_sp + sp_heal)
	emit_signal("sp_changed", current_sp, max_sp)
	emit_signal("potions_updated", inventory_potions_hp, inventory_potions_mp)
	_spawn_floating_text("+%d SP" % sp_heal, Color(0.3, 0.7, 1.0))


# ==============================================================================
# COMBATE BÁSICO Y DAÑO
# ==============================================================================

func perform_attack() -> void:
	current_state = State.ATTACK
	var dir_vec := _get_dir_vector()
	attack_area.position = dir_vec * 48
	slash_vfx.position = dir_vec * 44
	slash_vfx.rotation = dir_vec.angle()
	slash_vfx.modulate = Color(1.3, 1.3, 1.4, 1.0)
	slash_vfx.visible = true
	
	# Estocada ágil con dagas (avance rápido en la dirección y retorno)
	var lunge_offset := dir_vec * 16.0
	var tween := create_tween()
	tween.tween_property(sprite, "offset", Vector2(0, -64) + lunge_offset, 0.07).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "scale", Vector2(1.15, 0.88), 0.07)
	tween.parallel().tween_property(slash_vfx, "modulate:a", 0.0, 0.20)
	tween.tween_property(sprite, "offset", Vector2(0, -64), 0.10).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.10)
	tween.tween_callback(func():
		slash_vfx.visible = false
		slash_vfx.modulate.a = 1.0
		if current_state == State.ATTACK: current_state = State.IDLE
	)
	
	for body in attack_area.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):
			_deal_damage_to(body)


func _deal_damage_to(target: Node) -> void:
	var target_def: int = target.get("base_def") if "base_def" in target else 5
	var target_eva: int = target.get("base_eva") if "base_eva" in target else 6
	if randi_range(1, 99) > (100 - target_eva):
		if target.has_method("spawn_floating_text"):
			target.spawn_floating_text("FALLO", Color(0.8, 0.8, 0.8))
		return
		
	var var_range: int = maxi(1, int(base_atk / 20.0))
	var variance: int = randi_range(-var_range, var_range)
	var damage: int = maxi(1, base_atk - target_def + variance)
	
	var crit_prob: int = maxi(10, 60 - target_def)
	var is_crit: bool = (randi_range(0, 99) < crit_prob)
	if is_crit: damage = int(damage * 1.5)
		
	target.take_damage(damage, is_crit, global_position)


func take_damage(amount: int, from_pos: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or current_state == State.DEAD:
		return
		
	var net_damage: int = maxi(1, amount - int(base_def * 0.3))
	current_hp = maxi(0, current_hp - net_damage)
	emit_signal("hp_changed", current_hp, max_hp)
	_spawn_floating_text("-%d" % net_damage, Color(1.0, 0.25, 0.25))
	
	if current_hp <= 0:
		_die()
		return
		
	current_state = State.HURT
	is_invulnerable = true
	invulnerable_timer = 0.5
	
	if from_pos != Vector2.ZERO:
		var knockback_dir := (global_position - from_pos).normalized()
		velocity = knockback_dir * 120.0
		move_and_slide()
		
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.3, 0.3), 0.08)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)
	tween.tween_callback(func():
		if current_state == State.HURT: current_state = State.IDLE
	)


func gain_exp(amount: int) -> void:
	current_exp += amount
	_spawn_floating_text("+%d EXP" % amount, Color(0.3, 0.7, 1.0))
	emit_signal("exp_gained", amount, current_exp, next_level_exp)
	if current_exp >= next_level_exp:
		_level_up()


func _level_up() -> void:
	level += 1
	current_exp -= next_level_exp
	next_level_exp = int(50.0 * pow(level, 2.2) + 20.0 * level)
	max_hp += 28
	current_hp = max_hp
	max_sp += 6
	current_sp = max_sp
	max_ep += 5
	current_ep = max_ep
	base_atk += 5
	base_def += 3
	emit_signal("level_up", level)
	emit_signal("hp_changed", current_hp, max_hp)
	emit_signal("sp_changed", current_sp, max_sp)
	emit_signal("ep_changed", current_ep, max_ep)
	_spawn_floating_text("¡SUBE DE NIVEL! (Nv. %d)" % level, Color(1.0, 0.85, 0.1))


func _die() -> void:
	current_state = State.DEAD
	velocity = Vector2.ZERO
	emit_signal("died")
	_spawn_floating_text("HAS MUERTO", Color(0.9, 0.1, 0.1))
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.2)


func _try_interact() -> void:
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 64.0
	query.shape = circle
	query.transform = global_transform
	query.collide_with_areas = true
	query.collide_with_bodies = true
	for res in space.intersect_shape(query):
		var collider: Node = res.collider
		if collider != self and collider.has_method("interact"):
			collider.interact(self)
			emit_signal("interacted_with", collider)
			return


func _spawn_floating_text(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.modulate = color
	label.z_index = 100
	label.position = Vector2(-40, -140)
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)


func _spawn_step_dust() -> void:
	var dust := Polygon2D.new()
	var pts := PackedVector2Array()
	var segs := 6
	var rad := randf_range(3.5, 6.0)
	for i in range(segs):
		var ang := (i / float(segs)) * TAU
		pts.append(Vector2(cos(ang) * rad, sin(ang) * (rad * 0.6)))
	dust.polygon = pts
	dust.color = Color(0.85, 0.80, 0.70, 0.45)
	
	var foot_offset := -_get_dir_vector() * randf_range(6.0, 10.0) + Vector2(randf_range(-4, 4), randf_range(-2, 2))
	dust.global_position = global_position + foot_offset
	get_parent().add_child(dust)
	
	var dtween := create_tween()
	dtween.tween_property(dust, "scale", Vector2(1.8, 1.8), 0.22)
	dtween.parallel().tween_property(dust, "modulate:a", 0.0, 0.22)
	dtween.tween_callback(dust.queue_free)


func _spawn_afterimage() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.offset = sprite.offset
	ghost.flip_h = sprite.flip_h
	ghost.scale = sprite.scale
	ghost.rotation = sprite.rotation
	ghost.modulate = Color(0.4, 0.2, 0.7, 0.55) # Sombra púrpura de Asesino
	ghost.global_position = global_position
	get_parent().add_child(ghost)
	
	var gt := create_tween()
	gt.tween_property(ghost, "modulate:a", 0.0, 0.25)
	gt.tween_callback(ghost.queue_free)
