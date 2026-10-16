extends Control

# main_menu.gd — Menú Principal de Heroes Lore: Zero para PC (T5.A)
# Proporciona el punto de entrada al juego con soporte para mando y teclado,
# inicio de nueva partida, continuación condicional de partida guardada,
# configuración de opciones (pantalla, vsync, perfil) y salida limpia.

@onready var title_texture: TextureRect = $CenterContainer/MainVBox/TitleContainer/TitleTexture
@onready var btn_new_game: Button = $CenterContainer/MainVBox/MenuButtons/BtnNewGame
@onready var btn_continue: Button = $CenterContainer/MainVBox/MenuButtons/BtnContinue
@onready var btn_options: Button = $CenterContainer/MainVBox/MenuButtons/BtnOptions
@onready var btn_quit: Button = $CenterContainer/MainVBox/MenuButtons/BtnQuit
@onready var menu_buttons_container: VBoxContainer = $CenterContainer/MainVBox/MenuButtons

# Panel de Opciones
@onready var options_panel: PanelContainer = $OptionsModal
@onready var opt_window_mode: OptionButton = $OptionsModal/Margin/OptionsVBox/Grid/WindowModeOption
@onready var opt_resolution: OptionButton = $OptionsModal/Margin/OptionsVBox/Grid/ResolutionOption
@onready var chk_vsync: CheckButton = $OptionsModal/Margin/OptionsVBox/Grid/VsyncCheck
@onready var opt_profile: OptionButton = $OptionsModal/Margin/OptionsVBox/Grid/ProfileOption
@onready var btn_options_back: Button = $OptionsModal/Margin/OptionsVBox/BtnOptionsBack

# Panel de Notificación / Stub de T5.B
@onready var stub_panel: PanelContainer = $StubModal
@onready var stub_label: Label = $StubModal/Margin/StubVBox/StubLabel
@onready var btn_stub_close: Button = $StubModal/Margin/StubVBox/BtnStubClose

# Versión y Copyright
@onready var lbl_version: Label = $Footer/Margin/FooterHBox/LblVersion
@onready var lbl_status: Label = $Footer/Margin/FooterHBox/LblStatus

var has_valid_save: bool = false
var selected_slot: int = 1

signal new_game_requested
signal continue_game_requested(slot: int)

func _ready() -> void:
	_check_save_state()
	_setup_options_ui()
	_connect_signals()
	_update_focus()
	
	lbl_version.text = "Heroes Lore: Zero — Remaster PC v0.1.0 (Godot 4.7.2)"
	print("[MainMenu] Menú principal inicializado correctamente.")


func _check_save_state() -> void:
	has_valid_save = SaveManager.has_any_save()
	if has_valid_save:
		selected_slot = SaveManager.get_latest_save_slot()
		btn_continue.disabled = false
		btn_continue.text = "CONTINUAR (Slot %d)" % selected_slot
		btn_continue.tooltip_text = "Cargar partida guardada más reciente"
	else:
		btn_continue.disabled = true
		btn_continue.text = "CONTINUAR (Sin partida)"
		btn_continue.tooltip_text = "No existe ninguna partida guardada en disco"


func _update_focus() -> void:
	# Dar foco al primer botón disponible
	if not btn_continue.disabled:
		btn_continue.grab_focus()
	else:
		btn_new_game.grab_focus()


func _connect_signals() -> void:
	btn_new_game.pressed.connect(_on_btn_new_game_pressed)
	btn_continue.pressed.connect(_on_btn_continue_pressed)
	btn_options.pressed.connect(_on_btn_options_pressed)
	btn_quit.pressed.connect(_on_btn_quit_pressed)
	
	btn_options_back.pressed.connect(_on_btn_options_back_pressed)
	btn_stub_close.pressed.connect(_on_btn_stub_close_pressed)
	
	opt_window_mode.item_selected.connect(_on_window_mode_selected)
	opt_resolution.item_selected.connect(_on_resolution_selected)
	chk_vsync.toggled.connect(_on_vsync_toggled)
	opt_profile.item_selected.connect(_on_profile_selected)


func _setup_options_ui() -> void:
	options_panel.visible = false
	stub_panel.visible = false
	
	# Modos de ventana
	opt_window_mode.clear()
	opt_window_mode.add_item("Ventana", DisplayManager.WindowMode.WINDOWED)
	opt_window_mode.add_item("Sin Bordes (Borderless)", DisplayManager.WindowMode.BORDERLESS)
	opt_window_mode.add_item("Pantalla Completa", DisplayManager.WindowMode.FULLSCREEN)
	opt_window_mode.select(int(DisplayManager.current_window_mode))
	
	# Resoluciones
	opt_resolution.clear()
	for i in range(DisplayManager.COMMON_RESOLUTIONS.size()):
		var res: Vector2i = DisplayManager.COMMON_RESOLUTIONS[i]
		opt_resolution.add_item("%d x %d" % [res.x, res.y], i)
		if res == DisplayManager.current_resolution:
			opt_resolution.select(i)
	
	# V-Sync
	chk_vsync.button_pressed = DisplayManager.vsync_enabled
	
	# Perfiles de rendimiento
	opt_profile.clear()
	opt_profile.add_item("Bajo (Intel UHD / Ahorro)", ProfileManager.QualityProfile.LOW)
	opt_profile.add_item("Medio (1080p Recomendado)", ProfileManager.QualityProfile.MEDIUM)
	opt_profile.add_item("Alto (RTX / 4K Enriquecido)", ProfileManager.QualityProfile.HIGH)
	opt_profile.select(int(ProfileManager.current_profile))


