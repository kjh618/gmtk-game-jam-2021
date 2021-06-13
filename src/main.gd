extends Node


const LEVELS := [
    preload("res://src/level/level_test.tscn"),
    preload("res://src/level/level_test.tscn"),
]


var level: Node = null


func select_level(level_index: int) -> void:
    print("Select level: ", level_index)

    if level != null:
        level.queue_free()
        level = null

    level = LEVELS[level_index].instance()
    add_child(level)


func update_unit_hud(selected_unit: Unit) -> void:
    $Hud.update_unit_hud(selected_unit)
