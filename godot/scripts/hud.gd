class_name GameHUD
extends CanvasLayer

# hud.gd — Interfaz de usuario (HUD) para el Vertical Slice de Heroes Lore: Zero (T5.4, T5.5)

signal dialogue_advanced()
signal dialogue_closed()

@onready var hp_bar: ProgressBar = $StatusPanel/VBox/HPContainer/HPBar
@onready var hp_label: Label = $StatusPanel/VBox/HPContainer/HPLabel
@onready var mp_bar: ProgressBar = $StatusPanel/VBox/MPContainer/MPBar
@onready var mp_label: Label = $StatusPanel/VBox/MPContainer/MPLabel
@onready var exp_bar: ProgressBar = $StatusPanel/VBox/EXPBar
@onready var name_label: Label = $StatusPanel/VBox/NameLabel
@onready var potion_badge: Label = $QuickSlots/PotionSlot/CountBadge

@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Margin/VBox/SpeakerLabel
@onready var dialogue_text: Label = $DialoguePanel/Margin/VBox/DialogueText
@onready var prompt_next: Label = $DialoguePanel/Margin/VBox/PromptNext

var is_dialogue_active: bool = false
var current_dialogue_lines: Array[String] = []
var current_line_idx: int = 0


func _ready() -> void:
	dialogue_panel.visible = false
	prompt_next.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if is_dialogue_active:
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			advance_dialogue()
			get_viewport().set_input_as_handled()


func update_hp(current: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current
	hp_label.text = "%d / %d" % [current, max_hp]


func update_mp(current: int, max_mp: int) -> void:
	mp_bar.max_value = max_mp
	mp_bar.value = current
	mp_label.text = "%d / %d" % [current, max_mp]


func update_exp(current: int, next: int) -> void:
	exp_bar.max_value = next
	exp_bar.value = current


func update_level(lvl: int, character_name: String = "Lucian") -> void:
	name_label.text = "%s (Nv. %d · Guerrero)" % [character_name, lvl]


func update_potion_count(count: int) -> void:
	potion_badge.text = "x%d" % count


## Abre la ventana de diálogo
func start_dialogue(speaker: String, lines: Array[String]) -> void:
	if lines.is_empty():
		return
		
	is_dialogue_active = true
	current_dialogue_lines = lines
	current_line_idx = 0
	speaker_label.text = speaker
	dialogue_panel.visible = true
	_show_current_line()


func _show_current_line() -> void:
	if current_line_idx < current_dialogue_lines.size():
		dialogue_text.text = current_dialogue_lines[current_line_idx]
	else:
		close_dialogue()


func advance_dialogue() -> void:
	current_line_idx += 1
	if current_line_idx >= current_dialogue_lines.size():
		close_dialogue()
	else:
		_show_current_line()
		emit_signal("dialogue_advanced")


func close_dialogue() -> void:
	is_dialogue_active = false
	dialogue_panel.visible = false
	emit_signal("dialogue_closed")
