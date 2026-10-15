extends Node

# InputManager.gd — Gestor abstracto de acciones y mapeo de controles (T4.9)
# Define el InputMap estándar con soporte completo para teclado y mando/gamepad.

func _ready() -> void:
	_setup_default_actions()
	print("[InputManager] Acciones de InputMap configuradas (Teclado + Mando)")


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
	
	# 2. Acciones de Combate
	_register_action("attack", [
		_key(KEY_SPACE), _key(KEY_J),
		_joy_button(JOY_BUTTON_A) # Botón Sur / Cruz en PlayStation
	])
	
	_register_action("skill_1", [
		_key(KEY_1), _key(KEY_Q),
		_joy_button(JOY_BUTTON_X) # Botón Oeste / Cuadrado
	])
	
	_register_action("skill_2", [
		_key(KEY_2), _key(KEY_E),
		_joy_button(JOY_BUTTON_Y) # Botón Norte / Triángulo
	])
	
	_register_action("skill_3", [
		_key(KEY_3), _key(KEY_R),
		_joy_button(JOY_BUTTON_B) # Botón Este / Círculo
	])
	
	_register_action("skill_4", [
		_key(KEY_4), _key(KEY_F),
		_joy_button(JOY_BUTTON_LEFT_SHOULDER) # LB / L1
	])
	
	# 3. Interacción, Pociones y Menú
	_register_action("quick_item", [
		_key(KEY_C), _key(KEY_TAB),
		_joy_button(JOY_BUTTON_RIGHT_SHOULDER) # RB / R1
	])
	
	_register_action("interact", [
		_key(KEY_ENTER), _key(KEY_E), _key(KEY_SPACE),
		_joy_button(JOY_BUTTON_A)
	])
	
	_register_action("menu", [
		_key(KEY_ESCAPE), _key(KEY_P),
		_joy_button(JOY_BUTTON_START)
	])
	
	_register_action("map", [
		_key(KEY_M),
		_joy_button(JOY_BUTTON_BACK)
	])
	
	_register_action("cancel", [
		_key(KEY_ESCAPE), _key(KEY_BACKSPACE),
		_joy_button(JOY_BUTTON_B)
	])


## Registra una acción en InputMap si no existe o la actualiza
func _register_action(action_name: String, events: Array, deadzone: float = 0.5) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, deadzone)
	for ev in events:
		if ev:
			InputMap.action_add_event(action_name, ev)


## Crea un evento de tecla
func _key(keycode: Key) -> InputEventKey:
	var ev = InputEventKey.new()
	ev.physical_keycode = keycode
	return ev


## Crea un evento de botón de mando
func _joy_button(btn: JoyButton) -> InputEventJoypadButton:
	var ev = InputEventJoypadButton.new()
	ev.button_index = btn
	return ev


## Crea un evento de eje de stick analógico
func _joy_axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var ev = InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	return ev


## Devuelve el vector de movimiento normalizado de la entrada actual
func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")
