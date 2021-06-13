extends CanvasLayer


const PlayerInfo := preload("res://src/hud/player_info.tscn")
const EnemyInfo := preload("res://src/hud/enemy_info.tscn")


const HELP_TEXTS := {
    "initial": "Your units can only use the skill marked on the tile they're standing on.\nClick on a unit to start.",
    "select": "Click on your idle unit to select it.\nOr press Space to end your turn.",
    "move": "Click on a green square to move. Or hold Shift to view skill overlay.\nEach unit can do only one action each turn.",
    "use_skill": "Shift + Click on a marked square to use skill.",
    "enemy_turn": "It's the enemy's turn now.",

    "error_not_in_range": "Not in range!",
    "error_action_done": "The clicked unit already did something this turn!"
}

onready var SELECTED_UNIT_LABEL := $Control/Panel/VBoxContainer/SelectedUnitLabel
onready var INFO_CONTAINER := $Control/Panel/VBoxContainer/InfoContainer


var info: Node = null


func _ready() -> void:
    $Control/SelectLevelButton.get_popup().connect("id_pressed", self, "_on_id_pressed")


func update_help_text(key: String, temporary_secs: float) -> void:
    if temporary_secs > 0.0:
        var original_text: String = $Control/HelpText.bbcode_text
        set_help_text(HELP_TEXTS[key])
        yield(get_tree().create_timer(temporary_secs), "timeout")
        $Control/HelpText.bbcode_text = original_text
    else:
        set_help_text(HELP_TEXTS[key])


func set_help_text(text: String) -> void:
    $Control/HelpText.bbcode_text = "[center][u]Help[/u]\n%s[/center]" % text


func update_unit_hud(selected_unit: Unit) -> void:
    SELECTED_UNIT_LABEL.text = "Nothing selected"
    if info != null:
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


func _on_id_pressed(id: int) -> void:
    get_parent().select_level(id)


func _on_EndTurnButton_pressed() -> void:
    get_parent().level.get_node("Board").end_player_turn()
