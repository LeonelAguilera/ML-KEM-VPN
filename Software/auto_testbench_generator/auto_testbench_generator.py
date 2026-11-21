# TODO:
# [x] Generate vunit.py
# [ ] Generate unit_tb.vhdl
# [ ] Generate unit.do file in simulation
# [ ] Generate unit.txt file in testbench


import sys
import re
import os

from vhdl_parsing import parse_vhdl_file


def open_file(path):
    with open(path, 'r') as file:
        file_content = file.read()
    return file_content


def write_file(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def find_file(filename, path_prefix):
    dir_path = path_prefix
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith(filename):
                return (root + '/' + str(file)).replace("\\", "/")


def get_parent_path(path):
    child_path_index = path.index("hdl") + 3
    parent_path = path[0:child_path_index]
    return parent_path


def remove_parent_path(path):
    child_path_index = path.index("hdl") + 3
    return path[child_path_index:]


def get_child_path(path):
    return re.search(r"(\/[^.]+)*\/[^.\/]*.v", remove_parent_path(path)).group(1)


def generate_vunit_file(path, entity_name, vhdl_file):
    add_source_file_string = r'lib.add_source_files(join(root, "hdl%MODULE_PATH%").replace("\\", "/"))'

    vunit_out_path = get_child_path(path) + "/test_" + entity_name

    module_imports = ""
    for imported_module in vhdl_file.imports:
        module_path = remove_parent_path(find_file(imported_module + ".vhdl", get_parent_path(path)))
        module_imports = module_imports + add_source_file_string.replace("%MODULE_PATH%", module_path) + '\n'

    instance_imports = ""
    for instantiated_entity in vhdl_file.instances:
        instance_path = remove_parent_path(find_file(instantiated_entity + ".vhdl", get_parent_path(path)))
        instance_imports = instance_imports + add_source_file_string.replace("%MODULE_PATH%", instance_path) + '\n'

    main_entity_import = remove_parent_path(path)

    testbench_import = main_entity_import.replace(".vhdl", "_tb.vhdl")

    dofile_import = main_entity_import.replace(".vhdl", ".do")

    test_file_path = main_entity_import.replace(".vhdl", ".txt")

    vunit_template = open_file("file_templates/vunit.txt")
    vunit_file = vunit_template.replace("%VUNIT_OUT_PATH%", vunit_out_path).replace("%IMPORTED_MODULES%", module_imports).replace("%INSTANTIATED_ENTITIES%", instance_imports).replace("%MAIN_FILE%", main_entity_import).replace("%TESTBENCH_FILE%", testbench_import).replace("%DO_FILE%", dofile_import).replace("%TEST_FILE%", test_file_path)
    return vunit_file


def main():
    if (len(sys.argv) != 2):
        print("Usage of the script:\n$python auto_testbench_generator.py ./path/to/your/file.vhdl")
        return

    path = sys.argv[1].replace("\\", "/")
    file_content = open_file(path).lower()

    entity_name = re.findall(r"[^.]*", os.path.basename(path))[0]
    vhdl_file = parse_vhdl_file(file_content, entity_name)
    vunit_file = generate_vunit_file(path, entity_name, vhdl_file)
    write_file("run.py", vunit_file)


main()
