extends OperatorVertex
class_name UnaryOperatorVertex
var Operand:Vertex
func _init(operator_token:Token, operand:Vertex):
	Operator = operator_token
	Operand = operand

func _to_string():
	#var value = Operand.VertexValue if Operand is DataVertex and not Operand.DataType in [DataToken.DATATYPE.FUNCTION, DataToken.DATATYPE.SELECTOR] else Operand
	var operator
	if Operator.Type == Token.TYPE.OPERATOR:
		operator = OperatorToken.OPERATORTYPE.keys()[Operator.OperatorType]
	elif Operator.Type == Token.TYPE.KEYWORD and Operator.TokenValue in [DataToken.DATATYPE.BOOLEAN, DataToken.DATATYPE.INTEGER,  DataToken.DATATYPE.FLOAT, DataToken.DATATYPE.STRING, DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.VARIANT, DataToken.DATATYPE.ENUMERATION, DataToken.DATATYPE.OBJECT]:
		operator = DataToken.DATATYPE.keys()[Operator.TokenValue]
	else:
		operator = Operator.TokenValue
	return '(%s, %s)' % [str(operator), str(Operand)]

