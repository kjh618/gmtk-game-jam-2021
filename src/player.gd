extends Area2D
class_name Player

enum State { IDLE, SELECTED, ACTION_DONE }

enum ActionType {
    MOVE,
    SHORT_ATTACK,
    LONG_ATTACK,
    DEFEND,
    HEAL,
    MOVE_STRAIGHT,
    BUFF_MOVES,
}

enum BoardOverlay { MOVE, ATTACK, DEFENCE }

onready var BOARD := get_parent().get_parent()


export var max_move_distance := 2
export var short_attack_range := 1
export var short_attack_damage := 60
export var long_attack_range := 4
export var long_attack_damage := 30
export var defend_amount := 10
export var heal_amount := 10
export var move_straight_distance := 3
export var buff_moves_distance := 3

export var health := 100 setget set_health
export var defence := 0
var state: int = State.IDLE setget set_state


func set_health(new_health: int) -> void:
    health = new_health
    $HealthBar.value = health
    if (health < 0):
        queue_free()


func set_state(new_state: int) -> void:
    state = new_state
    match state:
        State.IDLE:
            $Sprite.modulate = Color.white
        State.SELECTED:
            $Sprite.modulate = Color.green
        State.ACTION_DONE:
            $Sprite.modulate = Color.gray


func show_overlay(action_type: int):
    print("Show overlay: ", action_type)

    var board_position: Vector2 = BOARD.to_board_position(position)
    match action_type:
        ActionType.MOVE:
            BOARD.set_overlay_in_square(board_position, max_move_distance, BoardOverlay.MOVE, true)
        ActionType.SHORT_ATTACK:
            BOARD.set_overlay_in_square(board_position, short_attack_range, BoardOverlay.ATTACK)
        ActionType.LONG_ATTACK:
            BOARD.set_overlay_in_square(board_position, long_attack_range, BoardOverlay.ATTACK)
        ActionType.DEFEND:
            BOARD.set_overlay(board_position, BoardOverlay.DEFENCE)
        ActionType.HEAL:
            BOARD.set_overlay(board_position, BoardOverlay.DEFENCE)
        ActionType.MOVE_STRAIGHT:
            for x_or_y in [1, 0]:
                for d in range(-move_straight_distance, move_straight_distance + 1):
                    var v := Vector2(d * x_or_y, d * -(x_or_y - 1))
                    if v == Vector2.ZERO \
                            or !BOARD.is_in_board(board_position + v) \
                            or !BOARD.is_available(board_position + v):
                        continue
                    BOARD.set_overlay(board_position + v, BoardOverlay.MOVE)
        ActionType.BUFF_MOVES:
            for player in BOARD.get_node("Players").get_children():
                BOARD.set_overlay(BOARD.to_board_position(player.position), BoardOverlay.MOVE)


func try_do_action(action_type: int, target_board_position: Vector2) -> bool:
    print("Try do action: ", action_type)

    var board_position: Vector2 = BOARD.to_board_position(position)

    match action_type:
        ActionType.MOVE:
            if !BOARD.is_in_square(target_board_position, board_position, max_move_distance) \
                    or !BOARD.is_available(target_board_position):
                return false
            move_to(target_board_position)

        ActionType.SHORT_ATTACK:
            if !BOARD.is_in_square(target_board_position, board_position, short_attack_range):
                return false
            var enemy: Enemy = BOARD.get_enemy(target_board_position)
            if enemy == null:
                return false
            enemy.health -= short_attack_damage

        ActionType.LONG_ATTACK:
            if !BOARD.is_in_square(target_board_position, board_position, long_attack_range):
                return false
            var enemy: Enemy = BOARD.get_enemy(target_board_position)
            if enemy == null:
                return false
            enemy.health -= long_attack_damage

        ActionType.DEFEND:
            if target_board_position != board_position:
                return false
            defence += defend_amount

        ActionType.HEAL:
            if target_board_position != board_position:
                return false
            self.health += heal_amount

        ActionType.MOVE_STRAIGHT:
            for x_or_y in [1, 0]:
                for d in range(-move_straight_distance, move_straight_distance + 1):
                    var v := Vector2(d * x_or_y, d * -(x_or_y - 1))
                    if v == Vector2.ZERO \
                            or !BOARD.is_in_board(board_position + v) \
                            or !BOARD.is_available(board_position + v):
                        continue
                    if target_board_position - board_position == v:
                        move_to(target_board_position)
                        return true
            return false

        ActionType.BUFF_MOVES:
            return false

    return true


func move_to(target_board_position: Vector2):
    var board_position: Vector2 = BOARD.to_board_position(position)
    if BOARD.get_action_type(board_position) == ActionType.BUFF_MOVES:
        for player in BOARD.get_node("Players").get_children():
            player.max_move_distance = 2 # TODO

    position = BOARD.to_local_position(target_board_position)

    if BOARD.get_action_type(target_board_position) == ActionType.BUFF_MOVES:
        for player in BOARD.get_node("Players").get_children():
            player.max_move_distance = buff_moves_distance
