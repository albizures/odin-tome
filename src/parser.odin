package tome

Integer :: i64
Float :: f64
Boolean :: bool
String :: string
Array :: distinct [dynamic]Value
Object :: distinct map[string]Value


Value :: union {
	Integer,
	Float,
	Boolean,
	String,
	Array,
	Object,
}

parse :: proc(input: string) -> (result: Object) {
	

	return
}