# --- Manejadores de Botones Principales ---

func _on_btn_new_game_pressed() -> void:
	print("[MainMenu] Selección: Nueva Partida iniciada (Punto de integración temporal T5.B).")
	emit_signal("new_game_requested")
	
	# Punto de integración temporal con T5.B (Selección de Personaje).
	# La transición narrativa y de escena NO se considera completa hasta que
	# exista y se pruebe 'CharacterSelect.tscn' en T5.B.
	var char_select_path := "res://scenes/CharacterSelect.tscn"
	if ResourceLoader.exists(char_select_path):
		get_tree().change_scene_to_file(char_select_path)
	else:
		_show_stub_modal(
			"PUNTO DE INTEGRACIÓN TEMPORAL: SELECCIÓN DE PERSONAJE (T5.B)\n\n" +
			"Punto de entrada de Nueva Partida verificado hacia T5.B.\n\n" +
			"AVISO: La transición narrativa al prólogo (T5.C) y al mapa (T5.D)\n" +
			"permanece pendiente y no se declara completa hasta la construcción\n" +
			"y prueba de 'CharacterSelect.tscn' en la siguiente tarea."
		)


func _on_btn_continue_pressed() -> void:
	if not has_valid_save:
		print("[MainMenu] No se puede continuar: no hay partida guardada.")
		return
		
	print("[MainMenu] Selección: Continuar partida desde slot %d." % selected_slot)
	emit_signal("continue_game_requested", selected_slot)
	
	var save_data = SaveManager.load_game(selected_slot)
	if save_data.is_empty():
		_show_stub_modal("Error al cargar la partida guardada del Slot %d." % selected_slot)
		return
		
	# Si existe una escena de mundo o vertical slice, cargarla
	var world_path := "res://scenes/World.tscn"
	var vs_path := "res://scenes/VerticalSlice.tscn"
	if ResourceLoader.exists(world_path):
		get_tree().change_scene_to_file(world_path)
	elif ResourceLoader.exists(vs_path):
		get_tree().change_scene_to_file(vs_path)
	else:
		_show_stub_modal(
			"PARTIDA CARGADA EXITOSAMENTE (Slot %d)\n\n" % selected_slot +
			"Datos recuperados: Nivel %s, HP %s/%s, Clase: %s.\n" % [
				save_data.get("level", 1),
				save_data.get("current_hp", 100),
				save_data.get("max_hp", 100),
				save_data.get("character_class", "Asesino")
			] +
			"La integración con el mapa de la aventura se completará en T5.D."
		)


func _on_btn_options_pressed() -> void:
	options_panel.visible = true
	menu_buttons_container.visible = false
	btn_options_back.grab_focus()
	print("[MainMenu] Panel de opciones abierto.")


func _on_btn_quit_pressed() -> void:
	print("[MainMenu] Saliendo del juego de forma limpia...")
	get_tree().quit()


# --- Manejadores de Opciones ---

func _on_btn_options_back_pressed() -> void:
	options_panel.visible = false
	menu_buttons_container.visible = true
	btn_options.grab_focus()
	print("[MainMenu] Opciones guardadas y aplicadas. Regreso al menú principal.")


func _on_window_mode_selected(index: int) -> void:
	var mode = opt_window_mode.get_item_id(index) as DisplayManager.WindowMode
	DisplayManager.set_window_mode(mode)
	print("[MainMenu] Modo de ventana cambiado a: ", mode)


func _on_resolution_selected(index: int) -> void:
	if index >= 0 and index < DisplayManager.COMMON_RESOLUTIONS.size():
		var res = DisplayManager.COMMON_RESOLUTIONS[index]
		DisplayManager.set_resolution(res)
		print("[MainMenu] Resolución cambiada a: ", res)


func _on_vsync_toggled(button_pressed: bool) -> void:
	DisplayManager.set_vsync(button_pressed)
	print("[MainMenu] V-Sync cambiado a: ", button_pressed)


func _on_profile_selected(index: int) -> void:
	var prof = opt_profile.get_item_id(index) as ProfileManager.QualityProfile
	ProfileManager.set_profile(prof)
	print("[MainMenu] Perfil de calidad cambiado a: ", ProfileManager.get_profile_name())


# --- Manejo del Modal de Información / Stub ---

func _show_stub_modal(message: String) -> void:
	stub_label.text = message
	stub_panel.visible = true
	menu_buttons_container.visible = false
	btn_stub_close.grab_focus()


func _on_btn_stub_close_pressed() -> void:
	stub_panel.visible = false
	menu_buttons_container.visible = true
	btn_new_game.grab_focus()


# --- Manejo de Entrada con Teclado y Gamepad ---

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") or event.is_action_pressed("ui_cancel"):
		if options_panel.visible:
			_on_btn_options_back_pressed()
			get_viewport().set_input_as_handled()
		elif stub_panel.visible:
			_on_btn_stub_close_pressed()
			get_viewport().set_input_as_handled()
