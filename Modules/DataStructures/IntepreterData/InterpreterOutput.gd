class_name InterpreterOutput
enum BREAKER{
	NONE,
	BREAK,
	CONTINUE,
	RETURN,
	ERROR
}
var Breaker:BREAKER
var Output
var Error_object:Error

func _init(breaker:BREAKER = BREAKER.NONE, data = null, error:Error = null) -> void:
	Output = data
	Breaker = breaker
	Error_object = error

func has_error() -> bool:
	return Breaker == BREAKER.ERROR

func set_break() -> void:
	Breaker = BREAKER.BREAK

func set_continue() -> void:
	Breaker = BREAKER.CONTINUE

func set_return() -> void:
	Breaker = BREAKER.RETURN

func wrap_data(data) -> InterpreterOutput:
	Output = data
	return self

func wrap_error(error:Error) -> InterpreterOutput:
	Breaker = BREAKER.ERROR
	Error_object = error
	return self

static func Wrap_data(data) -> InterpreterOutput:
	return InterpreterOutput.new(BREAKER.NONE, data)

static func Wrap_error(error:Error) -> InterpreterOutput:
	return InterpreterOutput.new(BREAKER.ERROR, null, error)
