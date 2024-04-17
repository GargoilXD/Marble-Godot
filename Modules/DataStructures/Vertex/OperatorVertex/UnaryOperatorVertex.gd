extends OperatorVertex
class_name UnaryOperatorVertex
func _init(operator_token:Token, vertex_value:Vertex):
	Operator = operator_token
	VertexValue = vertex_value

func _to_string():
	var value = VertexValue.VertexValue if VertexValue is DataVertex and not VertexValue.DataType in [DataToken.DATATYPE.FUNCTION, DataToken.DATATYPE.SELECTOR] else VertexValue
	var operator
	if Operator.Type == Token.TYPE.OPERATOR:
		operator = OperatorToken.OPERATORTYPE.keys()[Operator.OperatorType]
	elif Operator.Type == Token.TYPE.KEYWORD and Operator.TokenValue in [DataToken.DATATYPE.BOOLEAN, DataToken.DATATYPE.INTEGER,  DataToken.DATATYPE.FLOAT, DataToken.DATATYPE.STRING, DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.VARIANT]:
		operator = DataToken.DATATYPE.keys()[Operator.TokenValue]
	else:
		operator = Operator.TokenValue
	return '(%s, %s)' % [str(operator), str(value)]

