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

onready var BOARD := get_parent()


export var max_move_distance := 2
export var short_attack_range := 1
export var short_attack_damage := 60
export var long_attack_range := 4
export var long_attack_damage := 30

export var health := 100
export var defence := 0
var state: int = State.IDLE setget set_state


func set_state(new_state: int) -> void:
    state = new_state
    match state:
        State.IDLE:
            $Sprite.modulate = Color.white
        State.SELECTED:
            $Sprite.modulate = Color.green


func show_overlay():
    var board_position: Vector2 = BOARD.to_board_position(position)
    var action_type: int = BOARD.get_action_type(board_position)
    print("Show overlay: ", action_type)

    match action_type:
        ActionType.MOVE:
            show_move_overlay(board_position)
        ActionType.SHORT_ATTACK:
            BOARD.set_overlay_in_square(board_position, short_attack_range, BoardOverlay.ATTACK)
        ActionType.LONG_ATTACK:
            BOARD.set_overlay_in_square(board_position, long_attack_range, BoardOverlay.ATTACK)
        ActionType.DEFEND:
            return
        ActionType.HEAL:
            return
        ActionType.MOVE_STRAIGHT:
            return
        ActionType.BUFF_MOVES:
            return


func show_move_overlay(board_position: Vector2 = BOARD.to_board_position(position)):
    print("Show move overlay")
    BOARD.set_overlay_in_square(board_position, max_move_distance, BoardOverlay.MOVE)


func try_do_action(target_board_position: Vector2) -> bool:
    var board_position: Vector2 = BOARD.to_board_position(position)
    var action_type: int = BOARD.get_action_type(board_position)
    print("Try do action: ", action_type)

    match action_type:
        ActionType.MOVE:
            return try_move(target_board_position)
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
            defence += 10
        ActionType.HEAL:
            health += 10
        ActionType.MOVE_STRAIGHT:
            return false
        ActionType.BUFF_MOVES:
            return false
    return true


func try_move(target_board_position: Vector2) -> bool:
    var board_position: Vector2 = BOARD.to_board_position(position)
    print("Try move: ", board_position, " -> ", target_board_position)

    if !BOARD.is_in_square(target_board_position, board_position, max_move_distance):
        return false

    position = BOARD.to_local_position(target_board_position)
    return true
