extends GridMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print(len(get_used_cells()))
	for x in 9 : 
		for y in 1 : 
			for z in 7 :
				print(get_cell_item(x,y,z))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
