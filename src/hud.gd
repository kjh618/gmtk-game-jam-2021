extends CanvasLayer


const PlayerInfo := preload("res://src/player_info.tscn")
const EnemyInfo := preload("res://src/enemy_info.tscn")


onready var SELECTED_UNIT_LABEL := $Panel/VBoxContainer/SelectedUnitLabel
onready var INFO_CONTAINER := $Panel/VBoxContainer/InfoContainer


var info: Node = null


func update_unit_hud(selected_unit: Unit) -> void:
    SELECTED_UNIT_LABEL.text = "Nothing selected"
    if info != null:
        INFO_CONTAINER.remove_child(info)
        info.queue_free()
        info = null

    if selected_unit == null:
        return

    match selected_unit.type:
        Unit.Type.PLAYER:
            SELECTED_UNIT_LABEL.text = "Player"
            info = PlayerInfo.instance()
            info.set_info(selected_unit)
        Unit.Type.ENEMY:
            SELECTED_UNIT_LABEL.text = "Enemy"
            info = EnemyInfo.instance()
            info.set_info(selected_unit)
    INFO_CONTAINER.add_child(info)
