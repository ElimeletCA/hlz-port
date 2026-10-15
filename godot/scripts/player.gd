class_name Player
extends CharacterBody2D

# player.gd — Controlador del Héroe (Lucian) para Heroes Lore: Zero Port (T5.1, T5.3, T5.5)
# Basado en la especificación de ingeniería inversa:
#   - Reloj dual: simulación de lógica a 14 Hz (GameClock.game_tick) e interpolación visual a 60 FPS
#   - Velocidad: 3 px/tick * 14 Hz = 42 px/s (docs/spec/movement.md)
#   - Atributos base de Guerrero Nivel 1: HP 120, MP 30, ATK 18, DEF 12 (docs/spec/progression.md)
#   - Fórmulas de combate exactas (docs/spec/combat.md)

signal hp_changed(current: int, max_hp: int)
signal mp_changed(current: int, max_mp: int)
signal exp_gained(amount: int, current_exp: int, next_exp: int)
signal level_up(new_level: int)
signal died()
signal interacted_with(target: Node)

enum State {
	IDLE,
	MOVE,
	ATTACK,
	HURT,
	DEAD
}

enum Direction {
	DOWN = 0,
	UP = 1,
	LEFT = 2,
	RIGHT = 3
}

# --- Atributos de Personaje (Clase Guerrero · Lucian) ---
@export var character_name: String = "Lucian"
@export var level: int = 1
@export var max_hp: int = 120
@export var current_hp: int = 120
@export var max_mp: int = 30
@export var current_mp: int = 30
@export var base_atk: int = 18
@export var base_def: int = 12
@export var current_exp: int = 0
@export var next_level_exp: int = 70

# --- Movimiento y Física (14 Hz / 42 px/s) ---
# En escala 4x (64px/tile), la velocidad se escala correspondientemente:
# 42 px/s originales (a 16px/tile) * 4 = 168 px/s en el mundo 4x
const BASE_SPEED_4X: float = 168.0

var current_state: State = State.IDLE
var current_dir: Direction = Direction.DOWN
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0

# Posiciones para interpolación de reloj dual
var prev_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var move_dir: Vector2 = Vector2.ZERO

# Referencias a nodos hijos
@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Polygon2D = $Shadow
@onready var slash_vfx: Sprite2D = $SlashVFX
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: CollisionShape2D = $CollisionShape2D

# Inventario simple (Pociones)
var inventory_potions: int = 3


func _ready() -> void:
	# Cargar textura ilustrada de Lucian si existe
	var lucian_path := "res://art_samples/hero_lucian_idle.png"
	if ResourceLoader.exists(lucian_path):
		var tex := load(lucian_path) as Texture2D
		if tex:
			sprite.texture = tex
	
	# Configurar slash VFX
	var slash_path := "res://art_samples/vfx_sword_slash.png"
	if ResourceLoader.exists(slash_path):
		var slash_tex := load(slash_path) as Texture2D
		if slash_tex:
			slash_vfx.texture = slash_tex
	slash_vfx.visible = false
	
	# Inicializar posiciones de interpolación
	prev_pos = global_position
	target_pos = global_position
	
	# Conectar al reloj de 14 Hz para lógica fija
	GameClock.game_tick.connect(_on_game_tick)
	
	emit_signal("hp_changed", current_hp, max_hp)
	emit_signal("mp_changed", current_mp, max_mp)


func _process(delta: float) -> void:
	# Manejar temporizadores de estado (en tiempo real continuo)
	if is_invulnerable:
		invulnerable_timer -= delta
		# Parpadeo de invulnerabilidad
		sprite.modulate.a = 0.4 if fmod(invulnerable_timer * 10.0, 1.0) > 0.5 else 1.0
		if invulnerable_timer <= 0.0:
			is_invulnerable = false
			sprite.modulate.a = 1.0

	# Interpolación visual suave (Dual-clock alpha)
	if current_state == State.MOVE:
		var alpha: float = GameClock.get_interp_alpha()
		# Si usamos move_and_slide(), la física mueve el CharacterBody2D directamente.
		# La interpolación visual asegura sincronía de cuadro.


