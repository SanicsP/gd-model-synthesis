extends Propagator


class_name PropagatorAc3
var possibleLabels : Array = []
var inQueue : Array= []
var possibilitySize : Array = []
var size : Array = []
var offset : Array = []




func _init(new_settings : InputSettings , newPossibilitySize : Array , newOffset : Array).(new_settings) :
	settings = new_settings
	possibilitySize = newPossibilitySize
	offset = newOffset
	numLabels = settings.numLabels
	size = settings.size

	possibleLabels.resize(possibilitySize[0])

	inQueue.resize(possibilitySize[0])
	
	
	
	for x in possibilitySize[0] : 
	
		possibleLabels[x] = []
	
		possibleLabels[x].resize(possibilitySize[1])

		inQueue[x] = []
	
		inQueue[x].resize(possibilitySize[1])

		
		for y in possibilitySize[1] : 
			possibleLabels[x][y] = []
			possibleLabels[x][y].resize(possibilitySize[2])
			inQueue[x][y] = []
			inQueue[x][y].resize(possibilitySize[2])
			
			for z in possibilitySize[2] : 
				possibleLabels[x][y][z] = []
				possibleLabels[x][y][z].resize(numLabels)
	pass


func removeLabel(label : int , position : Array) -> bool : 
	var x : int = position[0]
	var y : int = position[1]
	var z : int = position[2]

	if possibleLabels[x][y][z][label] : 
		return true
	
	possibleLabels[x][y][z][label] = false
	inQueue[x][y][z] = true

	#TODO: Combine this with setBlockLabel.
	var updateQueue : deque = deque.new()
	updateQueue.addFront(position)
	inQueue[x][y][z] = true
	
	while updateQueue.size() : 
		var update : Array = updateQueue.front()
		var x_1 = update[0]
		var y_1 = update[1]
		var z_1 = update[2]

		#// TODO: Check if this makes things faster or not.
		#Check if any possible labels are still left.
		#If not we have failed.

		var is_Possible = false 
		for i in numLabels : 
			if possibleLabels[x_1][y_1][z_1][i] : 
				is_Possible = true
				break
		if not is_Possible : 
			return false 
		for dir in 6 : 
			updateQueue = propagate(x_1 , y_1 , z_1 , dir , updateQueue)
		inQueue[x_1][y_1][z_1] = false
		updateQueue.removeFront()

	return true

func setBlockLabel(label : int , position : Array) -> bool : 
	var x : int = position[0]
	var y : int = position[1]
	var z : int = position[2]

	for i in numLabels : 
		possibleLabels[x][y][z][i] = (i==label)
	
	var updateQueue : deque = deque.new()
	updateQueue.addFront(position)

	while updateQueue.size() > 0 : 
		var update : Array = updateQueue.front()
		var x_1 : int = update[0]
		var y_1 : int = update[1]
		var z_1 : int = update[2]

		var is_Possible : bool = false 
		for i in numLabels : 
			if possibleLabels[x_1][y_1][z_1][i] : 
				is_Possible = true
				break
		
		if not is_Possible : 
			return false
		
		for dir in 6 : 
			propagate(x_1,y_1,z_1 , dir , updateQueue)
		inQueue[x_1][y_1][z_1] = false
		updateQueue.removeFront()
	
	return true

	

func resetBlock() : 
	for x in possibilitySize[0] : 
		for y in possibilitySize[1] : 
			for z in possibilitySize[2] : 
				inQueue[x][y][z] = false
				for label in numLabels : 
					possibleLabels[x][y][z][label] = true

func isPossible(x : int , y :int , z : int , label : int) -> bool :
	return possibleLabels[x][y][z][label]

func propagate(xB : int , yB : int , zB : int , dir : int , updateQueue : deque) : 
	var transition : Array = settings.transition
	var xA : int = xB 
	var yA : int = yB
	var zA : int = zB
	 
	match dir : 
		0 : xA -= 1
		1 : xA += 1
		2 : yA -= 1
		3 : yA += 1
		4 : zA -= 1
		5 : zA += 1
	# Do not propagate if this goes outside the bounds of the block.

	if settings.periodic : 
		match dir : 
			0 : if xA < offset[0] : xA += size[0]
			2 : if yA < offset[1] : yA += size[1]
			4 : if zA <= offset[2] : return
			1 : if xA > possibilitySize[0] - offset[0] - 1 : xA -= size[0] 
			3 : if yA > possibilitySize[1] - offset[1] - 1 : yA -= size[1] 
			5 : if zA > possibilitySize[2] - offset[2] - 1 : return
	else : 
		match dir : 
			0 : if xB <= offset[0] : return
			2 : if yB <= offset[1] : return 
			4 : if zB <= offset[2] : return
			1 : if xB >= possibilitySize[0] - offset[0] - 1 : return 
			3 : if yB >= possibilitySize[1] - offset[1] - 1 : return 
			5 : if zB >= possibilitySize[2] - offset[2] - 1 : return

	var dim : int = dir /2 
	var positive = (dir % 2 == 1)
	for a in numLabels : 
		if possibleLabels[xA][yA][zA][a] : 
			var acceptable : bool = false 
			for b in numLabels : 
				var validTransition : bool = transition[dim][b][a] if positive else transition[dim][a][b]
				if validTransition and possibleLabels[xB][yB][zB][b] : 
					acceptable = true
					break
			if not acceptable : 
				possibleLabels[xA][yA][zA][a] = false
				if not inQueue[xA][yA][zA] : 
					var posA : Array = []
					posA.resize(3)
					posA[0] = xA
					posA[1] = yA
					posA[2] = zA
					updateQueue.addFront(posA)
	return updateQueue


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
