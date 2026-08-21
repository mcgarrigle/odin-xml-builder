package main

import "core:fmt"
import "project:xml"

/*
<domain type='kvm'>
  <name>test</name>
  <memory unit='KiB'>8388608</memory>
  <vcpu placement='static'>4</vcpu>
  <os firmware='efi'>
    <type arch='x86_64' machine='pc-q35-rhel10.2.0'>hvm</type>
  </os>
  <features>
    <acpi/>
    <apic/>
    <smm state='on'/>
  </features>
  <devices>
    <disk type='file' device='disk'>
      <source file='/var/lib/libvirt/filesystems/test.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <disk type='file' device='cdrom'>
      <target dev='sda' bus='sata'/>
      <readonly/>
    </disk>
    <interface type='bridge'>
      <source network='bridge' bridge='bridge0'/>
    </interface>
  </devices>
</domain>
*/

main :: proc() {
  x: xml.Builder

  xml.init(&x, true)
  defer xml.destroy(&x)

  xml.start_element(&x, "domain")
  xml.attribute(&x, "type", "kvm")
  xml.element_text(&x, "name", "test")
  xml.element_attribute_text(&x, "memory", "unit", "KiB","8388608")
  xml.element_attribute_text(&x, "type", "placement", "static","4")
  xml.start_element(&x, "os")
  xml.attribute(&x, "firmware", "efi")
  xml.start_element(&x, "type")
  xml.attribute(&x, "arch", "x86_64")
  xml.attribute(&x, "machine", "pc-q35-rhel10.2.0")
  xml.text(&x, "hvm")
  xml.end_element(&x) // type
  xml.end_element(&x) // os
  xml.end_element(&x) // domain
  fmt.println(xml.to_string(&x))

  // -----------------------------------

  xml.init(&x, true)
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
