extends Object


class_name utils


static func make2dArray(x,y,value) :
	var array : Array = []
	for i in x : 
		array.append([])
		for j in y : 
			array[x].append(value)
	return array

static func make3dArray(x,y,z,value) : 
	var array : Array = []
	array.resize(x)
	for i in x : 
		array[i] = []
		array[x].resize(y)
		for j in y : 
			array[i][j] = []
			array[i][j].resize(z)
			for k in z : 
				array[i][j][k] = value 
	
