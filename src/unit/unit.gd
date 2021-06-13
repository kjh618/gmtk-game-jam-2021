extends Area2D
class_name Unit


enum Type { PLAYER, ENEMY }

enum State { IDLE, SELECTED, ACTION_DONE }

enum BoardOverlay { MOVE, ATTACK, UTIL }

enum AttackAnimation { FIREBALL, LIGHTNING }

const ATTACK_ANIMATIONS := [
    preload("res://src/unit/fireball.tscn"),
    preload("res://src/unit/lightning.tscn"),
]

onready var BOARD := get_parent().get_parent()


var max_health := 100
var health = max_health setget set_health
var type: int = Type.ENEMY
var state: int = State.IDLE setget set_state


func set_health(new_health: int) -> void:
    health = new_health
    $HealthBar.value = health as float / max_health * 100
    if (health < 0):
        queue_free()


func set_state(new_state: int) -> void:
    state = new_state
    match state:
        State.IDLE:
            $Sprite.modulate = Color.white
        State.SELECTED:
            $Sprite.modulate = Color.blue
        State.ACTION_DONE:
            $Sprite.modulate = Color.darkgray


func show_overlay() -> void:
    pass


func move_to(target_board_position: Vector2) -> void:
    position = BOARD.to_local_position(target_board_position)


func attack(unit: Unit, damage: int, animation_index: int) -> void:
    var animation: Node = ATTACK_ANIMATIONS[animation_index].instance()
    unit.add_child(animation)
    yield(animation.get_node("AnimationPlayer"), "animation_finished")
    unit.health -= damage
