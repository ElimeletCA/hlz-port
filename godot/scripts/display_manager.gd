extends Node

# DisplayManager.gd — Gestor de pantalla, ventana y escalado de UI (T4.1, T4.2)
# Proporciona control de presentación horizontal en 1920x1080 con soporte para
# pantalla completa, borderless, vsync, límite de FPS y escalado de UI independiente.

enum WindowMode {
	WINDOWED = 0,
	BORDERLESS = 1,
	FULLSCREEN = 2
}

const COMMON_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

# Configuración actual
var current_window_mode: WindowMode = WindowMode.WINDOWED
var current_resolution: Vector2i = Vector2i(1280, 720)
var vsync_enabled: bool = true
var target_fps: int = 60
var ui_scale: float = 1.0

# Señal emitida cuando cambia la resolución o escala
signal display_settings_changed

func _ready() -> void:
	# Configurar parámetros iniciales de Windows
	Engine.max_fps = target_fps
	set_vsync(vsync_enabled)
	print("[DisplayManager] Inicializado: 1920x1080 base, ventana inicial ", current_resolution, " @ ", target_fps, " FPS")


## Configura el modo de ventana (Ventana, Borderless, Pantalla Completa)
func set_window_mode(mode: WindowMode) -> void:
	current_window_mode = mode
	match mode:
		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(current_resolution)
			_center_window()
		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_size(screen_size)
			DisplayServer.window_set_position(Vector2i.ZERO)
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	emit_signal("display_settings_changed")


## Cambia la resolución de la ventana si está en modo ventana
func set_resolution(res: Vector2i) -> void:
	current_resolution = res
	if current_window_mode == WindowMode.WINDOWED:
		DisplayServer.window_set_size(res)
		_center_window()
	emit_signal("display_settings_changed")


## Configura la sincronización vertical (V-Sync)
func set_vsync(enabled: bool) -> void:
	vsync_enabled = enabled
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	emit_signal("display_settings_changed")


## Configura el límite de cuadros por segundo (0 = ilimitado)
func set_fps_limit(fps: int) -> void:
	target_fps = fps
	Engine.max_fps = fps
	emit_signal("display_settings_changed")


## Configura el factor de escalado de la interfaz de usuario (separado del contenido)
func set_ui_scale(scale: float) -> void:
	ui_scale = clampf(scale, 0.75, 2.5)
	emit_signal("display_settings_changed")


## Centra la ventana en la pantalla principal
func _center_window() -> void:
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var pos = (screen_size - window_size) / 2
	DisplayServer.window_set_position(pos)


## Devuelve un diccionario con los datos técnicos de la pantalla y configuración
func get_display_info() -> Dictionary:
	return {
		"adapter": RenderingServer.get_video_adapter_name(),
		"adapter_type": RenderingServer.get_video_adapter_type(),
		"screen_size": DisplayServer.screen_get_size(),
		"refresh_rate": DisplayServer.screen_get_refresh_rate(),
		"window_size": DisplayServer.window_get_size(),
		"mode": current_window_mode,
		"vsync": vsync_enabled,
		"fps_limit": target_fps,
		"ui_scale": ui_scale
	}
