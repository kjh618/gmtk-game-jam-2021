tool
extends Unit
class_name Enemy


enum EnemyType { STATIONARY, TANK, CANNON, RANDOM }

const MAX_HEALTH := {
    EnemyType.STATIONARY: 150,
    EnemyType.TANK: 200,
    EnemyType.CANNON: 100,
    EnemyType.RANDOM: 50,
}

const TANK_DAMAGE := 40

const CANNON_DAMAGE := 20

const RANDOM_MOVE_DISTANCE := 1

const TEXTURE_POSITION := {
    EnemyType.STATIONARY: Vector2(0, 0),
    EnemyType.TANK: Vector2(0, 1),
    EnemyType.CANNON: Vector2(0, 2),
    EnemyType.RANDOM: Vector2(0, 3),
}
const TEXTURE_WIDTH := 64
const TEXTURE_HEIGHT := 64


export var enemy_type: int = EnemyType.STATIONARY


func _ready() -> void:
    max_health = MAX_HEALTH[enemy_type]
    health = max_health
    $Sprite.texture = get_texture()


func get_texture() -> AtlasTexture:
    var texture := AtlasTexture.new()
    texture.atlas = preload("res://assets/enemy.png")
    var p: Vector2 = TEXTURE_POSITION[enemy_type]
    texture.region = Rect2(
            p.x * TEXTURE_WIDTH,
            p.y * TEXTURE_HEIGHT,
            TEXTURE_WIDTH,
            TEXTURE_HEIGHT)
    return texture


func get_description() -> String:
    match enemy_type:
        EnemyType.STATIONARY:
            return "Stay still"
        EnemyType.TANK:
            return "Move and attack in a line"
        EnemyType.CANNON:
            return "Attack the farthest player"
        EnemyType.RANDOM:
            return "Randomly wonder around"
        _:
            return ""


func show_overlay() -> void:
    print("Enemy show overlay")


func do_intent() -> void:
    var board_postion: Vector2 = BOARD.to_board_position(position)

    match enemy_type:
        EnemyType.STATIONARY:
            pass
        EnemyType.TANK:
            # TODO: Attack
            var target_board_position := board_postion + Vector2.DOWN
            if !BOARD.is_in_board(target_board_position):
                return
            if BOARD.is_available(target_board_position):
                move_to(target_board_position)
            else:
                var player: Unit = BOARD.get_player(target_board_position)
                if player == null:
                    return
                attack(player, TANK_DAMAGE, AttackAnimation.FIREBALL)
        EnemyType.CANNON:
            var max_distance := 0.0
            var max_distance_player: Unit = null
            for player in BOARD.get_node("Players").get_children():
                var player_board_position: Vector2 = BOARD.to_board_position(player.position)
                var distance := board_postion.distance_squared_to(player_board_position)
                if distance > max_distance:
                    max_distance = distance
                    max_distance_player = player
            if max_distance_player == null:
                return
            attack(max_distance_player, CANNON_DAMAGE, AttackAnimation.FIREBALL)
        EnemyType.RANDOM:
            var moves := []
            for x in range(-RANDOM_MOVE_DISTANCE, RANDOM_MOVE_DISTANCE + 1):
                for y in range(-RANDOM_MOVE_DISTANCE, RANDOM_MOVE_DISTANCE + 1):
                    var v := Vector2(x, y)
                    if v == Vector2.ZERO \
                            or !BOARD.is_in_board(board_postion + v) \
                            or !BOARD.is_available(board_postion + v):
                        continue
                    moves.append(v)
            if moves.empty():
                return
            var move: Vector2 = moves[randi() % moves.size()]
            move_to(board_postion + move)
