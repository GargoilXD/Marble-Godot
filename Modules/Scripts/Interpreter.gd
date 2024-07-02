class_name Interpreter
static var Output:String = ''

class Storage:
	var Parent:Storage = null
	var Is_root:bool = false
	var Variables:Dictionary
	var Functions:Dictionary
	var for_function:bool = false
	
	func _init(is_root:bool = false, variables:Dictionary = {}, functions:Dictionary = {}) -> void:
		Is_root = is_root
		Variables = variables
		Functions = functions
	
	func create_child() -> Storage:
		var child:Storage = get_script().new()
		child.Parent = self
		return child
	
	func create_function_child(return_type) -> Storage:
		var child:Storage = get_script().new()
		child.Functions = Functions
		child.for_function = true
		child.create_variable('Return', MarbleData.new(return_type))
		return child
	
	func reset() -> void:
		Variables.clear()
		Functions.clear()
	
	func create_variable(name:String, value:MarbleData = null) -> MarbleData:
		Variables[name] = value
		return value
	
	func delete_variable(name:String) -> void:
		Variables.erase(name)
	
	func has_variable(name:String) -> bool:
		var has:bool = Variables.has(name)
		if not has:
			if Parent:
				has = Parent.has_variable(name)
		return has
	
	func set_variable(name:String, value:MarbleData) -> void:
		if Variables.has(name):
			Variables[name] = value
		else:
			if Parent:
				Parent.set_variable(name, value)
	
	func get_variable(name:String):
		if Variables.has(name):
			return Variables[name]
		else:
			if Parent:
				return Parent.get_variable(name)
	
	func create_function(name:String, value:MarbleFunction = null) -> void:
		Functions[name] = value
	
	func delete_function(name:String) -> void:
		Functions.erase(name)
	
	func has_function(name:String) -> bool:
		var has:bool = Functions.has(name)
		if not has:
			if Parent:
				has = Parent.has_function(name)
		return has
	
	func set_function(name:String, key:String, value) -> void:
		if Functions.has(name):
			Functions[name][key] = value
		else:
			if Parent:
				Parent.set_function(name, key, value)
	
	func get_function(name:String):
		if Functions.has(name):
			return Functions[name]
		else:
			if Parent:
				return Parent.get_function(name)
	
	func _to_string() -> String:
		var result:String = 'Variables:\n'
		for variable:String in Variables:
			result += "%s %s = %s\n" % [DataToken.DATATYPE.keys()[Variables[variable].Type], variable, Variables[variable]]
		return result

