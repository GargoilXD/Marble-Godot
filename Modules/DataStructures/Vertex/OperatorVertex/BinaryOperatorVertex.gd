extends OperatorVertex
class_name BinaryOperatorVertex
var Left:Vertex
var Right:Vertex
func _init(left:Vertex, operator_token:OperatorToken, right:Vertex):
	Left = left
	Operator = operator_token
	Right = right

func _to_string() -> String:
	#var left = Left.VertexValue if Left is DataVertex and not Left.DataType in [DataToken.DATATYPE.FUNCTION, DataToken.DATATYPE.SELECTOR] else Left
	#var right = Right.VertexValue if Right is DataVertex and not Right.DataType in [DataToken.DATATYPE.FUNCTION, DataToken.DATATYPE.SELECTOR] else Right
	return '(%s, %s, %s)' % [str(Left), str(OperatorToken.OPERATORTYPE.keys()[Operator.OperatorType]), str(Right)]

