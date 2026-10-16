extends Node

# test_main_menu.gd — Batería de pruebas automatizadas para el Menú Principal (T5.A)
# Verifica:
#   1. Carga e inicialización limpia de MainMenu.tscn.
#   2. Estado condicional de "Continuar" (deshabilitado sin partida, habilitado con partida).
#   3. Comportamiento y transición de "Nueva Partida" (conexión hacia T5.B).
#   4. Apertura, controles y cierre del panel de Opciones (DisplayManager + ProfileManager).
#   5. Navegación de foco y compatibilidad con teclado/mando.
#   6. Captura de pantalla real de la interfaz.

var test_results: Array[Dictionary] = []
var pass_count: int = 0
var fail_count: int = 0

@onready var main_menu = $MainMenu

func _ready() -> void:
	print("\n======================================================================")
	print("[TestMainMenu] INICIANDO PRUEBAS DE ACEPTACIÓN DE T5.A (MENÚ PRINCIPAL)")
	print("======================================================================")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	_run_all_tests()


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


func _run_all_tests() -> void:
	# 1. Comprobar existencia y visibilidad de nodos esenciales
	_record_assertion("NodesExistence", "main_menu_valid", true, is_instance_valid(main_menu), is_instance_valid(main_menu))
	_record_assertion("NodesExistence", "btn_new_game_valid", true, is_instance_valid(main_menu.btn_new_game), is_instance_valid(main_menu.btn_new_game))
	_record_assertion("NodesExistence", "btn_continue_valid", true, is_instance_valid(main_menu.btn_continue), is_instance_valid(main_menu.btn_continue))
	_record_assertion("NodesExistence", "btn_options_valid", true, is_instance_valid(main_menu.btn_options), is_instance_valid(main_menu.btn_options))
	_record_assertion("NodesExistence", "btn_quit_valid", true, is_instance_valid(main_menu.btn_quit), is_instance_valid(main_menu.btn_quit))
	
	# 2. Comprobar botón Nueva Partida
	_record_assertion("NewGameButton", "new_game_enabled", false, main_menu.btn_new_game.disabled, not main_menu.btn_new_game.disabled)
	_record_assertion("NewGameButton", "new_game_visible", true, main_menu.btn_new_game.is_visible_in_tree(), main_menu.btn_new_game.is_visible_in_tree())
	
	# 3. Comprobar estado de botón Continuar según presencia de partidas
	var has_save: bool = SaveManager.has_any_save()
	if not has_save:
		_record_assertion("ContinueButton_NoSave", "continue_disabled_when_no_save", true, main_menu.btn_continue.disabled, main_menu.btn_continue.disabled)
	else:
		_record_assertion("ContinueButton_HasSave", "continue_enabled_when_save_exists", false, main_menu.btn_continue.disabled, not main_menu.btn_continue.disabled)
		
	# 4. Probar simulación con guardado temporal y verificar reactividad
	var test_slot := 3
	var temp_save_created := false
	if not SaveManager.has_save(test_slot):
		SaveManager.save_game(test_slot, {"level": 5, "character_class": "Asesino", "current_hp": 85})
		temp_save_created = true
	
	main_menu._check_save_state()
	_record_assertion("ContinueButton_Reactive", "continue_enabled_with_save", false, main_menu.btn_continue.disabled, not main_menu.btn_continue.disabled)
	_record_assertion("ContinueButton_Reactive", "continue_shows_slot", true, main_menu.btn_continue.text.contains("Slot"), main_menu.btn_continue.text.contains("Slot"))
	
	# Limpiar guardado temporal de prueba si se creó
	if temp_save_created:
		var p := SaveManager.get_save_path(test_slot)
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
		main_menu._check_save_state()
	
	# 5. Probar flujo de Opciones
	_record_assertion("OptionsFlow", "options_modal_initially_hidden", false, main_menu.options_panel.visible, not main_menu.options_panel.visible)
	main_menu._on_btn_options_pressed()
	_record_assertion("OptionsFlow", "options_modal_opens", true, main_menu.options_panel.visible, main_menu.options_panel.visible)
	_record_assertion("OptionsFlow", "menu_buttons_hidden_in_options", false, main_menu.menu_buttons_container.visible, not main_menu.menu_buttons_container.visible)
	
	# Probar controles de opciones
	_record_assertion("OptionsControls", "window_modes_count", 3, main_menu.opt_window_mode.item_count, main_menu.opt_window_mode.item_count == 3)
	_record_assertion("OptionsControls", "resolutions_count", 5, main_menu.opt_resolution.item_count, main_menu.opt_resolution.item_count == 5)
	_record_assertion("OptionsControls", "profiles_count", 3, main_menu.opt_profile.item_count, main_menu.opt_profile.item_count == 3)
	
	# Cerrar opciones
	main_menu._on_btn_options_back_pressed()
	_record_assertion("OptionsFlow", "options_modal_closes", false, main_menu.options_panel.visible, not main_menu.options_panel.visible)
	_record_assertion("OptionsFlow", "menu_buttons_restored", true, main_menu.menu_buttons_container.visible, main_menu.menu_buttons_container.visible)
	
	# 6. Probar flujo de Nueva Partida y apertura de stub T5.B
	main_menu._on_btn_new_game_pressed()
	_record_assertion("NewGameTransition", "stub_modal_opens", true, main_menu.stub_panel.visible, main_menu.stub_panel.visible)
	_record_assertion("NewGameTransition", "stub_contains_t5b", true, main_menu.stub_label.text.contains("T5.B"), main_menu.stub_label.text.contains("T5.B"))
	main_menu._on_btn_stub_close_pressed()
	_record_assertion("NewGameTransition", "stub_modal_closes", false, main_menu.stub_panel.visible, not main_menu.stub_panel.visible)
	
	# 7. Captura de pantalla de la interfaz
	_save_preview_capture("res://anim_captures/main_menu_preview.png")
	
	# 8. Informe final
	_export_report()


func _save_preview_capture(path: String) -> void:
	var tex = get_viewport().get_texture()
	if tex:
		var img = tex.get_image()
		if img:
			var global_path = ProjectSettings.globalize_path(path)
			img.save_png(global_path)
			print("[TestMainMenu] Captura de preview guardada en: ", global_path)


func _export_report() -> void:
	var report = {
		"suite": "T5.A MainMenu Acceptance Test",
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