class DataOperator:
	static func get_raw_datatype(value) -> DataToken.DATATYPE:
		if value is bool:
			return DataToken.DATATYPE.BOOLEAN
		elif value is int:
			return DataToken.DATATYPE.INTEGER
		elif value is float:
			return DataToken.DATATYPE.FLOAT
		elif value is String:
			return DataToken.DATATYPE.STRING
		elif value is Array:
			return DataToken.DATATYPE.LIST
		elif value is Dictionary:
			return DataToken.DATATYPE.DICTIONARY
		elif value is MarbleEnumeration:
			return DataToken.DATATYPE.ENUMERATION
		elif value is MarbleObject or value == null:
			return DataToken.DATATYPE.OBJECT
		else:
			breakpoint
			return DataToken.DATATYPE.NONE
			
	static func try_convert(operand:MarbleData, type:DataToken.DATATYPE) -> MarbleData:
		var data:MarbleData = MarbleData.new(type)
		match operand.Type:
			DataToken.DATATYPE.VARIANT:
				return try_convert(MarbleData.new(get_raw_datatype(operand.Value), operand.Value), type)
			DataToken.DATATYPE.BOOLEAN:
				match type:
					DataToken.DATATYPE.INTEGER:
						data.Value = int(operand.Value)
					DataToken.DATATYPE.FLOAT:
						data.Value = float(operand.Value)
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.INTEGER:
				match type:
					DataToken.DATATYPE.FLOAT:
						data.Value = float(operand.Value)
					DataToken.DATATYPE.BOOLEAN:
						data.Value = bool(operand.Value)
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.FLOAT:
				match type:
					DataToken.DATATYPE.INTEGER:
						data.Value = int(operand.Value)
					DataToken.DATATYPE.BOOLEAN:
						data.Value = bool(operand.Value)
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.STRING:
				match type:
					DataToken.DATATYPE.BOOLEAN:
						return null
						#data.Value = bool(operand.Value)
					DataToken.DATATYPE.INTEGER:
						data.Value = int(operand.Value)
					DataToken.DATATYPE.FLOAT:
						data.Value = float(operand.Value)
					DataToken.DATATYPE.LIST:
						data.Value = []
						for x in operand.Value:
							data.Value.append(x)
					_:
						return null
			DataToken.DATATYPE.LIST:
				match type:
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.DICTIONARY:
				match type:
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
		return data
	
	static func add(left:MarbleData, right:MarbleData) -> MarbleData:
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) + int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) + right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) + right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value + int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value + right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) + right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value + float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value + float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value + right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						var M:Dictionary = left.Value
						M.merge(right.Value, true)
						data = MarbleData.new(DataToken.DATATYPE.DICTIONARY, M)
		return data

	static func subtract(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) - int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) - right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) - right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value - int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value - right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) - right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value - float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value - float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value - right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data

	static func multiply(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) * int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) * right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) * right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value * int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value * right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) * right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value * float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value * float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value * right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data

	static func divide(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) / right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) / right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) / float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) / right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value / float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value / right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data
	
	static func exponent(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, pow(int(left.Value), int(right.Value)))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, pow(int(left.Value), right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(float(left.Value), right.Value))
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, pow(left.Value, int(right.Value)))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(float(left.Value), right.Value))
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, int(right.Value)))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, float(right.Value)))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, right.Value))
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data
		
	static func modolus(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) % int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) % right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) % right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value % int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value % right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) % right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value % float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value % float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value % right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data
	
	static func And(left:MarbleData, right:MarbleData):
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value and right.Value)
	
	static func Or(left:MarbleData, right:MarbleData):
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value or right.Value)
	
	static func equals(left:MarbleData, right:MarbleData):
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value == right.Value)
	
	static func not_equals(left:MarbleData, right:MarbleData) -> MarbleData:
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value != right.Value)
		
	static func greater_than(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value.size())
		return data
		
	static func greater_than_or_equals(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value.size())
		return data
		
	static func lesser_than(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value.size())
		return data
		
	static func lesser_than_or_equals(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value.size())
		return data
	
	static func is_in(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
		return data
	
	static func negate(operand:MarbleData) -> MarbleData:
		var data:MarbleData = MarbleData.new(operand.Type)
		if operand.Type == DataToken.DATATYPE.BOOLEAN:
			data.Value = !operand.Value
		elif operand.Type in [DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT]:
			data.Value = -operand.Value
		elif operand.Type == DataToken.DATATYPE.LIST:
			data.Value = operand.Value
			data.Value.reverse()
		else:
			return null
		return data

func InterpreteVertex(vertex:Vertex, StorageObject:Storage) -> InterpreterOutput:
	if vertex is BinaryOperatorVertex:
		return InterpreteBinaryVertex(vertex, StorageObject)
	elif vertex is UnaryOperatorVertex:
		return InterpreteUnaryVertex(vertex, StorageObject)
	elif vertex is KeywordVertex:
		return InterpreteKeywordVertex(vertex, StorageObject)
	elif vertex is DataVertex:
		return InterpreteDataVertex(vertex, StorageObject)
	else:
		breakpoint
		return null

func InterpreteDataVertex(vertex:DataVertex, StorageObject:Storage) -> InterpreterOutput:
	match vertex.Data_type:
		DataToken.DATATYPE.FUNCTION:
			if vertex.Data.Identifier is KeywordToken:
				match vertex.Data.Identifier.TokenValue:
					'Print':
						for parameter:Vertex in vertex.Data.Parameters.Data:
							var interpreter_output:InterpreterOutput = InterpreteVertex(parameter, StorageObject)
							if interpreter_output.Breaker == InterpreterOutput.BREAKER.ERROR:
								return interpreter_output
							Output += str(interpreter_output.Output.Value) + ' '
						Output += '\n'
						return InterpreterOutput.Wrap_data(null)
					'Range':
						var interpreter_output:InterpreterOutput = InterpreteVertex(vertex.Data.Parameters.Data[0], StorageObject)
						if interpreter_output.Breaker == InterpreterOutput.BREAKER.ERROR:
							return interpreter_output
						var list:Array = []
						for x:int in interpreter_output.Output.Value:
							list.append(MarbleData.new(DataToken.DATATYPE.INTEGER, x))
						return interpreter_output.wrap_data(MarbleData.new(DataToken.DATATYPE.LIST, list))
					'Assert':
						var interpreter_output:InterpreterOutput = InterpreteVertex(vertex.Data.Parameters.Data[0], StorageObject)
						if interpreter_output.Breaker == InterpreterOutput.BREAKER.ERROR:
							return interpreter_output
						if !interpreter_output.Value:
							return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.ASSERTION_FAILED, vertex.Data.Parameters.Position))
					_:
						breakpoint
			else:
				if StorageObject.has_function(vertex.Data.Identifier.Data):
					var Function:MarbleFunction = StorageObject.get_function(vertex.Data.Identifier.Data)
					var child_storage_object:Storage = StorageObject.create_function_child(Function.Type)
					var Parameter:Array = vertex.Data.Parameters.Data
					for index:int in Function.Parameters.size():
						var Argument:InterpreterOutput = InterpreteVertex(Function.Parameters[index], child_storage_object)
						if Argument.Breaker == InterpreterOutput.BREAKER.ERROR:
							return Argument
						if index < Parameter.size():
							var input:InterpreterOutput = InterpreteVertex(Parameter[index], StorageObject)
							if input.Breaker == InterpreterOutput.BREAKER.ERROR:
								return input
							Argument.Output.Value = input.Output.Value
						elif Argument.Output.Value == null:
							breakpoint
					return Interprete(Function.Instructions, child_storage_object)
				else:
					return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.MESSAGE, vertex.Position, 'Undefined Function'))
		DataToken.DATATYPE.SELECTOR:
			var Parameters:Array = vertex.Data.Parameters.Data
			if Parameters.size() != 1:
				return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.MESSAGE, vertex.Position, 'What does this mean!?'))
			var interpreter_output:InterpreterOutput = InterpreteVertex(vertex.Data.Identifier, StorageObject)
			if interpreter_output.Breaker == InterpreterOutput.BREAKER.ERROR:
				return interpreter_output
			var Identifier:MarbleData = interpreter_output.Output
			if Identifier.Type == DataToken.DATATYPE.VARIANT:
				Identifier.Type = DataOperator.get_raw_datatype(Identifier.Value)
			var interpreter_output_1:InterpreterOutput = InterpreteVertex(Parameters[0], StorageObject)
			if interpreter_output_1.Breaker == InterpreterOutput.BREAKER.ERROR:
				return interpreter_output_1
			var result:MarbleData = interpreter_output_1.Output
			match Identifier.Type:
				DataToken.DATATYPE.LIST:
					if result.Type != DataToken.DATATYPE.INTEGER:
						return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Parameters[0].Position))
					if result.Value >= Identifier.Value.size():
						return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position))
					return InterpreterOutput.Wrap_data(Identifier.Value[result.Value])
				DataToken.DATATYPE.DICTIONARY:
					if !Identifier.Value.has(result.Value):
						return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position))
					var Value = Identifier.Value[result.Value]
					return InterpreterOutput.Wrap_data(MarbleData.new(DataOperator.get_raw_datatype(Value), Value))
				DataToken.DATATYPE.STRING:
					if result.Type != DataToken.DATATYPE.INTEGER:
						return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Parameters[0].Position))
					if result.Value >= Identifier.Value.length():
						return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position))
					return InterpreterOutput.Wrap_data(MarbleData.new(DataToken.DATATYPE.STRING, Identifier.Value[result.Value]))
				_:
					breakpoint
		DataToken.DATATYPE.IDENTIFIER:
			if StorageObject.has_variable(vertex.Data):
				var MarbleDataObject:MarbleData = StorageObject.get_variable(vertex.Data)
				if MarbleDataObject.Type != DataToken.DATATYPE.VARIANT and MarbleDataObject.Value == null:
					if vertex.Data != 'Return':
						return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.UNINITIALIZED_IDENTIFIER, vertex.Position))
				return InterpreterOutput.Wrap_data(MarbleDataObject)
			else:
				return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position))
		DataToken.DATATYPE.INSTRUCTIONS:
			breakpoint
			if vertex.Data.size() == 1:
				return InterpreteVertex(vertex.Data[0], StorageObject)
			else:
				print(vertex)
				breakpoint
		DataToken.DATATYPE.LIST:
			var Data:Array = []
			for item:Vertex in vertex.Data:
				var interpreter_output:InterpreterOutput = InterpreteVertex(item, StorageObject)
				if interpreter_output.Breaker == InterpreterOutput.BREAKER.ERROR:
					return interpreter_output
				interpreter_output.Output.Type = DataToken.DATATYPE.VARIANT
				Data.append(interpreter_output.Output)
			return InterpreterOutput.Wrap_data(MarbleData.new(DataToken.DATATYPE.LIST, Data))
		DataToken.DATATYPE.DICTIONARY:
			var Data:Dictionary = {}
			for item:Vertex in vertex.Data:
				var interpreter_output:InterpreterOutput = InterpreteVertex(item, StorageObject)
				if interpreter_output.Breaker == InterpreterOutput.BREAKER.ERROR:
					return interpreter_output
				Data.merge(interpreter_output.Output.Value, true)
			return InterpreterOutput.Wrap_data(MarbleData.new(DataToken.DATATYPE.DICTIONARY, Data))
		_:
			return InterpreterOutput.Wrap_data(MarbleData.FromDataVertex(vertex))
	return null


