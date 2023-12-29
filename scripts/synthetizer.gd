extends Object

class_name Synthetizer

var model : Array
var savedBlock : Array
var settings : InputSettings
var size : Array
var blockSize : Array
var offset : Array
var numLabels : int 
var numDirections : int 

var numAttemps = 20

#propagate the set of possible labels
var propagator : Propagator




func _init(newSettings : InputSettings  , synthesisTimeMicro=0 ):
	settings = newSettings
	size = settings.size
	blockSize = settings.block_size
	numLabels = settings.numLabels
	offset = []
	offset.resize(3)

	for dim in 3 : 
		if size[dim] > blockSize[dim] :
			offset[dim] = 1
		else : 
			offset[dim] = 0
	
	var possibilitySize = []
	possibilitySize.resize(3)
	for dim in 3 : 
		if blockSize[dim] == size[dim] : 
			possibilitySize[dim] = size[dim]
		else : 
			# Add one cell border to each side of the block if we are modifying in blocks
			possibilitySize[dim] = blockSize[dim]+2
	
	if settings.useAc4 :
		propagator = PropagatorAc4.new(newSettings,possibilitySize,offset)
	else : 
		propagator = PropagatorAc3.new(newSettings , possibilitySize,offset)
	
	#Create the model with the initial labels.
	
	model = []
	model.resize(size[0])

	for x in size[0] : 
		model[x] = [] 
		model[x].resize(size[1])
		for y in size[1] : 
			model[x][y] = []
			model[x][y].resize(size[2])
	
	var savedBlock : Array = []
	savedBlock.resize(possibilitySize[0])
	for x in possibilitySize[0]: 
		savedBlock[x] = []
		savedBlock[x].resize(possibilitySize[1])
		for y in possibilitySize[1] : 
			savedBlock[x][y] = []
			savedBlock[x][y].resize(possibilitySize[2])

func getModel() -> Array : 
	return model

func setupStepValues(dim : int , step : int , shifts : Array , maxBlockStart : Array , hasBoundary : Array) -> int :
	var value : int = step*shifts[dim]
	hasBoundary[2*dim] = (step > 0)

	if value >= maxBlockStart[dim] : 
		value = maxBlockStart[dim] 
		hasBoundary[2*dim + 1] = false 
	else : 
		hasBoundary [2*dim +1] = true
	return value

enum PrintMode {NONE , TEXT , NEW_LINE}

func printIteration(blockStart : int , printMode, indentation : int , varName : String) :
	if printMode == PrintMode.NEW_LINE :
		for i in indentation : 
			print(" ") 
		print("\n" , varName , "=" , blockStart)
	
	elif printMode == PrintMode.TEXT : 
		if blockStart == 0 : 
			for i in indentation : 
				print(" ")
			print(varName,"=",blockStart)
	else : 
		print(" ")

func synthesize(synthesizeTimeMicro : float) :

	#Set the initial labels.
	for x in size[0] : 
		for y in size[1] : 
			for z in size[2] : 
				model[x][y][z] = settings.initial_labels[z]
	
	# At each step, we shift the block by half the width of the block.
	# Calculate how many steps are needed.
	
	var shifts : Array = []
	shifts.resize(3)
	var numSteps : Array = []
	numSteps.resize(3)
	var maxBlockStart : Array = []
	maxBlockStart.resize(3)
	var blockStart : Array = []
	blockStart.resize(3)

	for dim in 3 :
		shifts[dim] = max(blockSize[dim]/2 , 1)
		numSteps[dim]  = int(ceil((size[dim]-blockSize[dim]) / (float(shifts[dim])))) + 1
		maxBlockStart[dim] = size[dim] - blockSize[dim]
	
	# Logic for how to print the iterations.

	var printMode : Array = []
	printMode.resize(3)
	var indentation : Array = []
	indentation.resize(3)
	var indent : int = 0
	var lastPrint : int = -1

	for dim in 3 : 
		indentation[dim] = indent
		if numSteps[dim] > 1 : 
			printMode[dim] = PrintMode.NEW_LINE
			lastPrint = dim 
			indent += 1
		else : 
			printMode[dim] = PrintMode.NONE
	
	if lastPrint >= 0 : 
		printMode[lastPrint] = PrintMode.TEXT
	
	print("printMode : " , printMode)
	var blocks : int = 0

	var modifyInBlocks : bool = (lastPrint >= 0)

	#Whether or not we should fill in the boundary values. We do not do 
	#this if they would be outside the model. This is for the boundary
	#in six directions: -X, +X, -Y, +Y, -Z, +Z.

	var hasBoundary : Array = []
	hasBoundary.resize(6)
	
	print("solving")
	
	for xStep in numSteps[0] : 
		blockStart[0] = setupStepValues(0 , xStep , shifts , maxBlockStart , hasBoundary)
		printIteration(blockStart[0] , printMode[0] , indentation[0] , "x")
		for yStep in numSteps[1] : 
			blockStart[1] = setupStepValues(1 , yStep , shifts , maxBlockStart , hasBoundary)
			printIteration(blockStart[1] , printMode[1] , indentation[1] , "y")
			
			for zStep in numSteps[2] : 
				blockStart[2] = setupStepValues(2 , zStep , shifts , maxBlockStart , hasBoundary)
				printIteration(blockStart[2] , printMode[2] , indentation[2] , "z")

				if size[2] > 1 : 
					hasBoundary[4] = true
					hasBoundary[5] = true
				var succes : bool = false 
				var attemps : int = 0
				if (modifyInBlocks) : 
					saveBlock(blockStart)
					pass
				while not succes and attemps < numAttemps :
					succes = synthesizeBlock(blockStart , hasBoundary) 				
					attemps += 1

					if not succes : 
						if attemps < numAttemps : 
							if lastPrint == -1 : 
								print("failled .Retrying")
						else : 
							if modifyInBlocks : 
								restoreBlock(blockStart)
								pass
							print("Failled. Max Attemps")
	if lastPrint >= 0 : 
		print("end")

