extends Unit
class_name Player


var move_distance := Action.MOVE_DISTANCE


func _init() -> void:
    type = Unit.Type.PLAYER


func show_overlay() -> void:
    print("Player show overlay")

    var board_position: Vector2 = BOARD.to_board_position(position)
    BOARD.set_overlay_in_square(board_position, move_distance, BoardOverlay.MOVE, true)


func show_skill_overlay(action_type: int) -> void:
    print("Player show skill overlay: ", action_type)

    var board_position: Vector2 = BOARD.to_board_position(position)
    match action_type:
        Action.Type.MOVE:
            show_overlay()
        Action.Type.MOVE_STRAIGHT:
            for x_or_y in [1, 0]:
                for d in range(-Action.MOVE_STRAIGHT_DISTANCE, Action.MOVE_STRAIGHT_DISTANCE + 1):
                    var v := Vector2(d * x_or_y, d * -(x_or_y - 1))
                    if v == Vector2.ZERO \
                            or !BOARD.is_in_board(board_position + v) \
                            or !BOARD.is_available(board_position + v):
                        continue
                    BOARD.set_overlay(board_position + v, BoardOverlay.MOVE)
        Action.Type.SHORT_ATTACK:
            BOARD.set_overlay_in_square(board_position, Action.SHORT_ATTACK_RANGE, BoardOverlay.ATTACK)
        Action.Type.LONG_ATTACK:
            BOARD.set_overlay_in_square(board_position, Action.LONG_ATTACK_RANGE, BoardOverlay.ATTACK)
        Action.Type.HEAL:
            BOARD.set_overlay(board_position, BoardOverlay.UTIL)
        Action.Type.BUFF_MOVES:
            for player in BOARD.get_node("Players").get_children():
                BOARD.set_overlay(BOARD.to_board_position(player.position), BoardOverlay.MOVE)


func move_to(target_board_position: Vector2):
    var board_position: Vector2 = BOARD.to_board_position(position)
    if BOARD.get_action_type(board_position) == Action.Type.BUFF_MOVES:
        for player in BOARD.get_node("Players").get_children():
            player.move_distance = Action.MOVE_DISTANCE

    .move_to(target_board_position)

    if BOARD.get_action_type(target_board_position) == Action.Type.BUFF_MOVES:
        for player in BOARD.get_node("Players").get_children():
            player.move_distance = Action.BUFF_MOVES_MOVE_DISTANCE


func get_action_type() -> int:
    var board_position: Vector2 = BOARD.to_board_position(position)
    return BOARD.get_action_type(board_position)


func try_do_action(action_type: int, target_board_position: Vector2) -> bool:
    print("Try do action: ", action_type)

    var board_position: Vector2 = BOARD.to_board_position(position)

    match action_type:
        Action.Type.MOVE:
            if !BOARD.is_in_square(target_board_position, board_position, move_distance) \
                    or !BOARD.is_available(target_board_position):
                return false
            move_to(target_board_position)

        Action.Type.MOVE_STRAIGHT:
            for x_or_y in [1, 0]:
                for d in range(-Action.MOVE_STRAIGHT_DISTANCE, Action.MOVE_STRAIGHT_DISTANCE + 1):
                    var v := Vector2(d * x_or_y, d * -(x_or_y - 1))
                    if v == Vector2.ZERO \
                            or !BOARD.is_in_board(board_position + v) \
                            or !BOARD.is_available(board_position + v):
                        continue
                    if target_board_position - board_position == v:
                        move_to(target_board_position)
                        return true
            return false

        Action.Type.SHORT_ATTACK:
            if !BOARD.is_in_square(target_board_position, board_position, Action.SHORT_ATTACK_RANGE):
                return false
            var enemy: Enemy = BOARD.get_enemy(target_board_position)
            if enemy == null:
                return false
            .attack(enemy, Action.SHORT_ATTACK_DAMAGE, AttackAnimation.FIREBALL)

        Action.Type.LONG_ATTACK:
            if !BOARD.is_in_square(target_board_position, board_position, Action.LONG_ATTACK_DAMAGE):
                return false
            var enemy: Enemy = BOARD.get_enemy(target_board_position)
            if enemy == null:
                return false
            .attack(enemy, Action.LONG_ATTACK_DAMAGE, AttackAnimation.LIGHTNING)

        Action.Type.HEAL:
            if target_board_position != board_position:
                return false
            self.health += Action.HEAL_AMOUNT

        Action.Type.BUFF_MOVES:
            return false

    return true