func Binary_operation(vertex:BinaryOperatorVertex, operation:Callable, StorageObject:Storage) -> InterpreterOutput:
	var Left:InterpreterOutput = InterpreteVertex(vertex.Left, StorageObject)
	if Left.Breaker == InterpreterOutput.BREAKER.ERROR:
		return Left
	var Right:InterpreterOutput = InterpreteVertex(vertex.Right, StorageObject)
	if Right.Breaker == InterpreterOutput.BREAKER.ERROR:
		return Right
	var Result:MarbleData = operation.call(Left.Output, Right.Output)
	if Result == null:
		return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position))
	return InterpreterOutput.Wrap_data(Result)

func Assign_operation(vertex:BinaryOperatorVertex, StorageObject:Storage, operation = null) -> InterpreterOutput:
	if vertex.Left is DataVertex:
		if not vertex.Left.Data_type in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
			Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Left.Position)
	
	var Left:InterpreterOutput = InterpreteVertex(vertex.Left, StorageObject)
	if Left.Breaker == InterpreterOutput.BREAKER.ERROR:
		return Left
	if Left.Output.Type == DataToken.DATATYPE.ENUMERATION:
		Left.Output.Value = MarbleEnumeration.new()
		for index:int in vertex.Right.Data.size():
			Left.Output.Value.Value[vertex.Right.Data[index].Data] = index
		return Left
	var Right:InterpreterOutput = InterpreteVertex(vertex.Right, StorageObject)
	if Right.Breaker == InterpreterOutput.BREAKER.ERROR:
		return Right
	if Left.Output.Type == DataToken.DATATYPE.VARIANT:
		Left.Output.Value = Right.Output.Value
	else:
		if Left.Output.Type == Right.Output.Type:
			if operation:
				Left.Output.Value = operation.call(Left.Output, Right.Output).Value
			else:
				Left.Output.Value = Right.Output.Value
		else:
			var converted_data:MarbleData = DataOperator.try_convert(Right.Output, Left.Output.Type)
			if converted_data == null:
				return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.Right.Position))
			else:
				if operation:
					Left.Output.Value = operation.call(Left.Output, Right.Output).Value
				else:
					Left.Output.Value = Right.Output.Value
	return Left

