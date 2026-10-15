extends Node

# InputManager.gd — Gestor abstracto de acciones y mapeo de controles (T4.9 / Fase 5)
# Define el InputMap estándar con soporte completo para teclado y mando/gamepad:
#   - Movimiento WASD / Flechas / Stick
#   - Ataque básico
#   - 6 SLOTS DE ACCIÓN:
#       1: Habilidad de Clase 1 (Tecla 1 / Mando LB)
#       2: Habilidad de Clase 2 (Tecla 2 / Mando RB)
#       3: Habilidad Elemental 1 (Tecla 3 / Mando LT)
#       4: Habilidad Elemental 2 (Tecla 4 / Mando RT)
#       5: Consumible HP (Tecla 5 o Q / Mando D-Pad Arriba)
#       6: Consumible SP/MP (Tecla 6 o R / Mando D-Pad Abajo)

func _ready() -> void:
	_setup_default_actions()
	print("[InputManager] Acciones de 6 Slots configuradas (Teclado + Mando)")


func _setup_default_actions() -> void:
	# 1. Movimiento Direccional
	_register_action("move_up", [
		_key(KEY_W), _key(KEY_UP),
		_joy_button(JOY_BUTTON_DPAD_UP),
		_joy_axis(JOY_AXIS_LEFT_Y, -1.0)
	], 0.2)
	
	_register_action("move_down", [
		_key(KEY_S), _key(KEY_DOWN),
		_joy_button(JOY_BUTTON_DPAD_DOWN),
		_joy_axis(JOY_AXIS_LEFT_Y, 1.0)
	], 0.2)
	
	_register_action("move_left", [
		_key(KEY_A), _key(KEY_LEFT),
		_joy_button(JOY_BUTTON_DPAD_LEFT),
		_joy_axis(JOY_AXIS_LEFT_X, -1.0)
	], 0.2)
	
	_register_action("move_right", [
		_key(KEY_D), _key(KEY_RIGHT),
		_joy_button(JOY_BUTTON_DPAD_RIGHT),
		_joy_axis(JOY_AXIS_LEFT_X, 1.0)
	], 0.2)
	
	# 2. Ataque Básico Melee
	_register_action("attack", [
		_key(KEY_SPACE), _key(KEY_J),
		_joy_button(JOY_BUTTON_X) # Botón X / Cuadrado
	])
	
	# 3. Los 6 Slots de Acción de Heroes Lore: Zero
	# Slot 1: Habilidad de Clase 1 (Golpe Brutal)
	_register_action("slot_1_skill", [
		_key(KEY_1),
		_joy_button(JOY_BUTTON_LEFT_SHOULDER) # LB / L1
	])
	
	# Slot 2: Habilidad de Clase 2 (Embestida)
	_register_action("slot_2_skill", [
		_key(KEY_2),
		_joy_button(JOY_BUTTON_RIGHT_SHOULDER) # RB / R1
	])
	
	# Slot 3: Habilidad Elemental 1 (Onda Ígnea)
	_register_action("slot_3_elem", [
		_key(KEY_3),
		_joy_button(JOY_BUTTON_DPAD_LEFT)
	])
	
	# Slot 4: Habilidad Elemental 2 (Rayo de Choque 360°)
	_register_action("slot_4_elem", [
		_key(KEY_4),
		_joy_button(JOY_BUTTON_DPAD_RIGHT)
	])
	
	# Slot 5: Poción de Recuperación HP
	_register_action("slot_5_item_hp", [
		_key(KEY_5), _key(KEY_Q),
		_joy_button(JOY_BUTTON_Y) # Botón Y / Triángulo
	])
	
	# Slot 6: Poción de Recuperación SP / MP
	_register_action("slot_6_item_mp", [
		_key(KEY_6), _key(KEY_R),
		_joy_button(JOY_BUTTON_B) # Botón B / Círculo
	])
	
	# 4. Interacción, Menú y Cancelar
	_register_action("interact", [
		_key(KEY_E), _key(KEY_ENTER),
		_joy_button(JOY_BUTTON_A) # Botón A / Cruz
	])
	
	_register_action("menu", [
		_key(KEY_ESCAPE), _key(KEY_P),
		_joy_button(JOY_BUTTON_START)
	])
	
	_register_action("cancel", [
		_key(KEY_ESCAPE), _key(KEY_BACKSPACE),
		_joy_button(JOY_BUTTON_B)
	])


func _register_action(action_name: String, events: Array, deadzone: float = 0.5) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, deadzone)
	else:
		InputMap.action_erase_events(action_name)
	for ev in events:
		if ev:
			InputMap.action_add_event(action_name, ev)


func _key(keycode: Key) -> InputEventKey:
	var ev = InputEventKey.new()
	ev.physical_keycode = keycode
	return ev


func _joy_button(btn: JoyButton) -> InputEventJoypadButton:
	var ev = InputEventJoypadButton.new()
	ev.button_index = btn
	return ev


func _joy_axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var ev = InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	return ev


func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")
