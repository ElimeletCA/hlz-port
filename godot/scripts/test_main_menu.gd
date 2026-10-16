extends Node

# test_main_menu.gd — Batería de pruebas automatizadas y de seguridad para T5.A
#
# Cobertura:
#   1. Aislamiento estricto de guardado: las pruebas se ejecutan en user://test_saves/
#      y se verifica mediante un archivo canario que user://saves/ jamás es modificado.
#   2. Validación semántica exhaustiva de SaveManager (5 estados de SaveStatus).
#   3. Comprobación de selección por metadatos (timestamps y fallback ante corrupción).
#   4. Comprobación de DisplayManager y ProfileManager mediante selección de opciones.
#   5. Mapeos en InputMap para teclado y mando.
#   6. Pruebas de entrada simulada diferenciadas:
#      - Eventos crudos de teclado (InputEventKey)
#      - Eventos crudos de mando (InputEventJoypadButton)
#      - Acciones simuladas de motor (InputEventAction)
#   7. Declaración explícita del stub de T5.B sin asumir transición narrativa completa.

var test_results: Array[Dictionary] = []
var pass_count: int = 0
var fail_count: int = 0

const CANARY_PATH: String = "user://saves/production_guard_canary.json"
var canary_initial_text: String = ""

@onready var main_menu = $MainMenu

func _ready() -> void:
	print("\n======================================================================")
	print("[TestMainMenu] INICIANDO PRUEBAS DE SEGURIDAD Y VALIDEZ DE T5.A")
	print("======================================================================")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	await _run_all_tests()


func _record_assertion(test_name: String, property: String, expected, actual, condition: bool) -> void:
	var res := "PASS" if condition else "FAIL"
	if condition:
		pass_count += 1
	else:
		fail_count += 1
		printerr("  [FALLO] %s :: %s -> Esperado: %s | Obtenido: %s" % [test_name, property, expected, actual])
	
	test_results.append({
		"test": test_name,
		"property": property,
		"expected": str(expected),
		"actual": str(actual),
		"result": res
	})
	print("  [%s] %s -> %s (Esperado: %s | Obtenido: %s)" % [res, test_name, property, expected, actual])


func _setup_production_canary() -> void:
	# Asegurar existencia de directorio de producción
	if not DirAccess.dir_exists_absolute(SaveManager.DEFAULT_SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SaveManager.DEFAULT_SAVE_DIR)
		
	var canary_data = {
		"canary_token": "HLZ_PROD_GUARD_2026",
		"created_at": Time.get_datetime_string_from_system(),
		"important_note": "ESTE ARCHIVO REPRESENTA PARTIDAS REALES Y NO DEBE SER TOCADO"
	}
	canary_initial_text = JSON.stringify(canary_data, "\t")
	var f := FileAccess.open(CANARY_PATH, FileAccess.WRITE)
	if f:
		f.store_string(canary_initial_text)
		f.close()


func _verify_canary_intact() -> bool:
	if not FileAccess.file_exists(CANARY_PATH):
		return false
	var f := FileAccess.open(CANARY_PATH, FileAccess.READ)
	if not f:
		return false
	var current_text := f.get_as_text()
	f.close()
	return current_text == canary_initial_text


func _simulate_key_press_and_release(keycode: Key) -> void:
	var ev_press := InputEventKey.new()
	ev_press.keycode = keycode
	ev_press.physical_keycode = keycode
	ev_press.pressed = true
	Input.parse_input_event(ev_press)
	get_viewport().push_input(ev_press, true)
	await get_tree().process_frame
	
	var ev_release := InputEventKey.new()
	ev_release.keycode = keycode
	ev_release.physical_keycode = keycode
	ev_release.pressed = false
	Input.parse_input_event(ev_release)
	get_viewport().push_input(ev_release, true)
	await get_tree().process_frame


func _simulate_joy_button_press_and_release(btn: JoyButton) -> void:
	var ev_press := InputEventJoypadButton.new()
	ev_press.button_index = btn
	ev_press.pressed = true
	Input.parse_input_event(ev_press)
	get_viewport().push_input(ev_press, true)
	await get_tree().process_frame
	
	var ev_release := InputEventJoypadButton.new()
	ev_release.button_index = btn
	ev_release.pressed = false
	Input.parse_input_event(ev_release)
	get_viewport().push_input(ev_release, true)
	await get_tree().process_frame