func getLabel( position : Array) : 
	return model[position[0]][position[1]][position[2]]

func addBoundary(blockStart : Array , dir : int) :
	var dim0 : int = dir /2 
	var dim1 : int =  -1
	var dim2 : int = -1

	match dim0 : 
		0 : 
			dim1 = 1 
			dim2 = 2
		1 : 
			dim1 = 0 
			dim2 = 2
		2 : 
			dim1 = 0
			dim2 = 1
	var blockPos : Array = []
	blockPos.resize(3)
	var modelPos : Array = []
	modelPos.resize(3)

	if dir % 2 : 
		blockPos[dim0] = blockSize[dim0] - 1 + offset[dim0]
	else : 
		blockPos[dim0] = 0
	
	modelPos[dim0] = blockPos[dim0] + blockStart[dim0] - offset[dim0]

	for i in range(offset[dim1] , blockSize[dim1]+offset[dim1]) : 
		blockPos[dim1] = i 
		modelPos[dim1] = i + blockStart[dim1] - offset[dim1]
		
		for j in range(offset[dim2],blockSize[dim2] + offset[dim2]) : 
			blockPos[dim2] = j
			modelPos[dim2] = j + blockStart[dim2] - offset[dim2]
			propagator.setBlockLabel(getLabel(modelPos) , blockPos)

func addGround(blockStart : Array) : 
	if blockSize[1] - offset[1] + blockStart[1] + offset[1] == size[1] : 
		var position : Array = []
		position.resize(3)

		position[2] = 0

		for x in range(offset[0] , blockSize[0]+offset[0]) : 
			position[0] = x
			for y in range(offset[1], blockSize[1]+ offset[1]) : 
				position[1] = y
				if y == blockSize[1] - 1 : 
					propagator.setBlockLabel(settings.ground , position)
				elif propagator.isPossible(x , y , 0 , settings.ground) : 
					propagator.removeLabel(settings.ground , position)


func removeNoSupport(blockStart : Array) : 
	var numDirections : int = 2 * settings.numDims
	var udateQueue : deque = deque.new()

	for i in numLabels : 
		for dir in numDirections : 
			if settings.supportCount[i][dir] == 0 : 
				var position : Array = []
				position.resize(3)
				for x in range(offset[0] , blockSize[0] + offset[0]) : 
					position[0] = x
					for y in range(offset[1] , blockSize[1] + offset[1]) : 
						position[1] = y
						for z in range(offset[2] , blockSize[2] + offset[2]) : 
							position[2] = z 
							var remove : bool = false 
							match dir : 
								0 : remove = x + blockStart[0] - offset[0] != size[0] - 1
								1: remove = x + blockStart[0] - offset[0] != 0
								2: remove = y + blockStart[1] - offset[1] != size[1] - 1
								3: remove = y + blockStart[1] - offset[1] != 0
								4: remove = z + blockStart[2] - offset[2] != size[2] - 1
								5: remove = z + blockStart[2] - offset[2] != 0
							
							if remove and propagator.isPossible(x , y , z , i) : 
								propagator.removeLabel(i , position)


func saveBlock(blockStart : Array) : 
	for x in range(offset[0] , blockSize[0] + offset[0]) : 
		for y in range(offset[1], blockSize[1] + offset[1]) : 
			for z in range(offset[2] , blockSize[2] + offset[2]) : 
				savedBlock[x][y][z] = model[x+blockStart[0] - offset[0]][y+blockStart[1] - offset[1]][z+blockStart[2] - offset[2]]

func restoreBlock(blockStart : Array) : 
	for x in range(offset[0] , blockSize[0] + offset[0]) :
		for y in range(offset[1] , blockSize[1] + offset[1]) :
			for z in range(offset[2] , blockSize[2] + offset[2]) :
				model[x+blockStart[0] - offset[0]][y+blockStart[1]-offset[1]][z+blockStart[2]-offset[2]] = savedBlock[x][y][z]
				
				
func synthesizeBlock(blockStart : Array , hasBoundary :Array) -> bool: 
	propagator.resetBlock()

	for dir in 6 : 
		if hasBoundary[dir] :
			addBoundary(blockStart , dir)
	
	if settings.ground >= 0 :
		addGround(blockStart)

	if settings.useAc4 : 
		removeNoSupport(blockStart)

	for x in range(offset[0] , blockSize[0] + offset[0]) : 
		for y in range(offset[1] , blockSize[1] + offset[1]) : 
			for z in range(offset[2] , blockSize[2] + offset[2]) : 
				var label : int = propagator.pickLabel(x , y , z)

				if label == - 1 :
					print("contradiction") 
					return false  
				model[x + blockStart[0] - offset[0]][y + blockStart[1] - offset[1]][z + blockStart[2] - offset[2]] = label
	
	return true

func printModel() : 
	print("--------------------------------------")
	print("Model")

	for z in size[2] : 
		for y in size[1] : 
			for x in size[0] : 
				printraw(model[x][y][z] , "")
			print("\n")
		print("\n")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
