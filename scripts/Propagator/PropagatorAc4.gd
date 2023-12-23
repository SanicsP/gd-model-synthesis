extends Propagator

class_name PropagatorAc4

var possibleLabels : Array
var support : Array
var possibilitySize : Array
var offset : Array
var size : Array
var numDirections



func _init(newSettings : InputSettings , newPossibilitySize : Array , newOffset : Array ).(newSettings) :
	settings = newSettings 
	possibilitySize = newPossibilitySize
	offset = newOffset
	numLabels = settings.numLabels
	size = settings.size
	numDirections = 2 * settings.numDims

	possibleLabels = []
	possibleLabels.resize(possibilitySize[0])

	for x in possibilitySize[0] : 
		possibleLabels[x] = []
		possibleLabels[x].resize(possibilitySize[1])

		for y in possibilitySize[1] : 
			possibleLabels[x][y] = []
			possibleLabels[x][y].resize(possibilitySize[2])

			for z in possibilitySize[2] : 
				possibleLabels[x][y][z] = []
				possibleLabels[x][y][z].resize(numLabels)
	
	support = []
	support.resize(possibilitySize[0])

	for x in possibilitySize[0] : 
		support[x] = []
		support[x].resize(possibilitySize[1])
		for y in possibilitySize[1] : 
			support[x][y] = []
			support[x][y].resize(possibilitySize[2])
			for z in possibilitySize[2] : 
				support[x][y][z] = []
				support[x][y][z].resize(numLabels)
				for i in numLabels : 
					support[x][y][z][i] = []
					support[x][y][z][i].resize(numDirections)

func addToQueue(x : int , y : int , z : int , label : int , updateQueue : deque) : 
	var labeledPos : Array = []
	labeledPos.resize(4)

	labeledPos[0] = x
	labeledPos[1] = y
	labeledPos[2] = z
	labeledPos[3] = label
	updateQueue.addFront(labeledPos)

func propagate(updateQueue : deque) :
	while updateQueue.size() > 0 : 
		var update : Array = updateQueue.front()
		var xC : int = update[0]
		var yC : int = update[1]
		var zC : int = update[2]

		var cSupporting = settings.supporting[update[3]]

		for dir in numDirections : 
			var xB : int = xC
			var yB : int = yC
			var zB : int = zC

			match dir : 
				0 : xB -= 1 
				1 : xB += 1
				2 : yB -= 1
				3 : yB += 1
				4 : zB -= 1
				5 : zB += 1
			
			if settings.periodic : 
				match dir : 
					0 : if xB < offset[0] : xB += size[0]
					2 : if yB < offset[1] : yB += size[1]
					4 : if zB <= offset[2] : continue
					1 : if xB > possibilitySize[0] - offset[0] - 1 : xB -= size[0]
					3 : if yB > possibilitySize[1] - offset[1] - 1 : yB -= size[1] 
					5 : if zB > possibilitySize[2] - offset[2] - 1 : continue
			else : 
				match dir : 
					0: if xC <= offset[0] : continue
					2: if yC <= offset[1] : continue
					4: if zC <= offset[2] : continue
					1: if xC >= possibilitySize[0] - offset[0] - 1 : continue
					3: if yC >= possibilitySize[1] - offset[1] - 1 : continue
					5: if zC >= possibilitySize[2] - offset[2] - 1 : continue
			var dirSupporting : Array = cSupporting[dir]
			for i in len(dirSupporting) : 
				var b : int = dirSupporting[i]
				support[xB][yB][zB][b][dir] -= 1
				if support[xB][yB][zB][b][dir] == 0 and possibleLabels[xB][yB][zB][b]:
					possibleLabels[xB][yB][zB][b] = false
					addToQueue(xB , yB , zB , b , updateQueue)
		updateQueue.removeFront()

func setBlockLabel(label : int , position : Array ) -> bool :
	var updateQueue : deque = deque.new()
	var x : int = position[0]
	var y : int = position[1]
	var z : int = position[2]

	for i in numLabels : 
		if i != label and possibleLabels[x][y][z][i] : 
			var labeledPos : Array = []
			labeledPos.resize(4)
			possibleLabels[x][y][z][i] = false 
			labeledPos[0] = x
			labeledPos[1] = y
			labeledPos[2] = z
			labeledPos[i] = i
			updateQueue.addFront(labeledPos)
	propagate(updateQueue)
	return true 

func removeLabel(label : int , position : Array) -> bool : 
	var x = position[0]
	var y = position[1]
	var z = position[2]

	possibleLabels[x][y][z][label] = false
	
	var labeledPos : Array = []
	labeledPos.resize(4)
	
	labeledPos[0] = x
	labeledPos[1] = y
	labeledPos[2] = z
	labeledPos[3] = label
	
	var updateQueue : deque = deque.new()
	updateQueue.addFront(labeledPos)
	propagate(updateQueue)

	return true

func resetBlock() : 
	for x in possibilitySize[0] : 
		for y in possibilitySize[1] : 
			for z in possibilitySize[2] : 
				for label in  numLabels : 
					possibleLabels[x][y][z][label] = true
					for dir in numDirections : 
						support[x][y][z][label][dir] = settings.supportCount[label][dir]


func isPossible(x : int , y : int , z : int , label :int) : 
	return possibleLabels[x][y][z][label]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
