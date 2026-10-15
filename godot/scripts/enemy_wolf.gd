class_name EnemyWolf
extends CharacterBody2D

# enemy_wolf.gd — IA y Combate del Lobo del Bosque (T5.3)
# Basado en la especificación de ingeniería inversa de docs/spec/ai_enemies.md
# Máquina de estados: Patrulla -> Persecución (Aggro) -> Ataque -> Enfriamiento -> Daño/Muerte

signal died(exp_reward: int, position: Vector2)

enum AIState {
	IDLE_PATROL,
	AGGRO_CHASE,
	ATTACK_WINDUP,
	ATTACK_EXECUTE,
	COOLDOWN_WAIT,
	STAGGER_HURT,
	DEAD
}

@export var enemy_name: String = "Lobo del Bosque"
@export var max_hp: int = 45
@export var current_hp: int = 45
@export var base_atk: int = 14
@export var base_def: int = 4
@export var base_eva: int = 6
@export var exp_reward: int = 10

# Distancias en escala 4x (64px/tile):
# 6 tiles = 384 px; 12 tiles = 768 px; 1.2 tiles = ~76 px
const DETECT_RADIUS: float = 384.0
const LEASH_RADIUS: float = 768.0
const ATTACK_RADIUS: float = 76.0
const CHASE_SPEED: float = 120.0
const PATROL_SPEED: float = 50.0

var current_state: AIState = AIState.IDLE_PATROL
var home_position: Vector2 = Vector2.ZERO
var patrol_target: Vector2 = Vector2.ZERO
var patrol_timer: float = 0.0
var state_timer: float = 0.0

var target_player: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Polygon2D = $Shadow
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hp_bar: ProgressBar = $HPBar


func _ready() -> void:
	home_position = global_position
	patrol_target = home_position
	
	# Cargar textura de lobo
	var wolf_path := "res://art_samples/enemy_forest_wolf.png"
	if ResourceLoader.exists(wolf_path):
		var tex := load(wolf_path) as Texture2D
		if tex:
			sprite.texture = tex
			
	# Configurar barra de vida
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_bar.visible = false
	
	# Conectar al reloj de 14 Hz para lógica fija
	GameClock.game_tick.connect(_on_game_tick)


func _physics_process(delta: float) -> void:
	if current_state == AIState.DEAD:
		return
		
	# Actualizar temporizador de estado continuo
	if state_timer > 0.0:
		state_timer -= delta

	# Movimiento según estado
	match current_state:
		AIState.IDLE_PATROL:
			_process_patrol(delta)
		AIState.AGGRO_CHASE:
			_process_chase(delta)
		AIState.ATTACK_WINDUP:
			velocity = Vector2.ZERO
			if state_timer <= 0.0:
				_execute_attack()
		AIState.COOLDOWN_WAIT:
			velocity = Vector2.ZERO
			if state_timer <= 0.0:
				current_state = AIState.AGGRO_CHASE
		AIState.STAGGER_HURT:
			move_and_slide() # Aplica el knockback
			if state_timer <= 0.0:
				current_state = AIState.AGGRO_CHASE


## Lógica de IA a 14 Hz (GameClock)
func _on_game_tick(_tick_count: int) -> void:
	if current_state == AIState.DEAD:
		return
		
	# Buscar al jugador si no se tiene referencia
	if target_player == null or not is_instance_valid(target_player):
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]
			
	if target_player == null:
		return
		
	var dist_to_player := global_position.distance_to(target_player.global_position)
	
	match current_state:
		AIState.IDLE_PATROL:
			# Si el jugador entra en radio de detección -> Persecución
			if dist_to_player <= DETECT_RADIUS:
				current_state = AIState.AGGRO_CHASE
				hp_bar.visible = true
				
		AIState.AGGRO_CHASE:
			# Si el jugador se aleja más allá de Leash -> volver a casa
			if dist_to_player > LEASH_RADIUS:
				current_state = AIState.IDLE_PATROL
				patrol_target = home_position
				hp_bar.visible = false
			elif dist_to_player <= ATTACK_RADIUS:
				# En rango de ataque -> Carga de ataque
				current_state = AIState.ATTACK_WINDUP
				state_timer = 0.35 # 350 ms de anticipación
				_windup_animation()


func _process_patrol(delta: float) -> void:
	patrol_timer -= delta
	if patrol_timer <= 0.0:
		patrol_timer = randf_range(2.0, 4.5)
		# Elegir punto aleatorio cerca de home
		var offset := Vector2(randf_range(-120, 120), randf_range(-120, 120))
		patrol_target = home_position + offset
		
	var diff := patrol_target - global_position
	if diff.length() > 16.0:
		velocity = diff.normalized() * PATROL_SPEED
		sprite.flip_h = (velocity.x < 0)
		move_and_slide()
	else:
		velocity = Vector2.ZERO


func _process_chase(_delta: float) -> void:
	if target_player == null:
		return
		
	var diff := target_player.global_position - global_position
	velocity = diff.normalized() * CHASE_SPEED
	sprite.flip_h = (velocity.x < 0)
	move_and_slide()


func _windup_animation() -> void:
	# Parpadeo / aviso de ataque
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.2, 0.4, 0.4), 0.15)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func _execute_attack() -> void:
	current_state = AIState.ATTACK_EXECUTE
	
	# Embestida rápida hacia el jugador
	if target_player != null and is_instance_valid(target_player):
		var dist := global_position.distance_to(target_player.global_position)
		if dist <= ATTACK_RADIUS * 1.3:
			# Infligir daño al jugador
			target_player.take_damage(base_atk, global_position)
			
	# Pasar a tiempo de enfriamiento (1.5 segundos)
	current_state = AIState.COOLDOWN_WAIT
	state_timer = 1.5


## Llamado cuando Lucian golpea al lobo
func take_damage(amount: int, is_crit: bool, from_pos: Vector2) -> void:
	if current_state == AIState.DEAD:
		return
		
	current_hp = maxi(0, current_hp - amount)
	hp_bar.value = current_hp
	hp_bar.visible = true
	
	# Mostrar número de daño flotante
	var text := "¡CRÍTICO! -%d" % amount if is_crit else "-%d" % amount
	var col := Color(1.0, 0.85, 0.1) if is_crit else Color(1.0, 0.3, 0.3)
	spawn_floating_text(text, col)
	
	if current_hp <= 0:
		_die()
		return
		
	# Retroceso (Knockback) y aturdimiento
	current_state = AIState.STAGGER_HURT
	state_timer = 0.25
	var knockback_dir := (global_position - from_pos).normalized()
	velocity = knockback_dir * 180.0
	
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.2, 0.2), 0.08)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)


func _die() -> void:
	current_state = AIState.DEAD
	velocity = Vector2.ZERO
	hp_bar.visible = false
	
	spawn_floating_text("+%d EXP" % exp_reward, Color(0.3, 0.8, 1.0))
	emit_signal("died", exp_reward, global_position)
	
	# Notificar al jugador para que gane la EXP
	if target_player != null and target_player.has_method("gain_exp"):
		target_player.gain_exp(exp_reward)
		
	# Probabilidad de dropear una poción (40%)
	if randf() < 0.40 and target_player != null and "inventory_potions" in target_player:
		target_player.inventory_potions += 1
		spawn_floating_text("+1 Poción", Color(0.2, 1.0, 0.4))
		
	# Animación de muerte
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.8)
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)


func spawn_floating_text(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.modulate = color
	label.z_index = 100
	label.position = Vector2(-30, -70)
	add_child(label)
	
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 35, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)
