package xml

import "core:strings"

element :: proc(x: ^Builder, name: string, content: proc(^Builder)) {
	start_element(x, name)
	content(x)
	end_element(x)
}

element_text :: proc(x: ^Builder, name: string, value: string) {
	start_element(x, name)
	text(x, value)
	end_element(x)
}

element_attribute_text :: proc(x: ^Builder, name: string, attribute_name: string, attribute_value: string, value: string) {
	start_element(x, name)
	attribute(x, attribute_name, attribute_value)
	text(x, value)
	end_element(x)
}