func _simulate_action_press_and_release(action_name: String) -> void:
	var ev_press := InputEventAction.new()
	ev_press.action = action_name
	ev_press.pressed = true
	Input.parse_input_event(ev_press)
	get_viewport().push_input(ev_press, true)
	await get_tree().process_frame
	
	var ev_release := InputEventAction.new()
	ev_release.action = action_name
	ev_release.pressed = false
	Input.parse_input_event(ev_release)
	get_viewport().push_input(ev_release, true)
	await get_tree().process_frame


func _run_all_tests() -> void:
	# =========================================================================
	# BLOQUE 0: Protección de Datos Reales y Activación de Entorno Aislado
	# =========================================================================
	_setup_production_canary()
	_record_assertion("SaveIsolation_Setup", "production_canary_created", true, FileAccess.file_exists(CANARY_PATH), FileAccess.file_exists(CANARY_PATH))
	
	# Activar aislamiento hacia user://test_saves/
	SaveManager.set_save_dir(SaveManager.TEST_SAVE_DIR)
	SaveManager.clean_test_saves_dir()
	_record_assertion("SaveIsolation_Setup", "save_dir_switched_to_test", SaveManager.TEST_SAVE_DIR, SaveManager.get_save_dir(), SaveManager.get_save_dir() == SaveManager.TEST_SAVE_DIR)
	_record_assertion("SaveIsolation_Setup", "canary_intact_after_switch", true, _verify_canary_intact(), _verify_canary_intact())
	
	# =========================================================================
	# BLOQUE 1: Existencia y jerarquía de nodos de MainMenu
	# =========================================================================
	_record_assertion("NodesExistence", "main_menu_valid", true, is_instance_valid(main_menu), is_instance_valid(main_menu))
	_record_assertion("NodesExistence", "btn_new_game_valid", true, is_instance_valid(main_menu.btn_new_game), is_instance_valid(main_menu.btn_new_game))
	_record_assertion("NodesExistence", "btn_continue_valid", true, is_instance_valid(main_menu.btn_continue), is_instance_valid(main_menu.btn_continue))
	_record_assertion("NodesExistence", "btn_options_valid", true, is_instance_valid(main_menu.btn_options), is_instance_valid(main_menu.btn_options))
	_record_assertion("NodesExistence", "btn_quit_valid", true, is_instance_valid(main_menu.btn_quit), is_instance_valid(main_menu.btn_quit))
	
	# =========================================================================
	# BLOQUE 2: Validación Semántica Exhaustiva de SaveManager (5 Estados)
	# =========================================================================
	# 2.1 Archivo Ausente
	_record_assertion("SaveSchema_Missing", "status_file_missing", SaveManager.SaveStatus.FILE_MISSING, SaveManager.evaluate_save_status(1), SaveManager.evaluate_save_status(1) == SaveManager.SaveStatus.FILE_MISSING)
	_record_assertion("SaveSchema_Missing", "is_save_valid_false", false, SaveManager.is_save_valid(1), not SaveManager.is_save_valid(1))
	_record_assertion("SaveSchema_Missing", "load_game_empty", {}, SaveManager.load_game(1), SaveManager.load_game(1).is_empty())
	
	# 2.2 Archivo Vacío (0 bytes)
	var p1 := SaveManager.get_save_path(1)
	var f_empty := FileAccess.open(p1, FileAccess.WRITE)
	if f_empty:
		f_empty.store_string("")
		f_empty.close()
	_record_assertion("SaveSchema_Empty", "status_file_empty", SaveManager.SaveStatus.FILE_EMPTY, SaveManager.evaluate_save_status(1), SaveManager.evaluate_save_status(1) == SaveManager.SaveStatus.FILE_EMPTY)
	_record_assertion("SaveSchema_Empty", "is_save_valid_false", false, SaveManager.is_save_valid(1), not SaveManager.is_save_valid(1))
	
	# 2.3 JSON Sintácticamente Inválido
	var f_corrupt := FileAccess.open(p1, FileAccess.WRITE)
	if f_corrupt:
		f_corrupt.store_string("{\n\t\"level\": 99,\n\t\"broken_syntax\": [INCOMPLETE_ARRAY\n")
		f_corrupt.close()
	_record_assertion("SaveSchema_SyntaxError", "status_json_syntax_error", SaveManager.SaveStatus.JSON_SYNTAX_ERROR, SaveManager.evaluate_save_status(1), SaveManager.evaluate_save_status(1) == SaveManager.SaveStatus.JSON_SYNTAX_ERROR)
	_record_assertion("SaveSchema_SyntaxError", "is_save_valid_false", false, SaveManager.is_save_valid(1), not SaveManager.is_save_valid(1))
	
	# 2.4 JSON Válido pero Semánticamente Incorrecto
	# Caso A: Metadatos incompletos (falta version o timestamp)
	var dict_missing_meta = {"save_slot": 1, "character_class": "Asesino", "level": 10, "current_hp": 100}
	_record_assertion("SaveSchema_Semantic", "missing_metadata_rejected", false, SaveManager.validate_save_dict(dict_missing_meta), not SaveManager.validate_save_dict(dict_missing_meta))
	
	# Caso B: Tipo incorrecto (level como String en vez de int)
	var dict_wrong_type = {"save_slot": 1, "version": "1.0.0-fase5", "timestamp": "2026-10-16T12:00:00", "character_class": "Asesino", "level": "diez", "current_hp": 100}
	_record_assertion("SaveSchema_Semantic", "wrong_type_level_rejected", false, SaveManager.validate_save_dict(dict_wrong_type), not SaveManager.validate_save_dict(dict_wrong_type))
	
	# Caso C: Rango incorrecto (level 0 o level > 99)
	var dict_out_of_range = {"save_slot": 1, "version": "1.0.0-fase5", "timestamp": "2026-10-16T12:00:00", "character_class": "Asesino", "level": 0, "current_hp": 100}
	_record_assertion("SaveSchema_Semantic", "out_of_range_level_rejected", false, SaveManager.validate_save_dict(dict_out_of_range), not SaveManager.validate_save_dict(dict_out_of_range))
	
	# Caso D: HP actual inválido (menor que 1)
	var dict_invalid_hp = {"save_slot": 1, "version": "1.0.0-fase5", "timestamp": "2026-10-16T12:00:00", "character_class": "Asesino", "level": 5, "current_hp": 0}
	_record_assertion("SaveSchema_Semantic", "zero_hp_rejected", false, SaveManager.validate_save_dict(dict_invalid_hp), not SaveManager.validate_save_dict(dict_invalid_hp))
	
	# Caso E: Inconsistencia max_hp < current_hp
	var dict_inconsistent_hp = {"save_slot": 1, "version": "1.0.0-fase5", "timestamp": "2026-10-16T12:00:00", "character_class": "Asesino", "level": 5, "current_hp": 150, "max_hp": 100}
	_record_assertion("SaveSchema_Semantic", "max_hp_lower_than_current_rejected", false, SaveManager.validate_save_dict(dict_inconsistent_hp), not SaveManager.validate_save_dict(dict_inconsistent_hp))
	
	# Caso F: Clase desconocida
	var dict_unknown_class = {"save_slot": 1, "version": "1.0.0-fase5", "timestamp": "2026-10-16T12:00:00", "character_class": "HechiceroOscuro", "level": 5, "current_hp": 100}
	_record_assertion("SaveSchema_Semantic", "unknown_class_rejected", false, SaveManager.validate_save_dict(dict_unknown_class), not SaveManager.validate_save_dict(dict_unknown_class))
	
	# Caso G: Versión no reconocida
	var dict_unknown_version = {"save_slot": 1, "version": "99.0.0-incompatible", "timestamp": "2026-10-16T12:00:00", "character_class": "Asesino", "level": 5, "current_hp": 100}
	_record_assertion("SaveSchema_Semantic", "incompatible_version_rejected", false, SaveManager.validate_save_dict(dict_unknown_version), not SaveManager.validate_save_dict(dict_unknown_version))
	
	# Escribir un JSON sintácticamente correcto pero semánticamente inválido y verificar evaluate_save_status
	var f_sem := FileAccess.open(p1, FileAccess.WRITE)
	if f_sem:
		f_sem.store_string(JSON.stringify(dict_wrong_type, "\t"))
		f_sem.close()
	_record_assertion("SaveSchema_Semantic", "status_semantically_invalid", SaveManager.SaveStatus.SEMANTICALLY_INVALID, SaveManager.evaluate_save_status(1), SaveManager.evaluate_save_status(1) == SaveManager.SaveStatus.SEMANTICALLY_INVALID)
	
	# 2.5 Guardado Válido Conforme al Esquema Reconocido
	var dict_valid = {
		"save_slot": 1,
		"version": "1.0.0-fase5",
		"timestamp": "2026-10-16T12:00:00",
		"character_class": "Asesino",
		"level": 5,
		"current_hp": 85,
		"max_hp": 100,
		"current_exp": 340
	}
	_record_assertion("SaveSchema_Valid", "dict_valid_approved", true, SaveManager.validate_save_dict(dict_valid), SaveManager.validate_save_dict(dict_valid))
	SaveManager.save_game(1, dict_valid)
	_record_assertion("SaveSchema_Valid", "status_valid", SaveManager.SaveStatus.VALID, SaveManager.evaluate_save_status(1), SaveManager.evaluate_save_status(1) == SaveManager.SaveStatus.VALID)
	_record_assertion("SaveSchema_Valid", "is_save_valid_true", true, SaveManager.is_save_valid(1), SaveManager.is_save_valid(1))
	
	# Verificar que el canario de producción sigue intacto tras estas operaciones
	_record_assertion("SaveIsolation_Check", "canary_intact_after_schema_tests", true, _verify_canary_intact(), _verify_canary_intact())
	
	# =========================================================================
	# BLOQUE 3: Múltiples Slots y Fallback ante Corrupción (en test dir)
	# =========================================================================
	SaveManager.clean_test_saves_dir()
	
	# Guardar slot 1 con fecha anterior
	SaveManager.save_game(1, {"save_slot": 1, "character_class": "Guerrero", "level": 3, "current_hp": 120, "timestamp": "2026-10-15T08:00:00"})
	# Guardar slot 2 con fecha más reciente
	SaveManager.save_game(2, {"save_slot": 2, "character_class": "Asesino", "level": 10, "current_hp": 90, "timestamp": "2026-10-16T15:30:00"})
	# Guardar slot 3 con fecha intermedia
	SaveManager.save_game(3, {"save_slot": 3, "character_class": "Caballero", "level": 6, "current_hp": 150, "timestamp": "2026-10-16T10:00:00"})
	
	_record_assertion("Method_SaveManager_Timestamps", "latest_slot_is_slot2", 2, SaveManager.get_latest_save_slot(), SaveManager.get_latest_save_slot() == 2)
	
	# Actualizar slot 3 con fecha aún más reciente
	SaveManager.save_game(3, {"save_slot": 3, "character_class": "Caballero", "level": 12, "current_hp": 200, "timestamp": "2026-10-16T20:45:00"})
	_record_assertion("Method_SaveManager_Timestamps", "latest_slot_updates_to_slot3", 3, SaveManager.get_latest_save_slot(), SaveManager.get_latest_save_slot() == 3)
	
	# Si corrompemos el slot 3 más reciente, debe descartarlo y retroceder a slot 2
	var p3 := SaveManager.get_save_path(3)
	var f_broken3 := FileAccess.open(p3, FileAccess.WRITE)
	if f_broken3:
		f_broken3.store_string("corrupted_json")
		f_broken3.close()
	_record_assertion("Method_SaveManager_CorruptFallback", "slot3_status_syntax_error", SaveManager.SaveStatus.JSON_SYNTAX_ERROR, SaveManager.evaluate_save_status(3), SaveManager.evaluate_save_status(3) == SaveManager.SaveStatus.JSON_SYNTAX_ERROR)
	_record_assertion("Method_SaveManager_CorruptFallback", "latest_slot_fallback_to_slot2", 2, SaveManager.get_latest_save_slot(), SaveManager.get_latest_save_slot() == 2)
	
	# Reactividad en MainMenu dentro del entorno aislado
	main_menu._check_save_state()
	_record_assertion("ContinueButton_Reactive", "continue_enabled_with_save", false, main_menu.btn_continue.disabled, not main_menu.btn_continue.disabled)
	_record_assertion("ContinueButton_Reactive", "continue_shows_slot2", true, main_menu.btn_continue.text.contains("Slot 2"), main_menu.btn_continue.text.contains("Slot 2"))
	
	SaveManager.clean_test_saves_dir()
	main_menu._check_save_state()
	_record_assertion("ContinueButton_Reactive", "continue_disabled_after_cleanup", true, main_menu.btn_continue.disabled, main_menu.btn_continue.disabled)
	_record_assertion("ContinueButton_Reactive", "continue_shows_sin_partida", true, main_menu.btn_continue.text.contains("Sin partida"), main_menu.btn_continue.text.contains("Sin partida"))
	
	# =========================================================================
	# BLOQUE 4: Opciones en DisplayManager y ProfileManager
	# =========================================================================
	main_menu._on_window_mode_selected(1) # BORDERLESS
	_record_assertion("Method_DisplayManager", "window_mode_borderless", DisplayManager.WindowMode.BORDERLESS, DisplayManager.current_window_mode, DisplayManager.current_window_mode == DisplayManager.WindowMode.BORDERLESS)
	main_menu._on_window_mode_selected(2) # FULLSCREEN
	_record_assertion("Method_DisplayManager", "window_mode_fullscreen", DisplayManager.WindowMode.FULLSCREEN, DisplayManager.current_window_mode, DisplayManager.current_window_mode == DisplayManager.WindowMode.FULLSCREEN)
	main_menu._on_window_mode_selected(0) # WINDOWED
	_record_assertion("Method_DisplayManager", "window_mode_windowed", DisplayManager.WindowMode.WINDOWED, DisplayManager.current_window_mode, DisplayManager.current_window_mode == DisplayManager.WindowMode.WINDOWED)
	
	main_menu._on_resolution_selected(0) # 1280x720
	_record_assertion("Method_DisplayManager", "resolution_720p", Vector2i(1280, 720), DisplayManager.current_resolution, DisplayManager.current_resolution == Vector2i(1280, 720))
	main_menu._on_resolution_selected(2) # 1920x1080
	_record_assertion("Method_DisplayManager", "resolution_1080p", Vector2i(1920, 1080), DisplayManager.current_resolution, DisplayManager.current_resolution == Vector2i(1920, 1080))
	main_menu._on_resolution_selected(4) # 3840x2160
	_record_assertion("Method_DisplayManager", "resolution_4k", Vector2i(3840, 2160), DisplayManager.current_resolution, DisplayManager.current_resolution == Vector2i(3840, 2160))
	main_menu._on_resolution_selected(0) # Restaurar 1280x720
	
	main_menu._on_vsync_toggled(false)
	_record_assertion("Method_DisplayManager", "vsync_disabled", false, DisplayManager.vsync_enabled, not DisplayManager.vsync_enabled)
	main_menu._on_vsync_toggled(true)
	_record_assertion("Method_DisplayManager", "vsync_enabled", true, DisplayManager.vsync_enabled, DisplayManager.vsync_enabled)
	
	main_menu._on_profile_selected(0) # LOW
	_record_assertion("Method_ProfileManager", "profile_low", ProfileManager.QualityProfile.LOW, ProfileManager.current_profile, ProfileManager.current_profile == ProfileManager.QualityProfile.LOW)
	_record_assertion("Method_ProfileManager", "profile_low_multiplier", 0.5, ProfileManager.get_particle_multiplier(), ProfileManager.get_particle_multiplier() == 0.5)
	
	main_menu._on_profile_selected(2) # HIGH
	_record_assertion("Method_ProfileManager", "profile_high", ProfileManager.QualityProfile.HIGH, ProfileManager.current_profile, ProfileManager.current_profile == ProfileManager.QualityProfile.HIGH)
	_record_assertion("Method_ProfileManager", "profile_high_multiplier", 1.5, ProfileManager.get_particle_multiplier(), ProfileManager.get_particle_multiplier() == 1.5)
	
	main_menu._on_profile_selected(1) # Restaurar MEDIUM
	_record_assertion("Method_ProfileManager", "profile_medium", ProfileManager.QualityProfile.MEDIUM, ProfileManager.current_profile, ProfileManager.current_profile == ProfileManager.QualityProfile.MEDIUM)
	
	# =========================================================================
	# BLOQUE 5: Verificación de Mapeos de Acciones en InputMap
	# =========================================================================
	_record_assertion("InputMap_Association", "has_action_ui_down", true, InputMap.has_action("ui_down"), InputMap.has_action("ui_down"))
	_record_assertion("InputMap_Association", "has_action_ui_up", true, InputMap.has_action("ui_up"), InputMap.has_action("ui_up"))
	_record_assertion("InputMap_Association", "has_action_ui_accept", true, InputMap.has_action("ui_accept"), InputMap.has_action("ui_accept"))
	_record_assertion("InputMap_Association", "has_action_ui_cancel", true, InputMap.has_action("ui_cancel"), InputMap.has_action("ui_cancel"))
	_record_assertion("InputMap_Association", "has_action_interact", true, InputMap.has_action("interact"), InputMap.has_action("interact"))
	_record_assertion("InputMap_Association", "has_action_cancel", true, InputMap.has_action("cancel"), InputMap.has_action("cancel"))
	
	# =========================================================================
	# BLOQUE 6: Pruebas de Entrada Simulada Diferenciadas (Teclado y Gamepad)
	# =========================================================================
	# 6.1 Acciones de Motor Simuladas (ActionSimulation)
	main_menu.btn_new_game.grab_focus()
	await get_tree().process_frame
	await _simulate_action_press_and_release("ui_down")
	var focused_action := get_viewport().gui_get_focus_owner()
	_record_assertion("ActionSimulation_Navigation", "ui_down_action_navigates", main_menu.btn_options, focused_action, focused_action == main_menu.btn_options)
	
	await _simulate_action_press_and_release("ui_up")
	var focused_action_up := get_viewport().gui_get_focus_owner()
	_record_assertion("ActionSimulation_Navigation", "ui_up_action_navigates_back", main_menu.btn_new_game, focused_action_up, focused_action_up == main_menu.btn_new_game)
	
	# 6.2 Eventos Crudos de Teclado Simulados (SimulatedKeyboard_RawEvents)
	main_menu.btn_new_game.grab_focus()
	await get_tree().process_frame
	await _simulate_key_press_and_release(KEY_DOWN)
	var focused_key := get_viewport().gui_get_focus_owner()
	_record_assertion("SimulatedKeyboard_RawEvents", "key_down_shifts_focus", main_menu.btn_options, focused_key, focused_key == main_menu.btn_options)
	
	# Abrir modal con Enter (KEY_ENTER)
	await _simulate_key_press_and_release(KEY_ENTER)
	_record_assertion("SimulatedKeyboard_RawEvents", "key_enter_opens_options", true, main_menu.options_panel.visible, main_menu.options_panel.visible)
	
	# Cerrar modal con Escape (KEY_ESCAPE)
	await _simulate_key_press_and_release(KEY_ESCAPE)
	_record_assertion("SimulatedKeyboard_RawEvents", "key_escape_closes_options", false, main_menu.options_panel.visible, not main_menu.options_panel.visible)
	
	# 6.3 Eventos Crudos de Mando Simulados (SimulatedGamepad_RawEvents)
	main_menu.btn_new_game.grab_focus()
	await get_tree().process_frame
	await _simulate_joy_button_press_and_release(JOY_BUTTON_DPAD_DOWN)
	var focused_joy := get_viewport().gui_get_focus_owner()
	_record_assertion("SimulatedGamepad_RawEvents", "joy_dpad_down_shifts_focus", main_menu.btn_options, focused_joy, focused_joy == main_menu.btn_options)
	
	# Disparar botón A (JOY_BUTTON_A) sobre Nueva Partida
	main_menu.btn_new_game.grab_focus()
	await get_tree().process_frame
	await _simulate_joy_button_press_and_release(JOY_BUTTON_A)
	_record_assertion("SimulatedGamepad_RawEvents", "joy_button_a_triggers_new_game", true, main_menu.stub_panel.visible, main_menu.stub_panel.visible)
	
	# Cerrar con botón B (JOY_BUTTON_B)
	await _simulate_joy_button_press_and_release(JOY_BUTTON_B)
	_record_assertion("SimulatedGamepad_RawEvents", "joy_button_b_closes_modal", false, main_menu.stub_panel.visible, not main_menu.stub_panel.visible)
	
	# =========================================================================
	# BLOQUE 7: Punto de Integración de Nueva Partida hacia T5.B
	# =========================================================================
	main_menu._on_btn_new_game_pressed()
	_record_assertion("NewGame_IntegrationPoint", "stub_modal_visible", true, main_menu.stub_panel.visible, main_menu.stub_panel.visible)
	_record_assertion("NewGame_IntegrationPoint", "stub_references_t5b", true, main_menu.stub_label.text.contains("T5.B"), main_menu.stub_label.text.contains("T5.B"))
	_record_assertion("NewGame_IntegrationPoint", "stub_explicit_disclaimer_narrative_pending", true, main_menu.stub_label.text.contains("no está completa") or main_menu.stub_label.text.contains("permanece pendiente"), main_menu.stub_label.text.contains("no está completa") or main_menu.stub_label.text.contains("permanece pendiente"))
	main_menu._on_btn_stub_close_pressed()
	_record_assertion("NewGame_IntegrationPoint", "stub_closed", false, main_menu.stub_panel.visible, not main_menu.stub_panel.visible)
	
	# =========================================================================
	# BLOQUE 8: Verificación Final de Integridad de Guardados Reales y Limpieza
	# =========================================================================
	_record_assertion("SaveIsolation_Final", "canary_untouched_after_entire_suite", true, _verify_canary_intact(), _verify_canary_intact())
	
	# Limpieza de archivos temporales de prueba
	SaveManager.clean_test_saves_dir()
	if DirAccess.dir_exists_absolute(SaveManager.TEST_SAVE_DIR):
		DirAccess.remove_absolute(SaveManager.TEST_SAVE_DIR)
		
	# Limpieza del canario de producción
	if FileAccess.file_exists(CANARY_PATH):
		DirAccess.remove_absolute(CANARY_PATH)
	_record_assertion("SaveIsolation_Final", "canary_cleaned_up_safely", false, FileAccess.file_exists(CANARY_PATH), not FileAccess.file_exists(CANARY_PATH))
	
	# Restablecer SaveManager al directorio de producción
	SaveManager.reset_save_dir()
	_record_assertion("SaveIsolation_Final", "save_dir_restored_to_default", SaveManager.DEFAULT_SAVE_DIR, SaveManager.get_save_dir(), SaveManager.get_save_dir() == SaveManager.DEFAULT_SAVE_DIR)
	
	# =========================================================================
	# BLOQUE 9: Captura de pantalla y reporte
	# =========================================================================
	_save_preview_capture("res://anim_captures/main_menu_preview.png")
	_export_report()


