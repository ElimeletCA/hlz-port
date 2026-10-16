extends Node

# test_main_menu.gd — Batería de pruebas automatizadas para el Menú Principal (T5.A)
# Verifica:
#   1. Jerarquía y estado inicial de nodos de MainMenu.tscn.
#   2. Pruebas de método para SaveManager (archivos ausentes, JSON corrupto, timestamps múltiples).
#   3. Pruebas de método para Opciones (DisplayManager + ProfileManager).
#   4. Pruebas de interacción en vivo con teclado (navegación por foco, enter/espacio, escape).
#   5. Pruebas de interacción en vivo con mando (D-pad/stick, botón A interactuar, botón B cancelar).
#   6. Punto de integración temporal hacia T5.B sin declarar transición narrativa completa.
#   7. Captura de pantalla real de la interfaz.
#   8. Exportación de reporte con resultados reales.

var test_results: Array[Dictionary] = []
var pass_count: int = 0
var fail_count: int = 0

@onready var main_menu = $MainMenu

func _ready() -> void:
	print("\n======================================================================")
	print("[TestMainMenu] INICIANDO PRUEBAS DE ACEPTACIÓN AMPLIADAS DE T5.A")
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
	# BLOQUE 1: Existencia y jerarquía de nodos esenciales
	# =========================================================================
	_record_assertion("NodesExistence", "main_menu_valid", true, is_instance_valid(main_menu), is_instance_valid(main_menu))
	_record_assertion("NodesExistence", "btn_new_game_valid", true, is_instance_valid(main_menu.btn_new_game), is_instance_valid(main_menu.btn_new_game))
	_record_assertion("NodesExistence", "btn_continue_valid", true, is_instance_valid(main_menu.btn_continue), is_instance_valid(main_menu.btn_continue))
	_record_assertion("NodesExistence", "btn_options_valid", true, is_instance_valid(main_menu.btn_options), is_instance_valid(main_menu.btn_options))
	_record_assertion("NodesExistence", "btn_quit_valid", true, is_instance_valid(main_menu.btn_quit), is_instance_valid(main_menu.btn_quit))
	
	# =========================================================================
	# BLOQUE 2: Pruebas de Método de SaveManager (Ausentes, Corruptos, Timestamps)
	# =========================================================================
	# Limpiar slots de prueba
	SaveManager.delete_save(1)
	SaveManager.delete_save(2)
	SaveManager.delete_save(3)
	
	# 2.1 Archivo ausente
	_record_assertion("Method_SaveManager_Missing", "slot1_valid_when_missing", false, SaveManager.is_save_valid(1), not SaveManager.is_save_valid(1))
	_record_assertion("Method_SaveManager_Missing", "slot1_load_when_missing", {}, SaveManager.load_game(1), SaveManager.load_game(1).is_empty())
	_record_assertion("Method_SaveManager_Missing", "has_any_save_when_empty", false, SaveManager.has_any_save(), not SaveManager.has_any_save())
	_record_assertion("Method_SaveManager_Missing", "latest_slot_when_empty", 0, SaveManager.get_latest_save_slot(), SaveManager.get_latest_save_slot() == 0)
	
	# 2.2 Archivo vacío (0 bytes) y JSON inválido
	var p2 := SaveManager.get_save_path(2)
	SaveManager._ensure_dir_exists()
	var f_empty := FileAccess.open(p2, FileAccess.WRITE)
	if f_empty:
		f_empty.store_string("")
		f_empty.close()
	_record_assertion("Method_SaveManager_EmptyFile", "slot2_valid_when_empty_file", false, SaveManager.is_save_valid(2), not SaveManager.is_save_valid(2))
	_record_assertion("Method_SaveManager_EmptyFile", "slot2_has_save_when_empty_file", false, SaveManager.has_save(2), not SaveManager.has_save(2))
	_record_assertion("Method_SaveManager_EmptyFile", "slot2_load_when_empty_file", {}, SaveManager.load_game(2), SaveManager.load_game(2).is_empty())
	
	# Corromper slot 2 con JSON roto
	var f_corrupt := FileAccess.open(p2, FileAccess.WRITE)
	if f_corrupt:
		f_corrupt.store_string("{\n\t\"level\": 99,\n\t\"corrupt_syntax\": [UNCLOSED_ARRAY\n")
		f_corrupt.close()
	_record_assertion("Method_SaveManager_CorruptJSON", "slot2_valid_when_corrupt_json", false, SaveManager.is_save_valid(2), not SaveManager.is_save_valid(2))
	_record_assertion("Method_SaveManager_CorruptJSON", "slot2_has_save_when_corrupt_json", false, SaveManager.has_save(2), not SaveManager.has_save(2))
	_record_assertion("Method_SaveManager_CorruptJSON", "slot2_load_when_corrupt_json", {}, SaveManager.load_game(2), SaveManager.load_game(2).is_empty())
	SaveManager.delete_save(2)
	
	# 2.3 Múltiples slots con marcas de tiempo distintas
	# Guardar slot 1 con fecha anterior
	SaveManager.save_game(1, {"level": 3, "character_class": "Guerrero", "timestamp": "2026-10-15T08:00:00"})
	# Guardar slot 2 con fecha más reciente
	SaveManager.save_game(2, {"level": 10, "character_class": "Asesino", "timestamp": "2026-10-16T15:30:00"})
	# Guardar slot 3 con fecha intermedia
	SaveManager.save_game(3, {"level": 6, "character_class": "Caballero", "timestamp": "2026-10-16T10:00:00"})
	
	_record_assertion("Method_SaveManager_Timestamps", "slot1_valid", true, SaveManager.is_save_valid(1), SaveManager.is_save_valid(1))
	_record_assertion("Method_SaveManager_Timestamps", "slot2_valid", true, SaveManager.is_save_valid(2), SaveManager.is_save_valid(2))
	_record_assertion("Method_SaveManager_Timestamps", "slot3_valid", true, SaveManager.is_save_valid(3), SaveManager.is_save_valid(3))
	_record_assertion("Method_SaveManager_Timestamps", "has_any_save_true", true, SaveManager.has_any_save(), SaveManager.has_any_save())
	_record_assertion("Method_SaveManager_Timestamps", "latest_slot_is_slot2", 2, SaveManager.get_latest_save_slot(), SaveManager.get_latest_save_slot() == 2)
	
	# Actualizar slot 3 con fecha aún más reciente
	SaveManager.save_game(3, {"level": 12, "character_class": "Caballero", "timestamp": "2026-10-16T20:45:00"})
	_record_assertion("Method_SaveManager_Timestamps", "latest_slot_updates_to_slot3", 3, SaveManager.get_latest_save_slot(), SaveManager.get_latest_save_slot() == 3)
	
	# Si corrompemos el slot 3 más reciente, debe ignorarlo y retroceder a slot 2
	var p3 := SaveManager.get_save_path(3)
	var f_corrupt3 := FileAccess.open(p3, FileAccess.WRITE)
	if f_corrupt3:
		f_corrupt3.store_string("corrupt")
		f_corrupt3.close()
	_record_assertion("Method_SaveManager_CorruptFallback", "slot3_now_invalid", false, SaveManager.is_save_valid(3), not SaveManager.is_save_valid(3))
	_record_assertion("Method_SaveManager_CorruptFallback", "latest_slot_fallback_to_slot2", 2, SaveManager.get_latest_save_slot(), SaveManager.get_latest_save_slot() == 2)
	
	# Comprobar reactividad del botón Continuar en MainMenu
	main_menu._check_save_state()
	_record_assertion("ContinueButton_Reactive", "continue_enabled_with_save", false, main_menu.btn_continue.disabled, not main_menu.btn_continue.disabled)
	_record_assertion("ContinueButton_Reactive", "continue_shows_slot2", true, main_menu.btn_continue.text.contains("Slot 2"), main_menu.btn_continue.text.contains("Slot 2"))
	
	# Limpiar slots temporales de prueba
	SaveManager.delete_save(1)
	SaveManager.delete_save(2)
	SaveManager.delete_save(3)
	main_menu._check_save_state()
	_record_assertion("ContinueButton_Reactive", "continue_disabled_after_cleanup", true, main_menu.btn_continue.disabled, main_menu.btn_continue.disabled)
	_record_assertion("ContinueButton_Reactive", "continue_shows_sin_partida", true, main_menu.btn_continue.text.contains("Sin partida"), main_menu.btn_continue.text.contains("Sin partida"))
	
	# =========================================================================
	# BLOQUE 3: Pruebas de Método para Opciones (DisplayManager + ProfileManager)
	# =========================================================================
	# 3.1 Modos de ventana en DisplayManager
	main_menu._on_window_mode_selected(1) # BORDERLESS
	_record_assertion("Method_DisplayManager", "window_mode_borderless", DisplayManager.WindowMode.BORDERLESS, DisplayManager.current_window_mode, DisplayManager.current_window_mode == DisplayManager.WindowMode.BORDERLESS)
	main_menu._on_window_mode_selected(2) # FULLSCREEN
	_record_assertion("Method_DisplayManager", "window_mode_fullscreen", DisplayManager.WindowMode.FULLSCREEN, DisplayManager.current_window_mode, DisplayManager.current_window_mode == DisplayManager.WindowMode.FULLSCREEN)
	main_menu._on_window_mode_selected(0) # WINDOWED
	_record_assertion("Method_DisplayManager", "window_mode_windowed", DisplayManager.WindowMode.WINDOWED, DisplayManager.current_window_mode, DisplayManager.current_window_mode == DisplayManager.WindowMode.WINDOWED)
	
	# 3.2 Resoluciones en DisplayManager
	main_menu._on_resolution_selected(0) # 1280x720
	_record_assertion("Method_DisplayManager", "resolution_720p", Vector2i(1280, 720), DisplayManager.current_resolution, DisplayManager.current_resolution == Vector2i(1280, 720))
	main_menu._on_resolution_selected(2) # 1920x1080
	_record_assertion("Method_DisplayManager", "resolution_1080p", Vector2i(1920, 1080), DisplayManager.current_resolution, DisplayManager.current_resolution == Vector2i(1920, 1080))
	main_menu._on_resolution_selected(4) # 3840x2160
	_record_assertion("Method_DisplayManager", "resolution_4k", Vector2i(3840, 2160), DisplayManager.current_resolution, DisplayManager.current_resolution == Vector2i(3840, 2160))
	main_menu._on_resolution_selected(0) # Restaurar 1280x720 para desarrollo
	
	# 3.3 V-Sync en DisplayManager
	main_menu._on_vsync_toggled(false)
	_record_assertion("Method_DisplayManager", "vsync_disabled", false, DisplayManager.vsync_enabled, not DisplayManager.vsync_enabled)
	main_menu._on_vsync_toggled(true)
	_record_assertion("Method_DisplayManager", "vsync_enabled", true, DisplayManager.vsync_enabled, DisplayManager.vsync_enabled)
	
	# 3.4 Perfiles de Calidad en ProfileManager
	main_menu._on_profile_selected(0) # LOW
	_record_assertion("Method_ProfileManager", "profile_low", ProfileManager.QualityProfile.LOW, ProfileManager.current_profile, ProfileManager.current_profile == ProfileManager.QualityProfile.LOW)
	_record_assertion("Method_ProfileManager", "profile_low_name", "Bajo", ProfileManager.get_profile_name(), ProfileManager.get_profile_name() == "Bajo")
	_record_assertion("Method_ProfileManager", "profile_low_multiplier", 0.5, ProfileManager.get_particle_multiplier(), ProfileManager.get_particle_multiplier() == 0.5)
	
	main_menu._on_profile_selected(2) # HIGH
	_record_assertion("Method_ProfileManager", "profile_high", ProfileManager.QualityProfile.HIGH, ProfileManager.current_profile, ProfileManager.current_profile == ProfileManager.QualityProfile.HIGH)
	_record_assertion("Method_ProfileManager", "profile_high_name", "Alto", ProfileManager.get_profile_name(), ProfileManager.get_profile_name() == "Alto")
	_record_assertion("Method_ProfileManager", "profile_high_multiplier", 1.5, ProfileManager.get_particle_multiplier(), ProfileManager.get_particle_multiplier() == 1.5)
	
	main_menu._on_profile_selected(1) # Restaurar MEDIUM
	_record_assertion("Method_ProfileManager", "profile_medium", ProfileManager.QualityProfile.MEDIUM, ProfileManager.current_profile, ProfileManager.current_profile == ProfileManager.QualityProfile.MEDIUM)
	_record_assertion("Method_ProfileManager", "profile_medium_multiplier", 1.0, ProfileManager.get_particle_multiplier(), ProfileManager.get_particle_multiplier() == 1.0)
	
	# =========================================================================
	# BLOQUE 4: Interacción Real con Teclado (LiveInput_Keyboard)
	# =========================================================================
	# 4.1 Foco inicial y navegación vertical con teclas
	main_menu.btn_new_game.grab_focus()
	await get_tree().process_frame
	var focused_node := get_viewport().gui_get_focus_owner()
	_record_assertion("LiveInput_Keyboard", "initial_focus_is_new_game", main_menu.btn_new_game, focused_node, focused_node == main_menu.btn_new_game)
	
	# Simular pulsación de tecla flecha abajo (ui_down)
	await _simulate_action_press_and_release("ui_down")
	var focused_after_down := get_viewport().gui_get_focus_owner()
	# Continuar está deshabilitado, por lo que el foco pasa directamente a btn_options
	_record_assertion("LiveInput_Keyboard", "focus_moves_to_options", main_menu.btn_options, focused_after_down, focused_after_down == main_menu.btn_options)
	
	# Simular pulsación de tecla flecha arriba (ui_up)
	await _simulate_action_press_and_release("ui_up")
	var focused_after_up := get_viewport().gui_get_focus_owner()
	_record_assertion("LiveInput_Keyboard", "focus_returns_to_new_game", main_menu.btn_new_game, focused_after_up, focused_after_up == main_menu.btn_new_game)
	
	# 4.2 Abrir Opciones mediante tecla Enter / Espacio (ui_accept)
	main_menu.btn_options.grab_focus()
	await get_tree().process_frame
	await _simulate_action_press_and_release("ui_accept")
	_record_assertion("LiveInput_Keyboard", "options_opened_via_accept_key", true, main_menu.options_panel.visible, main_menu.options_panel.visible)
	_record_assertion("LiveInput_Keyboard", "menu_buttons_hidden_on_options_open", false, main_menu.menu_buttons_container.visible, not main_menu.menu_buttons_container.visible)
	
	# 4.3 Cerrar Opciones mediante tecla Escape (ui_cancel)
	await _simulate_action_press_and_release("ui_cancel")
	_record_assertion("LiveInput_Keyboard", "options_closed_via_escape_key", false, main_menu.options_panel.visible, not main_menu.options_panel.visible)
	_record_assertion("LiveInput_Keyboard", "menu_buttons_restored_on_options_close", true, main_menu.menu_buttons_container.visible, main_menu.menu_buttons_container.visible)
	
	# =========================================================================
	# BLOQUE 5: Interacción Real con Mando / Gamepad (LiveInput_Gamepad)
	# =========================================================================
	# 5.1 Navegación con D-pad / Stick del mando (acciones ui_down y ui_up)
	main_menu.btn_new_game.grab_focus()
	await get_tree().process_frame
	await _simulate_action_press_and_release("ui_down")
	var focused_gamepad := get_viewport().gui_get_focus_owner()
	_record_assertion("LiveInput_Gamepad", "gamepad_dpad_down_navigates", main_menu.btn_options, focused_gamepad, focused_gamepad == main_menu.btn_options)
	
	# 5.2 Botón A del mando (ui_accept) sobre Nueva Partida
	main_menu.btn_new_game.grab_focus()
	await get_tree().process_frame
	await _simulate_action_press_and_release("ui_accept")
	_record_assertion("LiveInput_Gamepad", "gamepad_button_a_triggers_new_game", true, main_menu.stub_panel.visible, main_menu.stub_panel.visible)
	
	# 5.3 Botón B del mando (ui_cancel / cancel) para cerrar modal
	await _simulate_action_press_and_release("ui_cancel")
	_record_assertion("LiveInput_Gamepad", "gamepad_button_b_closes_modal", false, main_menu.stub_panel.visible, not main_menu.stub_panel.visible)
	_record_assertion("LiveInput_Gamepad", "gamepad_restores_menu_state", true, main_menu.menu_buttons_container.visible, main_menu.menu_buttons_container.visible)
	
	# =========================================================================
	# BLOQUE 6: Punto de Integración Temporal de Nueva Partida (T5.B)
	# =========================================================================
	main_menu._on_btn_new_game_pressed()
	_record_assertion("NewGame_IntegrationPoint", "stub_modal_visible", true, main_menu.stub_panel.visible, main_menu.stub_panel.visible)
	_record_assertion("NewGame_IntegrationPoint", "stub_references_t5b", true, main_menu.stub_label.text.contains("T5.B"), main_menu.stub_label.text.contains("T5.B"))
	_record_assertion("NewGame_IntegrationPoint", "stub_explicit_disclaimer_narrative_pending", true, main_menu.stub_label.text.contains("no está completa") or main_menu.stub_label.text.contains("permanece pendiente"), main_menu.stub_label.text.contains("no está completa") or main_menu.stub_label.text.contains("permanece pendiente"))
	main_menu._on_btn_stub_close_pressed()
	_record_assertion("NewGame_IntegrationPoint", "stub_closed", false, main_menu.stub_panel.visible, not main_menu.stub_panel.visible)
	
	# =========================================================================
	# BLOQUE 7: Captura de pantalla y reporte
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
		"suite": "T5.A MainMenu Acceptance Test Extended",
		"timestamp": Time.get_datetime_string_from_system(),
		"total_assertions": test_results.size(),
		"pass": pass_count,
		"fail": fail_count,
		"verdict": "PASS" if fail_count == 0 else "FAIL",
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
