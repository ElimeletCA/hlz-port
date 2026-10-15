extends Node2D

# camera_comparison.gd — Escena de comparación de variantes de encuadre 2D (T4.5, T4.6, T4.7)
# Permite evaluar y comparar en tiempo real:
#   Variante A: Cenital directa — zoom muy cerrado (5.0x), campo visual pequeño, controlada pixel-art
#   Variante B: Cenital Bleaklight Falls — zoom amplio (2.0x), mayor contexto, posición ligeramente elevada
#
# Controles:
#   WASD / Flechas  — mover a Lucian
#   1               — Variante A (Cenital Cerrada)
#   2               — Variante B (Bleaklight Falls)
#   Espacio / Enter — alternar variante
#   Escape          — salir

enum CameraVariant {
	VAR_A_CERRADA   = 0,  # Muy cerrada, estilo clásico top-down (zoom 5x)
	VAR_B_BLEAKLIGHT = 1  # Amplia, estilo Bleaklight Falls (zoom 2x)
}

var current_variant: CameraVariant = CameraVariant.VAR_B_BLEAKLIGHT
var player_speed: float = 42.0   # 3 px/tick * 14 Hz (movement.md)
var player_pos: Vector2          # Inicializada en _ready

# Mapa m_m_00: 28 tiles × 40 tiles × 64 px/tile (render 4x) = 1792 × 2560 px
const MAP_W_PX  : int = 1792
const MAP_H_PX  : int = 2560
const TILE_PX   : int = 64       # Tamaño de tile en el render 4x
const PLAYER_TILE_W : int = 96   # Tamaño del sprite de Lucian
const PLAYER_TILE_H : int = 128

@onready var camera: Camera2D      = $Camera2D
@onready var player: Node2D        = $MapContainer/Player
@onready var map_sprite: Sprite2D  = $MapContainer/MapSprite
@onready var hud_label: Label      = $CanvasLayer/Panel/Margin/VBox/LabelInfo
@onready var hud_desc: Label       = $CanvasLayer/Panel/Margin/VBox/LabelDesc
@onready var vignette_a: ColorRect = $CanvasLayer/VignetteA   # Overlay azul para variante A
@onready var vignette_b: ColorRect = $CanvasLayer/VignetteB   # Overlay ámbar para variante B

func _ready() -> void:
	# Posición inicial: centro del mapa de Aldea Silverleaf
	player_pos = Vector2(MAP_W_PX * 0.5, MAP_H_PX * 0.5)

	print("[CameraComparison] Cargando mapa m_m_00 (Aldea Silverleaf)…")

	# Intentar cargar el render real del mapa (render 4x = 1792×2560)
	var out_dir   : String = ProjectSettings.globalize_path("res://../out")
	var map_path  : String = out_dir + "/renders/m_m_00.png"

	if FileAccess.file_exists(map_path):
		var img := Image.new()
		if img.load(map_path) == OK:
			map_sprite.texture = ImageTexture.create_from_image(img)
			print("[CameraComparison] Mapa cargado: ", img.get_size())
		else:
			_create_fallback_map()
	else:
		_create_fallback_map()

	# Sprite de Lucian: usar art sample ilustrado (96×128)
	var lucian_path : String = ProjectSettings.globalize_path("res://art_samples/hero_lucian_idle.png")
	var hero_sprite : Sprite2D = $MapContainer/Player/Sprite2D
	if FileAccess.file_exists(lucian_path):
		var hi := Image.new()
		if hi.load(lucian_path) == OK:
			hero_sprite.texture = ImageTexture.create_from_image(hi)
			print("[CameraComparison] Sprite Lucian cargado: ", hi.get_size())
	else:
		# Fallback: cuadrado rojo anotado
		var fb := Image.create(96, 128, false, Image.FORMAT_RGBA8)
		fb.fill(Color(0.85, 0.15, 0.15, 1.0))
		hero_sprite.texture = ImageTexture.create_from_image(fb)
		print("[WARN] Art sample de Lucian no encontrado — usando cuadrado rojo.")

	# Centrar sprite en el origen del nodo (pivot en los pies)
	hero_sprite.position = Vector2(0, -PLAYER_TILE_H * 0.5)

	# Posicionar al jugador en el centro del mapa
	player.position = player_pos

	# La posición de map_sprite: como Sprite2D, el origen es el centro
	# por lo que lo colocamos en el punto central del mapa
	map_sprite.position = Vector2(MAP_W_PX * 0.5, MAP_H_PX * 0.5)

	# Iniciar con variante B (recomendada)
	apply_variant(current_variant)


func _process(delta: float) -> void:
	# Movimiento del jugador
	var input_vec := InputManager.get_movement_vector()
	if input_vec.length() > 0.01:
		player_pos += input_vec * player_speed * delta
		# Límites dentro del mapa
		player_pos.x = clampf(player_pos.x, float(TILE_PX), float(MAP_W_PX - TILE_PX))
		player_pos.y = clampf(player_pos.y, float(TILE_PX), float(MAP_H_PX - TILE_PX))
		player.position = player_pos

	# Cámara sigue al jugador
	camera.global_position = player.global_position

	# Cambio de variante con teclas numéricas
	if Input.is_key_pressed(KEY_1):
		apply_variant(CameraVariant.VAR_A_CERRADA)
	elif Input.is_key_pressed(KEY_2):
		apply_variant(CameraVariant.VAR_B_BLEAKLIGHT)
	elif Input.is_action_just_pressed("ui_accept"):
		var next := CameraVariant.VAR_B_BLEAKLIGHT \
			if current_variant == CameraVariant.VAR_A_CERRADA \
			else CameraVariant.VAR_A_CERRADA
		apply_variant(next)

	_update_hud()


