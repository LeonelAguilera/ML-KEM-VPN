import re

from vhdl_entity import Generic, Port, Entity


class VhdlFile:
    imports = []
    entity = Entity()
    instances = []


def get_vhdl_imports(file_content):
    imported_files = re.findall(r"use work.[^.]*.all", file_content.lower())
    for i in range(0, len(imported_files)):
        imported_files[i] = re.search(r"\.([^.]*)\.", imported_files[i]).group(1)
    return imported_files


def get_vhdl_entity(file_content, entity_name):
    entity_code = re.findall("entity " + entity_name + " is[^.]*end entity", file_content.lower())[0]

    generic_code = re.findall(r"generic[^.]+\);[^.]*port", entity_code)

    if len(generic_code) > 0:
        generic_code = re.findall(r"\S*\s*:[^;\n]*", generic_code[0])

    generics = []
    for i in range(0, len(generic_code)):
        generic = Generic()
        generic.name = re.findall(r"\w+", generic_code[i])[0].strip()
        generic.type = re.findall(r"\w+", generic_code[i])[1].strip()
        try:
            generic.default_value = re.search(r":=([^;\n]*)", generic_code[i]).group(1)
        except:
            generic.default_value = "0"
        generics.append(generic)

    port_code = re.findall(r"port[^.]+\);", entity_code)[0]
    port_code = re.findall(r"\S*\s*:[^;\n]*", port_code)

    ports = []
    for i in range(0, len(port_code)):
        port = Port()
        port.name = re.search(r"(\w+)\s*:", port_code[i]).group(1).strip()
        port.direction = re.findall(r"in|out|inout", port_code[i])[0].strip()
        port.type = re.search(r"(in|out|inout){1}\s*([^;\n]*)", port_code[i]).group(2).strip()
        ports.append(port)

    entity = Entity()
    entity.generics = generics
    entity.ports = ports

    return entity


def get_vhdl_instances(file_content):
    instance_text = re.findall(r":\s*(\w*)\s*(generic\s*map)?\s*(\([^;]*\))*\s*port map", file_content)
    instances = []
    for i in range(0, len(instance_text)):
        instances.append(instance_text[i][0])
    return instances


def parse_vhdl_file(file_content, entity_name):
    vhdl_file = VhdlFile()

    vhdl_file.imports = get_vhdl_imports(file_content)
    vhdl_file.entity = get_vhdl_entity(file_content, entity_name)
    vhdl_file.instances = get_vhdl_instances(file_content)

    return vhdl_file
