class_name VerticalSlice
extends Node2D

# vertical_slice.gd — Escena integrada del Vertical Slice (Fase 5 · T5.1 – T5.14)
# Combina:
#   - Movimiento a 14 Hz con reloj dual y paridad de velocidad
#   - Colisiones sólidas de escenario y árboles con Y-Sort
#   - Combate en tiempo real con hitboxes, fórmulas de daño y crítico
#   - 6 SLOTS DE ACCIÓN (2 de Clase, 2 Elementales, 2 de Recuperación)
#   - IA de lobos con máquina de estados (Patrulla / Carga / Enfriamiento / Drop)
#   - Diálogo interactivo con el Maestro de Armas
#   - Cofre interactivo con inventario de pociones HP/MP
#   - Cámara oficial aprobada: Variante B (zoom 2.0x, offset -80px)
#   - Guardado y carga en slot 1 (F5 / F6)

const MAP_W_PX: int = 1792
const MAP_H_PX: int = 2560

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $World/Player
@onready var npc: StaticBody2D = $World/NPCTrainer
@onready var chest: StaticBody2D = $World/PropChest
@onready var hud: CanvasLayer = $HUD
@onready var map_sprite: Sprite2D = $MapSprite
@onready var notification_label: Label = $HUD/NotificationLabel


func _ready() -> void:
	print("==================================================")
	print("=== INICIANDO VERTICAL SLICE - 6 SLOTS ACTIVOS ===")
	print("==================================================")
	
	# Cargar mapa ilustrado de la aldea
	var village_map_res := "res://art_samples/map_silverleaf.png"
	if ResourceLoader.exists(village_map_res):
		var tex := load(village_map_res) as Texture2D
		if tex:
			map_sprite.texture = tex
	else:
		var out_dir := ProjectSettings.globalize_path("res://../out")
		var map_path := out_dir + "/renders/m_m_00.png"
		if FileAccess.file_exists(map_path):
			var img := Image.new()
			if img.load(map_path) == OK:
				map_sprite.texture = ImageTexture.create_from_image(img)
	
	# Configurar cámara con Variante B oficial aprobada en T4.7
	camera.zoom = Vector2(2.0, 2.0)
	camera.offset = Vector2(0, -80)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_W_PX
	camera.limit_bottom = MAP_H_PX
	
	# Posición inicial de Lucian
	player.global_position = Vector2(896, 1280)
	
	# Conectar señales del jugador al HUD
	player.connect("hp_changed", Callable(self, "_on_player_hp_changed"))
	player.connect("sp_changed", Callable(self, "_on_player_sp_changed"))
	player.connect("ep_changed", Callable(self, "_on_player_ep_changed"))
	player.connect("exp_gained", Callable(self, "_on_player_exp_gained"))
	player.connect("level_up", Callable(self, "_on_player_level_up"))
	player.connect("died", Callable(self, "_on_player_died"))
	player.connect("slot_cooldown_updated", Callable(self, "_on_slot_cooldown_updated"))
	player.connect("potions_updated", Callable(self, "_on_potions_updated"))
	
	# Conectar señales del NPC al HUD
	npc.connect("dialogue_started", Callable(self, "_on_npc_dialogue_started"))
	
	# Conectar cofre
	chest.connect("chest_opened", Callable(self, "_on_chest_opened"))
	
	# Inicializar HUD
	hud.update_hp(player.current_hp, player.max_hp)
	hud.update_sp(player.current_sp, player.max_sp)
	hud.update_ep(player.current_ep, player.max_ep)
	hud.update_exp(player.current_exp, player.next_level_exp)
	hud.update_level(player.level, player.character_name)
	hud.update_potions(player.inventory_potions_hp, player.inventory_potions_mp)
	notification_label.visible = false


func _process(_delta: float) -> void:
	if player != null and is_instance_valid(player):
		camera.global_position = player.global_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_save_vertical_slice()
		elif event.keycode == KEY_F6:
			_load_vertical_slice()


func _on_player_hp_changed(cur: int, max_val: int) -> void:
	hud.update_hp(cur, max_val)


func _on_player_sp_changed(cur: int, max_val: int) -> void:
	hud.update_sp(cur, max_val)


func _on_player_ep_changed(cur: int, max_val: int) -> void:
	hud.update_ep(cur, max_val)