func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
		
	# Leer vector de entrada desde InputManager
	move_dir = InputManager.get_movement_vector()
	
	if current_state != State.ATTACK and current_state != State.HURT:
		if move_dir.length() > 0.05:
			current_state = State.MOVE
			# Determinar dirección cardinal predominante para sprites y hitboxes
			_update_facing_direction(move_dir)
			
			# Desplazamiento mediante motor de física de Godot (colisiones automáticas)
			velocity = move_dir.normalized() * BASE_SPEED_4X
			move_and_slide()
		else:
			current_state = State.IDLE
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		
	# Acciones de entrada
	if Input.is_action_just_pressed("attack") and current_state != State.ATTACK and current_state != State.DEAD:
		perform_attack()
	elif Input.is_action_just_pressed("quick_item") and current_state != State.DEAD:
		use_potion()
	elif Input.is_action_just_pressed("interact") and current_state != State.DEAD:
		_try_interact()


## Se ejecuta exactamente a TICK_HZ (14 Hz) mediante señal de GameClock
func _on_game_tick(tick_count: int) -> void:
	if current_state == State.DEAD:
		return
	
	# Regeneración natural leve de MP fuera de combate cada 28 ticks (~2 segundos)
	if tick_count % 28 == 0 and current_mp < max_mp:
		current_mp = mini(max_mp, current_mp + 1)
		emit_signal("mp_changed", current_mp, max_mp)


func _update_facing_direction(input: Vector2) -> void:
	if absf(input.x) > absf(input.y):
		current_dir = Direction.RIGHT if input.x > 0 else Direction.LEFT
		sprite.flip_h = (current_dir == Direction.LEFT)
	else:
		current_dir = Direction.DOWN if input.y > 0 else Direction.UP
		sprite.flip_h = false


## Ejecuta el ataque cuerpo a cuerpo básico de espada
func perform_attack() -> void:
	current_state = State.ATTACK
	
	# Posicionar y orientar la hitbox y el efecto VFX de corte según la dirección
	var attack_offset := Vector2.ZERO
	var slash_rot: float = 0.0
	
	match current_dir:
		Direction.DOWN:
			attack_offset = Vector2(0, 48)
			slash_rot = PI * 0.5
		Direction.UP:
			attack_offset = Vector2(0, -48)
			slash_rot = -PI * 0.5
		Direction.LEFT:
			attack_offset = Vector2(-48, 0)
			slash_rot = PI
		Direction.RIGHT:
			attack_offset = Vector2(48, 0)
			slash_rot = 0.0
			
	attack_area.position = attack_offset
	slash_vfx.position = attack_offset
	slash_vfx.rotation = slash_rot
	slash_vfx.visible = true
	slash_vfx.modulate.a = 1.0
	
	# Pequeña animación de tajo del sprite del héroe
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.15, 0.9), 0.08)
	tween.parallel().tween_property(slash_vfx, "modulate:a", 0.0, 0.22)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.12)
	tween.tween_callback(func():
		slash_vfx.visible = false
		if current_state == State.ATTACK:
			current_state = State.IDLE
	)
	
	# Detectar impactos en enemigos dentro del área de ataque
	var overlapping_bodies := attack_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body != self and body.has_method("take_damage"):
			_deal_damage_to(body)


