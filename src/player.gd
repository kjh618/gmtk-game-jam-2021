extends Area2D
class_name Player

enum State { IDLE, SELECTED }

enum ActionType {
    MOVE,
    SHORT_ATTACK,
    LONG_ATTACK,
    DEFEND,
    HEAL,
    BUFF_MOVES,
    MOVE_STRAIGHT,
}

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


func try_do_action(target_board_position: Vector2) -> bool:
    var action_type: int = BOARD.get_action_type(BOARD.to_board_position(position))
    print("Action type: ", action_type)
    match action_type:
        ActionType.MOVE:
            return try_move_to(target_board_position)
        ActionType.SHORT_ATTACK:
            if !Helper.is_in_square(target_board_position, short_attack_range):
                return false
            var enemies: Array = BOARD.get_enemies_in_square(target_board_position, short_attack_range)
            for enemy in enemies:
                enemy.health -= short_attack_damage
        ActionType.LONG_ATTACK:
            if !Helper.is_in_square(target_board_position, long_attack_range):
                return false
            var enemy: Enemy = BOARD.get_enemy(target_board_position)
            enemy.health -= long_attack_damage
        ActionType.DEFEND:
            defence += 10
        ActionType.HEAL:
            health += 10
        ActionType.BUFF_MOVES:
            return false
        ActionType.MOVE_STRAIGHT:
            return false
    return true


func try_move_to(board_position: Vector2) -> bool:
    var board_offset: Vector2 = board_position - BOARD.to_board_position(position)
    if !Helper.is_in_square(board_offset, max_move_distance):
        return false
    position = BOARD.to_local_position(board_position)
    return true
