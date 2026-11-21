# TODO:
# 1. Generate vunit.py
# 2. Generate unit_tb.vhdl
# 3. Generate unit.do file in simulation


import sys
import re
import os

from vhdl_parsing import parse_vhdl_file


def find_file(filename, path_prefix):
    dir_path = path_prefix
    print(dir_path)
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith(filename):
                return (root + '/' + str(file)).replace("\\", "/")


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
    # filepath = find_file("butterfly.vhdl", get_parent_path(path) + )
    # print(filepath)


def main():
    if (len(sys.argv) != 2):
        print("Usage of the script:\n$python auto_testbench_generator.py ./path/to/your/file.vhdl")
        return

    path = sys.argv[1].replace("\\", "/")
    with open(path, 'r') as file:
        file_content = file.read().lower()

    entity_name = re.findall(r"[^.]*", os.path.basename(path))[0]
    parse_vhdl_file(file_content, entity_name)
    generate_vunit_file(path, entity_name)


main()
