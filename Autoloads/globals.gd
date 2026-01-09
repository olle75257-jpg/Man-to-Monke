extends Node

var camera

@export_enum("Modern", "Medieval", "StoneAge", "Monke") var era: String = "Modern"

var kills: int = 0
var finished_era: bool = false
