extends VBoxContainer


func set_info(enemy: Enemy) -> void:
    $VBoxContainer/IntentInfo.bbcode_text = enemy.get_description()
