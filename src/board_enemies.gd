extends Node2D


func do_turn() -> void:
    print("Enemy turn")
    # TODO
    yield(get_tree().create_timer(0.1), "timeout")
    print("End enemy turn")
    get_parent().start_player_turn()
