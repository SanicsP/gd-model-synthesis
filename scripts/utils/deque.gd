extends Object


class_name deque

var items : Array = []

func isEmpty() : 
	return items == []

func addFront(item) :
	items.append(item)

func addRear(item) :
	items.insert(0 , item)

func removeFront() : 
	items.pop_front()

func removeRear() : 
	items.pop_back() 

func size() : 
	return len(items)

func front() : 
	return items[0]

func back() : 
	return items[-1]

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