func _save_preview_capture(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("[TestMainMenu] Modo headless detectado; se omite captura por textura nula.")
		return
	var tex = get_viewport().get_texture()
	if tex:
		var img = tex.get_image()
		if img:
			var global_path = ProjectSettings.globalize_path(path)
			img.save_png(global_path)
			print("[TestMainMenu] Captura de preview guardada en: ", global_path)


func _export_report() -> void:
	var report = {
		"suite": "T5.A MainMenu Final Acceptance & Safety Test",
		"timestamp": Time.get_datetime_string_from_system(),
		"total_assertions": test_results.size(),
		"pass": pass_count,
		"fail": fail_count,
		"verdict": "PASS" if fail_count == 0 else "FAIL",
		"isolated_test_dir": SaveManager.TEST_SAVE_DIR,
		"production_save_dir_protected": SaveManager.DEFAULT_SAVE_DIR,
		"assertions": test_results
	}
	
	var json_str := JSON.stringify(report, "\t")
	var out_path := "res://anim_captures/main_menu_test_results.json"
	var file := FileAccess.open(out_path, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		print("[TestMainMenu] Reporte exportado a: ", out_path)
		
	print("\n======================================================================")
	print("[TestMainMenu] RESULTADO: %d Aprobadas | %d Falladas | Dictamen: %s" % [pass_count, fail_count, report["verdict"]])
	print("======================================================================\n")
	
	if fail_count > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)