func InterpreteBinaryVertex(vertex:BinaryOperatorVertex, StorageObject:Storage) -> InterpreterOutput:
	match vertex.Operator.OperatorType:
		OperatorToken.OPERATORTYPE.DOT:
			print(vertex)
			breakpoint
		OperatorToken.OPERATORTYPE.ADD:
			return Binary_operation(vertex, DataOperator.add, StorageObject)
		OperatorToken.OPERATORTYPE.SUBTRACT:
			return Binary_operation(vertex, DataOperator.subtract, StorageObject)
		OperatorToken.OPERATORTYPE.MULTIPLY:
			return Binary_operation(vertex, DataOperator.multiply, StorageObject)
		OperatorToken.OPERATORTYPE.DIVIDE:
			return Binary_operation(vertex, DataOperator.divide, StorageObject)
		OperatorToken.OPERATORTYPE.EXPONENT:
			return Binary_operation(vertex, DataOperator.exponent, StorageObject)
		OperatorToken.OPERATORTYPE.MODOLUS:
			return Binary_operation(vertex, DataOperator.modolus, StorageObject)
		OperatorToken.OPERATORTYPE.AND:
			return Binary_operation(vertex, DataOperator.And, StorageObject)
		OperatorToken.OPERATORTYPE.OR:
			return Binary_operation(vertex, DataOperator.Or, StorageObject)
		OperatorToken.OPERATORTYPE.IN:
			return Binary_operation(vertex, DataOperator.is_in, StorageObject)
		OperatorToken.OPERATORTYPE.EQUALS:
			return Binary_operation(vertex, DataOperator.equals, StorageObject)
		OperatorToken.OPERATORTYPE.NOT_EQUALS:
			return Binary_operation(vertex, DataOperator.not_equals, StorageObject)
		OperatorToken.OPERATORTYPE.GREATER_THAN:
			return Binary_operation(vertex, DataOperator.greater_than, StorageObject)
		OperatorToken.OPERATORTYPE.GREATER_THAN_OR_EQUALS:
			return Binary_operation(vertex, DataOperator.greater_than_or_equals, StorageObject)
		OperatorToken.OPERATORTYPE.LESSER_THAN:
			return Binary_operation(vertex, DataOperator.lesser_than, StorageObject)
		OperatorToken.OPERATORTYPE.LESSER_THAN_OR_EQUALS:
			return Binary_operation(vertex, DataOperator.lesser_than_or_equals, StorageObject)
		OperatorToken.OPERATORTYPE.ASSIGN:
			return Assign_operation(vertex, StorageObject)
		OperatorToken.OPERATORTYPE.ADD_AND_ASSIGN:
			return Assign_operation(vertex, StorageObject, DataOperator.add)
		OperatorToken.OPERATORTYPE.SUBTRACT_AND_ASSIGN:
			return Assign_operation(vertex, StorageObject, DataOperator.subtract)
		OperatorToken.OPERATORTYPE.MULTIPLY_AND_ASSIGN:
			return Assign_operation(vertex, StorageObject, DataOperator.multiply)
		OperatorToken.OPERATORTYPE.DIVIDE_AND_ASSIGN:
			return Assign_operation(vertex, StorageObject, DataOperator.divide)
		OperatorToken.OPERATORTYPE.EXPONENT_AND_ASSIGN:
			return Assign_operation(vertex, StorageObject, DataOperator.exponent)
		OperatorToken.OPERATORTYPE.MODOLUS_AND_ASSIGN:
			return Assign_operation(vertex, StorageObject, DataOperator.modolus)
		OperatorToken.OPERATORTYPE.COLON:
			var Left:InterpreterOutput = InterpreteVertex(vertex.Left, StorageObject)
			if Left.Breaker == InterpreterOutput.BREAKER.ERROR:
				return Left
			if Left.Output.Type in [DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.OBJECT]:
				return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.MESSAGE, vertex.Left.Position, 'Invalid Key'))
			var Right:InterpreterOutput = InterpreteVertex(vertex.Right, StorageObject)
			if Right.Breaker == InterpreterOutput.BREAKER.ERROR:
				return Right
			return InterpreterOutput.Wrap_data(MarbleData.new(DataToken.DATATYPE.DICTIONARY, {Left.Output.Value : Right.Output.Value}))
		OperatorToken.OPERATORTYPE.RUNS:
			var child_storage_object:Storage = StorageObject.create_child()
			match vertex.Left.Operator.TokenValue:
				'Function':
					var Type:DataToken.DATATYPE = vertex.Left.Operand.Operator.TokenValue
					var Name:String = vertex.Left.Operand.Operand.Data.Identifier.Data
					var Parameters:Array = vertex.Left.Operand.Operand.Data.Parameters.Data
					var Instructions:Array = vertex.Right.Data.instructions
					StorageObject.create_function(Name, MarbleFunction.new(Type, Name, Parameters, Instructions))
				'if':
					var if_condition:InterpreterOutput = InterpreteVertex(vertex.Left.Operand, child_storage_object)
					if if_condition.Breaker == InterpreterOutput.BREAKER.ERROR:
						return if_condition
					if if_condition.Output.Type != DataToken.DATATYPE.BOOLEAN:
						if_condition.Output = DataOperator.try_convert(if_condition.Output, DataToken.DATATYPE.BOOLEAN)
						if if_condition.Output == null:
							return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.Left.Operand.Position))
					if if_condition.Output.Value:
						return Interprete(vertex.Right.Data.instructions, child_storage_object)
					else:
						var else_if_conditions:Array = vertex.Right.Data.else_ifs
						var else_if_instruction = null
						for else_if_condition:BinaryOperatorVertex in else_if_conditions:
							var else_if_key:InterpreterOutput = InterpreteVertex(else_if_condition.Left.Operand, child_storage_object)
							if else_if_key.Breaker == InterpreterOutput.BREAKER.ERROR:
								return else_if_key
							if else_if_key.Output.Value:
								else_if_instruction = else_if_condition.Right.Data.instructions
								break
						if else_if_instruction:
							return Interprete(else_if_instruction, child_storage_object)
						else:
							if vertex.Right.Data.else:
								return Interprete(vertex.Right.Data.else.Data.instructions, child_storage_object)
				'For':
					var IN:BinaryOperatorVertex = vertex.Left.Operand
					var get_variable:InterpreterOutput = InterpreteVertex(IN.Left, child_storage_object)
					if get_variable.Breaker == InterpreterOutput.BREAKER.ERROR:
						return get_variable
					var Iteratable:InterpreterOutput = InterpreteDataVertex(IN.Right, child_storage_object)
					if Iteratable.Breaker == InterpreterOutput.BREAKER.ERROR:
						return Iteratable
					#Lists only
					if Iteratable.Output.Type != DataToken.DATATYPE.LIST:
						return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.MESSAGE, IN.Right.Position, 'Lists Only!'))
					for data:MarbleData in Iteratable.Output.Value:
						get_variable.Output.Value = data.Value
						var interpreter_output:InterpreterOutput = Interprete(vertex.Right.Data.instructions, child_storage_object)
						match interpreter_output.Breaker:
							InterpreterOutput.BREAKER.BREAK:
								break
							InterpreterOutput.BREAKER.CONTINUE, InterpreterOutput.BREAKER.NONE:
								continue
							InterpreterOutput.BREAKER.RETURN, InterpreterOutput.BREAKER.ERROR:
								return interpreter_output
				'While':
					var while_condition:InterpreterOutput = InterpreteVertex(vertex.Left.Operand, child_storage_object)
					if while_condition.Breaker == InterpreterOutput.BREAKER.ERROR:
						return while_condition
					while while_condition.Output.Value:
						var interpreter_output:InterpreterOutput = Interprete(vertex.Right.Data.instructions, child_storage_object)
						match interpreter_output.Breaker:
							InterpreterOutput.BREAKER.BREAK:
								break
							InterpreterOutput.BREAKER.CONTINUE, InterpreterOutput.BREAKER.NONE:
								while_condition = InterpreteVertex(vertex.Left.Operand, child_storage_object)
								if while_condition.Breaker == InterpreterOutput.BREAKER.ERROR:
									return while_condition
							InterpreterOutput.BREAKER.RETURN, InterpreterOutput.BREAKER.ERROR:
								return interpreter_output
						
				#'Match':
					#var match_value = InterpreteVertex(vertex.Left.VertexValue, child_storage_object)
					#if match_value is Error:
						#return match_value
					#var instructions = null
					#for case in vertex.Right.VertexValue.instructions:
						#if case.Left.VertexValue is String:
							#instructions = case.Right.VertexValue.instructions
							#break
						#else:
							#if case.Left.VertexValue.VertexValue == match_value.Value:
								#instructions = case.Right.VertexValue.instructions
								#break
					#var res = Interprete(instructions, child_storage_object)
					#if res is Error:
						#return res
				_:
					breakpoint
		_:
			print(vertex)
			breakpoint
	return InterpreterOutput.new(InterpreterOutput.BREAKER.NONE)

