class_name TokenPosition
var StartPoint:int
var EndPoint:int
var StartLine:int
var EndLine:int

func _init(start_point:int = 0, end_point:int = 0, start_line:int = 0, end_line:int = 0):
	StartPoint = start_point
	EndPoint = end_point
	StartLine = start_line
	EndLine = end_line

func extend(position:TokenPosition) -> TokenPosition:
	EndPoint = position.EndPoint
	EndLine = position.EndLine
	return self

func duplicate() -> TokenPosition:
	return get_script().new(StartPoint, EndPoint, StartLine, EndLine)

func _to_string() -> String:
	var Point:String = ('Point: (%d)' % StartPoint ) if StartPoint == EndPoint else ('Point: (%d - %d)' % [StartPoint, EndPoint]) 
	var Line:String = (', Line: (%d)' % StartLine ) if StartLine == EndLine else (', Line: (%d - %d)' % [StartLine, EndLine]) 
	return Point + Line
