extends Node


const LEVELS := [
    preload("res://src/level/level_0.tscn"),
    preload("res://src/level/level_1.tscn"),
    preload("res://src/level/level_2.tscn"),
    preload("res://src/level/level_3.tscn"),
    preload("res://src/level/level_4.tscn"),
]


var level_index: int = -1
var level: Node = null


func _ready() -> void:
    select_level(0)


func select_level(new_level_index: int) -> void:
    level_index = new_level_index
    print("Select level: ", level_index)

    $Hud/Control/SelectLevelButton.text = "Level %d" % level_index

    if level != null:
        level.queue_free()
        level = null

    level = LEVELS[level_index].instance()
    add_child(level)


func try_next_level() -> bool:
    if level_index + 1 >= LEVELS.size():
        return false

    select_level(level_index + 1)
    return true


func hud_update_help_text(key: String, temporary_secs: float = 0.0) -> void:
    $Hud.update_help_text(key, temporary_secs)


func hud_update_unit_hud(selected_unit: Unit) -> void:
    $Hud.update_unit_hud(selected_unit)


func hud_end_turn_button_set_disabled(disabled: bool) -> void:
    $Hud/Control/Panel/VBoxContainer/EndTurnButton.disabled = disabled