func _on_player_exp_gained(_amount: int, cur: int, next_val: int) -> void:
	hud.update_exp(cur, next_val)


func _on_player_level_up(new_lvl: int) -> void:
	hud.update_level(new_lvl, player.character_name)
	_show_notification("¡NIVEL %d ALCANZADO!" % new_lvl, Color(1.0, 0.85, 0.1))


func _on_player_died() -> void:
	_show_notification("HAS SIDO DERROTADO — Presiona F6 para cargar partida", Color(1.0, 0.2, 0.2))


func _on_slot_cooldown_updated(slot_idx: int, cur_cd: float, max_cd: float) -> void:
	hud.update_slot_cooldown(slot_idx, cur_cd, max_cd)


func _on_potions_updated(hp_count: int, mp_count: int) -> void:
	hud.update_potions(hp_count, mp_count)


func _on_npc_dialogue_started(speaker: String, lines: Array) -> void:
	var string_lines: Array[String] = []
	for l in lines:
		string_lines.append(str(l))
	hud.start_dialogue(speaker, string_lines)


func _on_chest_opened(_item: String, _count: int) -> void:
	hud.update_potions(player.inventory_potions_hp, player.inventory_potions_mp)


func _save_vertical_slice() -> void:
	var save_data: Dictionary = {
		"level": player.level,
		"current_hp": player.current_hp,
		"max_hp": player.max_hp,
		"current_sp": player.current_sp,
		"max_sp": player.max_sp,
		"current_ep": player.current_ep,
		"max_ep": player.max_ep,
		"current_exp": player.current_exp,
		"next_level_exp": player.next_level_exp,
		"base_atk": player.base_atk,
		"base_def": player.base_def,
		"inventory_potions_hp": player.inventory_potions_hp,
		"inventory_potions_mp": player.inventory_potions_mp,
		"pos_x": player.global_position.x,
		"pos_y": player.global_position.y,
		"chest_opened": chest.is_opened
	}
	
	if SaveManager.save_game(1, save_data):
		_show_notification("Partida guardada en Slot 1", Color(0.2, 1.0, 0.4))


func _load_vertical_slice() -> void:
	var save_data: Dictionary = SaveManager.load_game(1)
	if save_data.is_empty():
		_show_notification("No hay partida guardada en Slot 1", Color(1.0, 0.4, 0.4))
		return
		
	player.level = int(save_data.get("level", 1))
	player.current_hp = int(save_data.get("current_hp", 120))
	player.max_hp = int(save_data.get("max_hp", 120))
	player.current_sp = int(save_data.get("current_sp", 30))
	player.max_sp = int(save_data.get("max_sp", 30))
	player.current_ep = int(save_data.get("current_ep", 50))
	player.max_ep = int(save_data.get("max_ep", 50))
	player.current_exp = int(save_data.get("current_exp", 0))
	player.next_level_exp = int(save_data.get("next_level_exp", 70))
	player.base_atk = int(save_data.get("base_atk", 18))
	player.base_def = int(save_data.get("base_def", 12))
	player.inventory_potions_hp = int(save_data.get("inventory_potions_hp", 3))
	player.inventory_potions_mp = int(save_data.get("inventory_potions_mp", 3))
	
	var px: float = float(save_data.get("pos_x", 896.0))
	var py: float = float(save_data.get("pos_y", 1280.0))
	player.global_position = Vector2(px, py)
	player.set("current_state", 0) # State.IDLE
	if "sprite" in player and player.sprite != null:
		player.sprite.modulate.a = 1.0
	
	chest.is_opened = bool(save_data.get("chest_opened", false))
	if chest.is_opened and "tex_open" in chest and chest.tex_open != null:
		chest.sprite.texture = chest.tex_open
		
	hud.update_hp(player.current_hp, player.max_hp)
	hud.update_sp(player.current_sp, player.max_sp)
	hud.update_ep(player.current_ep, player.max_ep)
	hud.update_exp(player.current_exp, player.next_level_exp)
	hud.update_level(player.level, player.character_name)
	hud.update_potions(player.inventory_potions_hp, player.inventory_potions_mp)
	
	_show_notification("Partida cargada de Slot 1", Color(0.3, 0.8, 1.0))


func _show_notification(text: String, col: Color) -> void:
	notification_label.text = text
	notification_label.modulate = col
	notification_label.visible = true
	
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(notification_label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func(): notification_label.visible = false)
