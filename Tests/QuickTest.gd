@tool
extends EditorScript

func _run():
	var Result:Vertex = BinaryOperatorVertex.new(DataVertex.new(DataToken.new()), OperatorToken.new(), DataVertex.new(DataToken.new()))
