extends Object

class_name OutputGenerator

static func GenerateTiledModel(settings : InputSettings , model : Array , outputPath : String) : 
	var size : Array = settings.size
	var outFile : File = File.new()
	outFile.open(outputPath , File.WRITE)
	outFile.store_line("Model generated using Paul Merrell's model synthesis algorithm.  Do not insert or delete lines from this file.")
	outFile.store_line("")
	outFile.store_line("x, y, and z extents")
	outFile.store_line(str(size[0]) + " " + str(size[1]) + " " + str(size[2]))
	outFile.store_line("")
	
	for z in size[2] : 
		for x in size[0] : 
			for y in size[1] :
				var label = model[x][y][z]
				if label < 10 : 
					outFile.store_string("")
				outFile.store_string(str(label) + " ")
			outFile.store_line("")
		outFile.store_line("")
