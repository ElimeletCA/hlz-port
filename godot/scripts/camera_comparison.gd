extends Node2D

# camera_comparison.gd — Escena de comparación de variantes de encuadre 2D (T4.5, T4.6, T4.7)
# Permite evaluar y comparar en tiempo real:
#   Variante A: Cenital directa (Top-down directo, zoom cerrado 3.0x, límites estrictos)
#   Variante B: Cenital con composición ligeramente elevada (Inspiración Bleaklight Falls, zoom 2.3x, offset frontal)

enum CameraVariant {
	VAR_A_DIRECT = 0,
	VAR_B_ELEVATED = 1
}

var current_variant: CameraVariant = CameraVariant.VAR_B_ELEVATED # B como recomendada
var player_speed: float = 42.0 # 3 px/tick * 14 ticks/s = 42 px/s (Fase 3 / movement.md)
var player_pos: Vector2 = Vector2(224, 320) # Centro de Aldea Silverleaf (448x640)

@onready var camera: Camera2D = $Camera2D
@onready var player: Node2D = $MapContainer/Player
@onready var map_sprite: Sprite2D = $MapContainer/MapSprite
@onready var hud_label: Label = $CanvasLayer/Panel/Margin/VBox/LabelInfo
@onready var hud_desc: Label = $CanvasLayer/Panel/Margin/VBox/LabelDesc

func _ready() -> void:
	print("[CameraComparison] Cargando mapa de referencia m_m_00 (Aldea Silverleaf)...")
	
	# Cargar render oficial del mapa m_m_00
	var out_dir = ProjectSettings.globalize_path("res://../out")
	var map_img_path = out_dir + "/renders/m_m_00.png"
	if FileAccess.file_exists(map_img_path):
		var img = Image.new()
		if img.load(map_img_path) == OK:
			map_sprite.texture = ImageTexture.create_from_image(img)
			print("[CameraComparison] Textura de mapa cargada: ", img.get_size())
	
	# Cargar sprite de referencia de Lucian
	var hero_path = out_dir + "/sprites/hero/0/00/frame_000.png"
	var hero_sprite = $MapContainer/Player/Sprite2D
	if FileAccess.file_exists(hero_path):
		var hero_img = Image.new()
		if hero_img.load(hero_path) == OK:
			hero_sprite.texture = ImageTexture.create_from_image(hero_img)
			
	# Centrar al jugador en la aldea
	player.position = player_pos
	
	# Aplicar variante inicial
	apply_variant(current_variant)


func _process(delta: float) -> void:
	# Manejar entrada de movimiento (WASD / Flechas / Stick Gamepad mediante InputManager)
	var input_vec = InputManager.get_movement_vector()
	if input_vec.length() > 0:
		player_pos += input_vec * player_speed * delta
		# Clampear a los límites transitables del mapa m_m_00 (448x640)
		player_pos.x = clampf(player_pos.x, 24.0, 424.0)
		player_pos.y = clampf(player_pos.y, 32.0, 608.0)
		player.position = player_pos
		
	# Teclas directas de cambio de variante
	if Input.is_key_pressed(KEY_1):
		apply_variant(CameraVariant.VAR_A_DIRECT)
	elif Input.is_key_pressed(KEY_2):
		apply_variant(CameraVariant.VAR_B_ELEVATED)
	elif Input.is_action_just_pressed("ui_accept"):
		# Alternar con barra espaciadora / Enter
		var next = CameraVariant.VAR_B_ELEVATED if current_variant == CameraVariant.VAR_A_DIRECT else CameraVariant.VAR_A_DIRECT
		apply_variant(next)
		
	# Actualizar info de HUD
	_update_hud()


## Aplica las configuraciones de la variante de cámara elegida
func apply_variant(variant: CameraVariant) -> void:
	current_variant = variant
	
	match variant:
		CameraVariant.VAR_A_DIRECT:
			# VARIANTE A: Cenital Directa
			camera.zoom = Vector2(3.0, 3.0)
			camera.offset = Vector2.ZERO
			camera.position_smoothing_speed = 8.0
			# Límites estrictos a los bordes de la textura de mapa (448x640)
			camera.limit_left = 0
			camera.limit_top = 0
			camera.limit_right = 448
			camera.limit_bottom = 640
			
		CameraVariant.VAR_B_ELEVATED:
			# VARIANTE B: Cenital Ligeramente Elevada (Inspiración Bleaklight Falls)
			camera.zoom = Vector2(2.35, 2.35)
			# Offset vertical hacia arriba para mostrar mayor anticipación frontal del camino
			camera.offset = Vector2(0, -32)
			camera.position_smoothing_speed = 5.0
			# Margen suave en límites para permitir ver el contexto del bioma
			camera.limit_left = -32
			camera.limit_top = -32
			camera.limit_right = 480
			camera.limit_bottom = 672
			
	print("[CameraComparison] Variante aplicada: ", "A (Directa)" if variant == CameraVariant.VAR_A_DIRECT else "B (Elevada)")


func _update_hud() -> void:
	var var_name = "Variante A: Cenital Directa" if current_variant == CameraVariant.VAR_A_DIRECT else "Variante B: Cenital Ligeramente Elevada (Recomendada · Estilo Bleaklight Falls)"
	hud_label.text = "%s\nZoom: %.2fx | Offset: (%d, %d) | FPS: %d | Pos: (%d, %d)" % [
		var_name,
		camera.zoom.x,
		camera.offset.x, camera.offset.y,
		Engine.get_frames_per_second(),
		int(player_pos.x), int(player_pos.y)
	]
	
	if current_variant == CameraVariant.VAR_A_DIRECT:
		hud_desc.text = "Cámara perpendicular estricta. Encuadre cerrado centrado en casillas. Límites rígidos al borde del mapa."
	else:
		hud_desc.text = "Perspectiva cenital con ligera elevación mediante arte y offset. Mayor campo de visión horizontal, lectura de profundidad y atmósfera."


func _on_btn_var_a_pressed() -> void:
	apply_variant(CameraVariant.VAR_A_DIRECT)


func _on_btn_var_b_pressed() -> void:
	apply_variant(CameraVariant.VAR_B_ELEVATED)
