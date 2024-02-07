extends Node2D

## Test world script

func temp_spawn_girder(holes, pos):
	var girder = Girder.new(holes)
	add_child(girder)
	girder.global_position = pos


func _ready():
	
	temp_spawn_girder([[Girder.HOLE_TYPE.PIN, Girder.HOLE_TYPE.PIN],[Girder.HOLE_TYPE.NONE, Girder.HOLE_TYPE.PIN]], Vector2(200, 900))
	temp_spawn_girder([[Girder.HOLE_TYPE.PIN, Girder.HOLE_TYPE.PIN, Girder.HOLE_TYPE.PIN, Girder.HOLE_TYPE.PIN]], Vector2(500, 900))
