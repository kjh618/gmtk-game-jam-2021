extends GridContainer


func _ready() -> void:
    $SkillHBoxContainer.modulate = Color.darkgray


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("modifier_skill"):
        $MoveHBoxContainer.modulate = Color.darkgray
        $SkillHBoxContainer.modulate = Color.white
    elif event.is_action_released("modifier_skill"):
        $MoveHBoxContainer.modulate = Color.white
        $SkillHBoxContainer.modulate = Color.darkgray


func set_info(player: Player) -> void:
    $MoveHBoxContainer/MoveIcon.texture = Action.get_texture(Action.Type.MOVE)
    $MoveHBoxContainer/MoveInfo.bbcode_text = Action.get_description(Action.Type.MOVE, player.move_distance)

    var action_type: int = player.get_action_type()
    $SkillHBoxContainer/SkillIcon.texture = Action.get_texture(action_type)
    $SkillHBoxContainer/SkillInfo.bbcode_text = Action.get_description(action_type, player.move_distance)
