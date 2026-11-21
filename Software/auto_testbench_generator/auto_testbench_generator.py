# TODO:
# 1. Generate vunit.py
# 2. Generate unit_tb.vhdl
# 3. Generate unit.do file in simulation


import sys
import re
import os


class Generic:
    name = ""
    type = ""


class Port:
    name = ""
    direction = ""
    type = ""


class Entity:
    generics = []
    ports = []


def find_file(filename, path_prefix):
    dir_path = path_prefix
    print(dir_path)
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith(filename):
                return (root + '/' + str(file)).replace("\\", "/")


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
        generic.name = re.findall(r"\w+", generic_code[i])[0]
        generic.type = re.findall(r"\w+", generic_code[i])[1]
        generics.append(generic)

    port_code = re.findall(r"port[^.]+\);", entity_code)[0]
    port_code = re.findall(r"\S*\s*:[^;\n]*", port_code)

    ports = []
    for i in range(0, len(port_code)):
        port = Port()
        port.name = re.search(r"(\w+)\s*:", port_code[i]).group(1)
        port.direction = re.findall(r"in|out|inout", port_code[i])[0]
        port.type = re.search(r"(in|out|inout){1}\s*([^;\n]*)", port_code[i]).group(2)

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
    imports = get_vhdl_imports(file_content)
    print(imports)
    entity = get_vhdl_entity(file_content, entity_name)
    print(entity)
    instances = get_vhdl_instances(file_content)
    print(instances)


def get_parent_path(path):
    child_path_index = path.index("hdl")
    parent_path = path[0:child_path_index]
    return parent_path


def get_child_path(path):
    child_path_index = path.index("hdl") + 3
    child_path = re.search(r"(\/[^.]+)*\/[^.\/]*.v", path[child_path_index:]).group(1)
    return child_path


def generate_vunit_file(path, entity_name):
    vunit_path = get_child_path(path) + "/test_" + entity_name
    print(vunit_path)
    print(get_parent_path(path))
    #filepath = find_file("butterfly.vhdl", get_parent_path(path) + )
    #print(filepath)


def main():
    if (len(sys.argv) != 2):
        print("Usage of the script:\n$python auto_testbench_generator.py ./path/to/your/file.vhdl");
        return

    path = sys.argv[1].replace("\\", "/")
    with open(path, 'r') as file:
        file_content = file.read().lower()

    entity_name = re.findall(r"[^.]*", os.path.basename(path))[0]
    parse_vhdl_file(file_content, entity_name)
    generate_vunit_file(path, entity_name)


main()
