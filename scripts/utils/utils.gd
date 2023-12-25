extends Object


class_name utils


static func make2dArray(x,y,value) :
	var array : Array = []
	array.resize(x)
	for i in x : 
		array[i] = []
		array[i].resize(y)
		for j in y : 
			array[i][j] = value
	return array

static func make3dArray(x,y,z,value) : 
	var array : Array = []
	array.resize(x)
	for i in x : 
		array[i] = []
		array[i].resize(y)
		for j in y : 
			array[i][j] = []
			array[i][j].resize(z)
			for k in z : 
				array[i][j][k] = value 
	return array