## Calcula el daño físico infligido según docs/spec/combat.md
func _deal_damage_to(target: Node) -> void:
	var target_def: int = target.get("base_def") if "base_def" in target else 5
	
	# 1. Comprobación de Evasión (Miss)
	var target_eva: int = target.get("base_eva") if "base_eva" in target else 6
	var eva_roll: int = randi_range(1, 99)
	if eva_roll > (100 - target_eva):
		if target.has_method("spawn_floating_text"):
			target.spawn_floating_text("FALLO", Color(0.8, 0.8, 0.8))
		return
		
	# 2. Varianza de daño: random(-floor(ATK/20), floor(ATK/20))
	var var_range: int = maxi(1, int(base_atk / 20.0))
	var variance: int = randi_range(-var_range, var_range)
	
	# Daño base = max(1, ATK - DEF + varianza)
	var damage: int = maxi(1, base_atk - target_def + variance)
	
	# 3. Comprobación de Golpe Crítico (dg.java línea 2165)
	var crit_prob: int = maxi(10, 60 - target_def)
	var is_crit: bool = (randi_range(0, 99) < crit_prob)
	if is_crit:
		damage = int(damage * 1.5)
		
	target.take_damage(damage, is_crit, global_position)


## Recibe daño de un enemigo o proyectil
func take_damage(amount: int, from_pos: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or current_state == State.DEAD:
		return
		
	# Reducción por armadura
	var net_damage: int = maxi(1, amount - int(base_def * 0.3))
	current_hp = maxi(0, current_hp - net_damage)
	emit_signal("hp_changed", current_hp, max_hp)
	
	# Texto flotante de daño
	_spawn_floating_text("-%d" % net_damage, Color(1.0, 0.25, 0.25))
	
	if current_hp <= 0:
		_die()
		return
		
	# Estado de daño y retroceso (Knockback)
	current_state = State.HURT
	is_invulnerable = true
	invulnerable_timer = 0.5 # 0.5s de invulnerabilidad post-golpe
	
	if from_pos != Vector2.ZERO:
		var knockback_dir := (global_position - from_pos).normalized()
		velocity = knockback_dir * 120.0
		move_and_slide()
		
	# Animación de retroceso/rojo
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.3, 0.3), 0.08)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)
	tween.tween_callback(func():
		if current_state == State.HURT:
			current_state = State.IDLE
	)


func use_potion() -> void:
	if inventory_potions <= 0:
		_spawn_floating_text("¡Sin pociones!", Color(0.9, 0.7, 0.2))
		return
	if current_hp >= max_hp:
		_spawn_floating_text("¡HP lleno!", Color(0.7, 0.9, 0.7))
		return
		
	inventory_potions -= 1
	var heal_amount: int = 50
	current_hp = mini(max_hp, current_hp + heal_amount)
	emit_signal("hp_changed", current_hp, max_hp)
	_spawn_floating_text("+%d HP" % heal_amount, Color(0.2, 1.0, 0.3))


func gain_exp(amount: int) -> void:
	current_exp += amount
	_spawn_floating_text("+%d EXP" % amount, Color(0.3, 0.7, 1.0))
	emit_signal("exp_gained", amount, current_exp, next_level_exp)
	
	if current_exp >= next_level_exp:
		_level_up()


func _level_up() -> void:
	level += 1
	current_exp -= next_level_exp
	# Curva de progresión (docs/spec/progression.md)
	# EXP_Requerida(L) = floor(50 * (L-1)^2.2 + 20 * (L-1))
	next_level_exp = int(50.0 * pow(level, 2.2) + 20.0 * level)
	
	# Crecimiento de Guerrero: HP +28, MP +6, ATK +5, DEF +3
	max_hp += 28
	current_hp = max_hp
	max_mp += 6
	current_mp = max_mp
	base_atk += 5
	base_def += 3
	
	emit_signal("level_up", level)
	emit_signal("hp_changed", current_hp, max_hp)
	emit_signal("mp_changed", current_mp, max_mp)
	_spawn_floating_text("¡SUBE DE NIVEL! (Nv. %d)" % level, Color(1.0, 0.85, 0.1))


func _die() -> void:
	current_state = State.DEAD
	velocity = Vector2.ZERO
	emit_signal("died")
	_spawn_floating_text("HAS MUERTO", Color(0.9, 0.1, 0.1))
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.2)


func _try_interact() -> void:
	# Buscar cofres o NPCs cercanos en un radio de 64 px
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 64.0
	query.shape = circle
	query.transform = global_transform
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results := space_state.intersect_shape(query)
	for res in results:
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