## Aplica la variante de cámara elegida con diferencias dramáticas y claras
func apply_variant(variant: CameraVariant) -> void:
	current_variant = variant

	# Ocultar ambos vigentes antes de mostrar el activo
	if is_instance_valid(vignette_a):
		vignette_a.visible = false
	if is_instance_valid(vignette_b):
		vignette_b.visible = false

	match variant:
		CameraVariant.VAR_A_CERRADA:
			# ── VARIANTE A ── Zoom muy cerrado: se ven ~5 tiles en horizontal
			# Equivalente pixel-art clásico J2ME (resolución original 240×320)
			camera.zoom                   = Vector2(5.0, 5.0)
			camera.offset                 = Vector2.ZERO
			camera.position_smoothing_enabled = true
			camera.position_smoothing_speed   = 12.0
			# Límites duros: no mostrar nada fuera del mapa
			camera.limit_left   = 0
			camera.limit_top    = 0
			camera.limit_right  = MAP_W_PX
			camera.limit_bottom = MAP_H_PX
			# Vignette azul fría para identificar variante A
			if is_instance_valid(vignette_a):
				vignette_a.visible = true

		CameraVariant.VAR_B_BLEAKLIGHT:
			# ── VARIANTE B ── Zoom amplio: se ven ~14 tiles en horizontal
			# Estilo Bleaklight Falls: campo amplio, lectura de territorio
			camera.zoom                   = Vector2(2.0, 2.0)
			# Offset vertical: muestra más terreno al frente del personaje
			camera.offset                 = Vector2(0, -80)
			camera.position_smoothing_enabled = true
			camera.position_smoothing_speed   = 5.0
			# Márgenes suaves: permite ver el borde del mapa con degradado
			camera.limit_left   = -64
			camera.limit_top    = -128
			camera.limit_right  = MAP_W_PX  + 64
			camera.limit_bottom = MAP_H_PX  + 64
			# Vignette ámbar cálida para identificar variante B
			if is_instance_valid(vignette_b):
				vignette_b.visible = true

	var label := "A (Cerrada Clásica)" if variant == CameraVariant.VAR_A_CERRADA else "B (Bleaklight Falls — Recomendada)"
	print("[CameraComparison] Variante aplicada: ", label)


func _update_hud() -> void:
	var var_name : String
	var tiles_visible_x : float
	if current_variant == CameraVariant.VAR_A_CERRADA:
		var_name       = "▶  Variante A  ◀  Cenital Cerrada (Clásica J2ME)"
		tiles_visible_x = 1920.0 / (64.0 * camera.zoom.x)
	else:
		var_name       = "▶  Variante B  ◀  Cenital Amplia (Estilo Bleaklight Falls)  ★ Recomendada"
		tiles_visible_x = 1920.0 / (64.0 * camera.zoom.x)

	hud_label.text = "%s\nZoom: %.1fx  |  Tiles visibles: ~%.0f×%.0f  |  FPS: %d  |  Pos: (%d, %d)" % [
		var_name,
		camera.zoom.x,
		tiles_visible_x,
		tiles_visible_x * (1080.0 / 1920.0),
		Engine.get_frames_per_second(),
		int(player_pos.x / TILE_PX), int(player_pos.y / TILE_PX)
	]

	if current_variant == CameraVariant.VAR_A_CERRADA:
		hud_desc.text = (
			"Zoom 5x — Campo visual: ~6 tiles ×  4 tiles.\n"
			+ "Equivalente resolución original J2ME (240×320 en hardware).\n"
			+ "Poco contexto del entorno — el jugador domina la pantalla."
		)
	else:
		hud_desc.text = (
			"Zoom 2x — Campo visual: ~15 tiles × 8 tiles.\n"
			+ "Inspiración Bleaklight Falls: mayor lectura del territorio,\n"
			+ "profundidad atmosférica y composición de escena completa."
		)


## Crea un mapa de fallback con tiles de colores si no existe el PNG
func _create_fallback_map() -> void:
	print("[WARN] Render m_m_00.png no encontrado — generando mapa de fallback.")
	var fb := Image.create(MAP_W_PX, MAP_H_PX, false, Image.FORMAT_RGBA8)
	# Fondo verde oscuro
	fb.fill(Color(0.12, 0.22, 0.10, 1.0))
	# Cuadrícula de tiles para que la diferencia de zoom sea visible
	for ty in range(0, MAP_H_PX, TILE_PX):
		for tx in range(0, MAP_W_PX, TILE_PX):
			# Alternar tonos verdes
			var col := Color(0.14, 0.26, 0.12) if ((tx / TILE_PX + ty / TILE_PX) % 2 == 0) else Color(0.10, 0.20, 0.09)
			for py in range(1, TILE_PX - 1):
				for px in range(1, TILE_PX - 1):
					fb.set_pixel(tx + px, ty + py, col)
	map_sprite.texture = ImageTexture.create_from_image(fb)
	map_sprite.position = Vector2(MAP_W_PX * 0.5, MAP_H_PX * 0.5)
	print("[CameraComparison] Mapa de fallback generado (", MAP_W_PX, "×", MAP_H_PX, ")")


func _on_btn_var_a_pressed() -> void:
	apply_variant(CameraVariant.VAR_A_CERRADA)


func _on_btn_var_b_pressed() -> void:
	apply_variant(CameraVariant.VAR_B_BLEAKLIGHT)
