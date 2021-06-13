extends Area2D
class_name Unit


enum Type { PLAYER, ENEMY }
enum State { IDLE, SELECTED, ACTION_DONE }
enum BoardOverlay { MOVE, ATTACK, UTIL }
onready var BOARD := get_parent().get_parent()


export var health := 100 setget set_health

var type: int = Type.ENEMY
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


func show_overlay() -> void:
    pass


func move_to(target_board_position: Vector2) -> void:
    position = BOARD.to_local_position(target_board_position)


func attack(unit: Unit, damage: int) -> void:
    unit.health -= damage
