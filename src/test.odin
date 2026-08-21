package main

import "core:fmt"
import "project:xml"


main :: proc() {
	x: xml.Builder

	xml.init(&x, true)
	defer xml.destroy(&x)
	xml.declaration(&x)

	xml.start_element(&x, "book")
	xml.attribute(&x, "id", "123")

	xml.start_element(&x, "title")
	xml.text(&x, "Odin & XML")
	xml.end_element(&x)

	xml.start_element(&x, "author")
	xml.text(&x, "John Smith")
	xml.end_element(&x)

	xml.empty_element(&x, "published")

	xml.comment(&x, "End of book")

	xml.end_element(&x)

	fmt.println(xml.to_string(&x))

  // -----------------------------------

	xml.init(&x, true)
  xml.element_attribute_text(&x, "body", "align", "left", "This is text")
	fmt.println(xml.to_string(&x))

}
