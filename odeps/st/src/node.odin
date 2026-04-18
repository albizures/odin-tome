package st_src

import "core:mem"
UINT32_MAX :: uint(0xffffffff)

// All node kinds are represented as a distinct u32
// Some are custom-defined by having an offset
Node_Kind :: distinct u32

Plugin_Id :: distinct u32

CUSTOM_OFFSET :: 100

Node :: struct {
	using pos: Pos,
	kind:      Node_Kind,
}

Child :: union {
	Node,
	Parent,
}

Tree :: struct {
	allocator: mem.Allocator,
	root:      Parent,
}

Parent :: struct {
	using node: Node,
	children:   [dynamic]Child,
}
