class_name Action


enum Type {
    MOVE,

    MOVE_STRAIGHT,

    SHORT_ATTACK,
    LONG_ATTACK,

    HEAL,
    BUFF_MOVES,
}

const MOVE_DISTANCE := 2

const MOVE_STRAIGHT_DISTANCE := 3

const SHORT_ATTACK_RANGE := 1
const SHORT_ATTACK_DAMAGE := 60

const LONG_ATTACK_RANGE := 4
const LONG_ATTACK_DAMAGE := 30

const HEAL_AMOUNT := 10

const BUFF_MOVES_MOVE_DISTANCE := 3

const TEXTURE_POSITION := {
    Type.MOVE: Vector2(0, 0),
    Type.MOVE_STRAIGHT: Vector2(1, 0),
    Type.SHORT_ATTACK: Vector2(0, 1),
    Type.LONG_ATTACK: Vector2(1, 1),
    Type.HEAL: Vector2(0, 2),
    Type.BUFF_MOVES: Vector2(1, 2),
}
const TEXTURE_WIDTH := 128
const TEXTURE_HEIGHT := 64
const TEXTURE_PADDING_X := 32
const TEXTURE_PADDING_Y := 16


static func get_texture(action_type: int) -> AtlasTexture:
    var texture := AtlasTexture.new()
    texture.atlas = preload("res://assets/actions.png")
    var p: Vector2 = TEXTURE_POSITION[action_type]
    texture.region = Rect2(
            p.x * TEXTURE_WIDTH + TEXTURE_PADDING_X,
            p.y * TEXTURE_HEIGHT + TEXTURE_PADDING_Y,
            TEXTURE_WIDTH - TEXTURE_PADDING_X * 2,
            TEXTURE_HEIGHT - TEXTURE_PADDING_Y * 2)
    print(texture.region)
    return texture


static func get_description(action_type: int) -> String:
    match action_type:
        Type.MOVE:
            return "Move %d" % MOVE_DISTANCE
        Type.MOVE_STRAIGHT:
            return "Move straight %d" % MOVE_STRAIGHT_DISTANCE
        Type.SHORT_ATTACK:
            return "Attack %d" % SHORT_ATTACK_DAMAGE
        Type.LONG_ATTACK:
            return "Attack %d" % LONG_ATTACK_DAMAGE
        Type.HEAL:
            return "Heal %d" % HEAL_AMOUNT
        Type.BUFF_MOVES:
            return "Buff moves to %d" % BUFF_MOVES_MOVE_DISTANCE
        _:
            return ""
