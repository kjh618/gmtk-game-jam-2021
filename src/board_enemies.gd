extends Node2D


func do_turn() -> void:
    print("Enemy turn")
    for enemy in get_children():
        print("Do intent: ", enemy.enemy_type)
        enemy.do_intent()
        yield(get_tree().create_timer(0.5), "timeout")
    print("End enemy turn")
    get_parent().start_player_turn()
