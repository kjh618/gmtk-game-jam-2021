extends TileMap


onready var MAIN := get_node("/root/Main")


func do_turn() -> void:
    print("Enemy turn")
    yield(get_tree().create_timer(0.5), "timeout")

    for enemy in get_children():
        print("Select enemy")
        enemy.state = Unit.State.SELECTED
        MAIN.hud_update_unit_hud(enemy)
        yield(get_tree().create_timer(0.5), "timeout")

        print("Do intent: ", enemy.enemy_type)
        enemy.do_intent()
        yield(get_tree().create_timer(0.5), "timeout")

        enemy.state = Unit.State.ACTION_DONE

    print("End enemy turn")
    for enemy in get_children():
        enemy.state = Unit.State.IDLE
    MAIN.hud_update_unit_hud(null)
    get_parent().start_player_turn()
