package tome

import "src"

Tokenizer :: src.Tokenizer
Token :: src.Token
Token_Kind :: src.Token_Kind

Nil :: src.Nil
Integer :: src.Integer
Float :: src.Float
Bool :: src.Bool
Object :: src.Object
Value :: src.Value
String :: src.String
Array :: src.Array
Null :: src.Null

Tome_Error :: src.Tome_Error
Parser :: src.Parser

parse :: src.parse
serialize :: proc {
	src.serialize_ast,
	src.serialize_cst,
}
parse_cst :: src.parse_cst
cst_find_node_by_key :: src.cst_find_node_by_key
cst_update_value :: src.cst_update_value
new_cst_node :: src.new_cst_node
add_child :: src.add_child
free_node :: proc {
	src.free_cst_node,
}
create_tokenizer :: src.create_tokenizer
get_token :: src.get_token
get_span_value :: src.get_span_value


DEFAULT_SERIALIZE_OPTIONS :: src.DEFAULT_SERIALIZE_OPTIONS
