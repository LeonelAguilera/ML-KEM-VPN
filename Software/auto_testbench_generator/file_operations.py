import re
import os


def open_file(path):
    with open(path, 'r') as file:
        file_content = file.read()
    return file_content


def write_file(path, content):
    try:
        with open(path, "x", encoding="utf-8") as f:
            f.write(content)
    except FileExistsError:
        while True:
            user = input("This script is trying to create the file: " + path + "\nHowever, this file already exists. Do you want to overwrite it (Y)? Or Skip it (N)?\n")
            if (user == 'Y'):
                with open(path, "w", encoding="utf-8") as f:
                    f.write(content)
                break
            if (user == 'N'):
                break


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
