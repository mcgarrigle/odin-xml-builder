package xml

import "core:strings"

Element :: struct {
	name: string
}

Builder :: struct {
	sb:       strings.Builder,
	stack:    [dynamic]Element,
	pretty:   bool,
	indent:   int,
	open_tag: bool,
}

init :: proc(x: ^Builder, pretty := false) {
	x.sb = strings.builder_make()
	x.stack = make([dynamic]Element)
	x.pretty = pretty
	x.indent = 0
	x.open_tag = false
}

destroy :: proc(x: ^Builder) {
	strings.builder_destroy(&x.sb)
	delete(x.stack)
}

write_indent :: proc(x: ^Builder) {
	if !x.pretty {
		return
	}

	for i in 0..<x.indent {
		strings.write_string(&x.sb, "    ")
	}
}

newline :: proc(x: ^Builder) {
	if x.pretty {
		strings.write_byte(&x.sb, '\n')
	}
}

escape :: proc(x: ^Builder, value: string, attribute := false) {
	for r in value {
		switch r {
		case '&':
			strings.write_string(&x.sb, "&amp;")
		case '<':
			strings.write_string(&x.sb, "&lt;")
		case '>':
			strings.write_string(&x.sb, "&gt;")
		case '"':
			if attribute {
				strings.write_string(&x.sb, "&quot;")
			} else {
				strings.write_rune(&x.sb, r)
			}
		case '\'':
			if attribute {
				strings.write_string(&x.sb, "&apos;")
			} else {
				strings.write_rune(&x.sb, r)
			}
		case:
			strings.write_rune(&x.sb, r)
		}
	}
}

close_open_tag :: proc(x: ^Builder) {
	if x.open_tag {
		strings.write_byte(&x.sb, '>')
		x.open_tag = false
	}
}

start_element :: proc(x: ^Builder, name: string) {
	if x.open_tag {
		close_open_tag(x)
		newline(x)
	}

	if x.pretty {
		write_indent(x)
	}

	strings.write_byte(&x.sb, '<')
	strings.write_string(&x.sb, name)

	append(&x.stack, Element{name = name})
	x.open_tag = true
	x.indent += 1
}

attribute :: proc(x: ^Builder, name: string, value: string) {
	if !x.open_tag {
		return
	}

	strings.write_byte(&x.sb, ' ')
	strings.write_string(&x.sb, name)
	strings.write_string(&x.sb, "=\"")
	escape(x, value, true)
	strings.write_byte(&x.sb, '"')
}

text :: proc(x: ^Builder, value: string) {
	close_open_tag(x)
	escape(x, value)
}

raw :: proc(x: ^Builder, value: string) {
	close_open_tag(x)
	strings.write_string(&x.sb, value)
}

end_element :: proc(x: ^Builder) {
	if len(x.stack) == 0 {
		return
	}

	element := x.stack[len(x.stack)-1]
	resize(&x.stack, len(x.stack) - 1)  // Remove the element from the stack.

	x.indent -= 1

	if x.open_tag {
		strings.write_string(&x.sb, "/>")
		x.open_tag = false
		newline(x)
		return
	}

  // TODO: get </close> next to text to cuddle string even in pretty mode
	if x.pretty {
		newline(x)
		write_indent(x)
	}

	strings.write_string(&x.sb, "</")
	strings.write_string(&x.sb, element.name)
	strings.write_byte(&x.sb, '>')
	newline(x)
}

empty_element :: proc(x: ^Builder, name: string) {
	if x.open_tag {
		close_open_tag(x)
		newline(x)
	}

	if x.pretty {
		write_indent(x)
	}

	strings.write_byte(&x.sb, '<')
	strings.write_string(&x.sb, name)
	strings.write_string(&x.sb, "/>")
	newline(x)
}

comment :: proc(x: ^Builder, value: string) {
	if x.open_tag {
		close_open_tag(x)
	}

	if x.pretty {
		write_indent(x)
	}

	strings.write_string(&x.sb, "<!--")
	strings.write_string(&x.sb, value)
	strings.write_string(&x.sb, "-->")
	newline(x)
}

declaration :: proc(x: ^Builder, encoding := "UTF-8") {
	strings.write_string(&x.sb, "<?xml version=\"1.0\" encoding=\"")
	escape(x, encoding, true)
	strings.write_string(&x.sb, "\"?>")
	newline(x)
}

to_string :: proc(x: ^Builder) -> string {
	close_open_tag(x)
	return strings.to_string(x.sb)
}
