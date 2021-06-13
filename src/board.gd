extends Node2D


enum Turn { PLAYER, ENEMY }
onready var MAIN := get_parent().get_parent()


export var width := 8
export var height := 8

var selected_unit: Unit = null
var turn: int = Turn.PLAYER


func _input(event: InputEvent) -> void:
    if turn == Turn.ENEMY:
        return

    if event.is_action_released("click"):
        var clicked_board_position: Vector2 = to_board_position(to_local(event.position))
        if !is_in_board(clicked_board_position):
            return
        print("Board clicked: ", clicked_board_position)

        var unit := get_unit(clicked_board_position)
        var clicked_on_idle_unit: bool = unit != null and unit.state == Unit.State.IDLE
        var player_selected: bool = selected_unit != null and selected_unit.type == Unit.Type.PLAYER
        var using_skill: bool = player_selected and event.shift

        if clicked_on_idle_unit and not using_skill:
            select_unit(unit)
            $OverlayTileMap.clear()
            selected_unit.show_overlay()
        elif player_selected:
            var action: int = selected_unit.get_action_type() if using_skill else Action.Type.MOVE
            if selected_unit.try_do_action(action, clicked_board_position) == true:
                selected_unit.state = Unit.State.ACTION_DONE
                select_unit(null)
                $OverlayTileMap.clear()

    elif event.is_action_pressed("modifier_skill"):
        if selected_unit != null and selected_unit.type == Unit.Type.PLAYER:
            $OverlayTileMap.clear()
            selected_unit.show_skill_overlay(selected_unit.get_action_type())

    elif event.is_action_released("modifier_skill"):
        if selected_unit != null and selected_unit.type == Unit.Type.PLAYER:
            $OverlayTileMap.clear()
            selected_unit.show_overlay()
    
    elif event.is_action_pressed("end_turn"):
        end_player_turn()


func to_board_position(position: Vector2) -> Vector2:
    return $TileMap.world_to_map(position)


func to_local_position(board_position: Vector2) -> Vector2:
    return $TileMap.map_to_world(board_position) + Vector2(0, 32)


func is_in_board(board_position: Vector2) -> bool:
    return 0 <= board_position.x and board_position.x < width \
            and 0 <= board_position.y and board_position.y < height


func is_in_square(board_position: Vector2, square_center: Vector2, square_radius: int) -> bool:
    var center_to_position := board_position - square_center
    return abs(center_to_position.x) <= square_radius and abs(center_to_position.y) <= square_radius


func is_available(board_position: Vector2) -> bool:
    return get_player(board_position) == null and get_enemy(board_position) == null \
            and $TileMap.get_cellv(board_position) == 0


func get_action_type(board_position: Vector2) -> int:
    var index: int = $SkillsTileMap.get_cellv(board_position)
    return Action.Type.MOVE if index == TileMap.INVALID_CELL else index


func get_unit(board_position: Vector2) -> Unit:
    var units := $Players.get_children() + $Enemies.get_children()
    for unit in units:
        if to_board_position(unit.position) == board_position:
            return unit
    return null


func get_player(board_position: Vector2) -> Player:
    for player in $Players.get_children():
        if to_board_position(player.position) == board_position:
            return player
    return null


func get_enemy(board_position: Vector2) -> Enemy:
    for enemy in $Enemies.get_children():
        if to_board_position(enemy.position) == board_position:
            return enemy
    return null


func get_enemies_in_square(square_center: Vector2, square_radius: int) -> Array:
    var enemies := []
    for enemy in get_children():
        if is_in_square(to_board_position(enemy.position), square_center, square_radius):
            enemies.append(enemy)
    return enemies


func set_overlay(board_position: Vector2, overlay: int):
    $OverlayTileMap.set_cellv(board_position, overlay)


func set_overlay_in_square(
        square_center: Vector2, square_radius: int,
        overlay: int,
        only_set_available: bool = false):
    for x in range(-square_radius, square_radius + 1):
        for y in range(-square_radius, square_radius + 1):
            var v := Vector2(x, y)
            if v == Vector2.ZERO or !is_in_board(square_center + v):
                continue
            if only_set_available and !is_available(square_center + v):
                continue
            set_overlay(square_center + v, overlay)


func select_unit(unit: Unit) -> void:
    if selected_unit != null and selected_unit.state == Unit.State.SELECTED:
        selected_unit.state = Unit.State.IDLE
    selected_unit = unit
    MAIN.update_unit_hud(selected_unit)
    if selected_unit != null:
        selected_unit.state = Unit.State.SELECTED


func start_player_turn() -> void:
    for player in $Players.get_children():
        player.state = Unit.State.IDLE
    turn = Turn.PLAYER


func end_player_turn() -> void:
    select_unit(null)
    $OverlayTileMap.clear()
    turn = Turn.ENEMY
    $Enemies.do_turn()
