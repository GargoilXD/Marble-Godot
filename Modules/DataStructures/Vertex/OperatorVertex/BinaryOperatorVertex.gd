extends OperatorVertex
class_name BinaryOperatorVertex
func _init(left:Vertex, operator_token:OperatorToken, right:Vertex):
	VertexValue = {'left': left, 'right': right}
	Operator = operator_token

func _to_string() -> String:
	var left = VertexValue.left.VertexValue if VertexValue.left is DataVertex and not VertexValue.left.DataType in [DataToken.DATATYPE.FUNCTION, DataToken.DATATYPE.SELECTOR] else VertexValue.left
	var right = VertexValue.right.VertexValue if VertexValue.right is DataVertex and not VertexValue.right.DataType in [DataToken.DATATYPE.FUNCTION, DataToken.DATATYPE.SELECTOR] else VertexValue.right
	return '(%s, %s, %s)' % [str(left), str(OperatorToken.OPERATORTYPE.keys()[Operator.OperatorType]), str(right)]