func InterpreteUnaryVertex(vertex:UnaryOperatorVertex, StorageObject:Storage) -> InterpreterOutput:
	if vertex.Operator is OperatorToken:
		match vertex.Operator.OperatorType:
			OperatorToken.OPERATORTYPE.NOT, OperatorToken.OPERATORTYPE.SUBTRACT:
				var interpreter_output:InterpreterOutput = InterpreteVertex(vertex.Operand, StorageObject)
				if interpreter_output.Breaker == InterpreterOutput.BREAKER.ERROR:
					return interpreter_output
				return interpreter_output.wrap_data(DataOperator.negate(interpreter_output.Output))
			OperatorToken.OPERATORTYPE.ADD:
				return InterpreteVertex(vertex.Operand, StorageObject)
			_:
				print(vertex)
				breakpoint
				return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position))
	elif vertex.Operator is KeywordToken:
		match vertex.Operator.TokenValue:
			DataToken.DATATYPE.VARIANT, DataToken.DATATYPE.BOOLEAN, DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT, DataToken.DATATYPE.STRING, DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.ENUMERATION, DataToken.DATATYPE.OBJECT:
				if StorageObject.has_variable(vertex.Operand.Data):
					return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.ALREADY_DEFINED_IDENTIFIER, vertex.Position))
				else:
					return InterpreterOutput.Wrap_data(StorageObject.create_variable(vertex.Operand.Data, MarbleData.new(vertex.Operator.TokenValue)))
			'Return':
				if StorageObject.has_variable('Return'):
					return Assign_operation(BinaryOperatorVertex.new(DataVertex.new(DataToken.DATATYPE.IDENTIFIER, null, 'Return'), OperatorToken.new(), vertex.Operand), StorageObject)
				else:
					return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.MESSAGE, vertex.Operator.Position, 'You can only do this in a function'))
	print(vertex)
	breakpoint
	return InterpreterOutput.Wrap_error(Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position))

func InterpreteKeywordVertex(vertex:KeywordVertex, _StorageObject:Storage) -> InterpreterOutput:
	match vertex.Keyword_type:
		KeywordToken.KEYWORD.MODIFIER:
			breakpoint
		KeywordToken.KEYWORD.DATATYPE:
			breakpoint
		KeywordToken.KEYWORD.FLOWCONTROL:
			match vertex.Keyword:
				'Break':
					return InterpreterOutput.new(InterpreterOutput.BREAKER.BREAK)
				'Continue':
					return InterpreterOutput.new(InterpreterOutput.BREAKER.CONTINUE)
				'Breakpoint':
					breakpoint
				'Return':
					breakpoint
				_:
					breakpoint
		KeywordToken.KEYWORD.DECISION:
			breakpoint
		KeywordToken.KEYWORD.LOOP:
			breakpoint
		KeywordToken.KEYWORD.INSTRUCTION_SET:
			breakpoint
		KeywordToken.KEYWORD.FUNCTION:
			breakpoint
	return null

func Interprete(Parsed:Array, StorageObject:Storage = Storage.new(true)) -> InterpreterOutput:
	for vertex:Vertex in Parsed:
		var interpreter_output:InterpreterOutput = InterpreteVertex(vertex, StorageObject)
		match interpreter_output.Breaker:
			InterpreterOutput.BREAKER.NONE:
				continue
			InterpreterOutput.BREAKER.BREAK, InterpreterOutput.BREAKER.CONTINUE:
				if StorageObject.Is_root or StorageObject.for_function:
					return interpreter_output.wrap_error(Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position))
				return interpreter_output
			InterpreterOutput.BREAKER.RETURN:
				if StorageObject.Is_root or StorageObject.for_function:
					return interpreter_output.wrap_error(Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position))
				return interpreter_output
			InterpreterOutput.BREAKER.ERROR:
				return interpreter_output
	if StorageObject.Is_root:
		return InterpreterOutput.new(InterpreterOutput.BREAKER.NONE, Output)
	elif StorageObject.for_function:
		return InterpreterOutput.new(InterpreterOutput.BREAKER.NONE, StorageObject.get_variable('Return'))
	else:
		return InterpreterOutput.new(InterpreterOutput.BREAKER.NONE)
		
