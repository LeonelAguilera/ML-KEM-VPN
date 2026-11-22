# TODO:
# [x] Generate vunit.py
# [ ] Generate unit_tb.vhdl
# [ ] Generate unit.do file in simulation
# [ ] Generate unit.txt file in testbench


import sys
import re
import os

from vhdl_parsing import parse_vhdl_file
from vunit_generator import generate_vunit_file
from file_operations import get_child_path, remove_parent_path, open_file, write_file


type_reference = {
        "std_logic": ("scalar", "std_logic"),
        "std_logic_vector": ("ask", "ask"),
        "integer": ("scalar", "integer"),
        "positive": ("scalar", "integer"),
        "negative": ("scalar", "integer"),
        "natural": ("scalar", "integer"),
        "signed": ("scalar", "integer"),
        "unsigned": ("scalar", "integer"),
        "coeff_t": ("scalar", "integer"),
        "poly_t": ("array", "integer"),
        "byte_array_t": ("array", "integer")
        }


array_assignment_string = """
\t\t\tarray_elements := SPLIT(STRIP(chk_line(%PORTINDEX%).ALL), ",");
\t\t\tFOR i IN %ARRAYRANGE% LOOP
\t\t\t\tREAD(array_elements(i), %ELEMENTVARIABLE%);
\t\t\t\tdata1.f(i) <= %TYPETRANSLATION%
\t\t\tEND LOOP;\n\n
"""


def get_array_range(array_type):
    if array_type == "poly_t":
        return "0 TO 255"
    else:
        return re.search(r"\(([^)]+)\)").group(1)


def ask_user_for_array_element_type(port_name):
    while True:
        user = input("The element of the array " + port_name + " are going to be represented as integers (I), bits (B) or strings (S)?")
        if user == 'I':
            return "integer"
        if user == 'B':
            return "std_logic"
        if user == 'S':
            return "string"


def get_type_conversion_function(type_name):
    if type_name == "coeff_t":
        return "STD_LOGIC_VECTOR(TO_UNSIGNED(%ELEMENTNAME%, COEFF_WL));"
    if type_name == "byte_array_t":
        return "STD_LOGIC_VECTOR(TO_UNSIGNED(%ELEMENTNAME%, 8));"
    else:
        return input("Write the function to turn the string in the file into the type required for " + type_name".\nUse %ELEMENTNAME% as a placeholder for the input variable.\nExample: STD_LOGIC_VECTOR(TO_UNSIGNED(%ELEMENTNAME%, 8));\n")




def generate_testbench_file(path, entity_name, vhdl_file):
    if len(vhdl_file.imports) > 0:
        module_imports = "LIBRARY work\n"
        for imported_module in vhdl_file.imports:
            module_imports = module_imports + "USE work." + imported_module + '.ALL\n'
    else:
        module_imports = ""

    if len(vhdl_file.entity.generics) > 0:
        generics = "\n"
        for generic in vhdl_file.entity.generics:
            generics = generics + "\t\t" + generic.name + ":\t" + generic.type + ';\n'
    else:
        generics = ""

    entity_io = ""
    for io in vhdl_file.entity.ports:
        entity_io = entity_io + io.name + ": " + io.type + ";\n\t\t"

    output_signals = ""
    for io in vhdl_file.entity.ports:
        if io.direction == "out":
            output_signals = output_signals + "SIGNAL " + io.name + ", " + io.name + "_d : " + io.type + ";\n\t\t"

    array_elements = ""
    variable_assignments = ""
#     data1.f(i) <= STD_LOGIC_VECTOR(TO_UNSIGNED(file_f_element, COEFF_WL));
    for port_index in range(len(vhdl_file.entity.ports)):
        io = vhdl_file.entity.ports[port_index]

        if type_reference[io.type][0] == "array":
            array_elements = array_elements + "VARIABLE file_" + io.name + "_element: " + type_reference[io.type][1].upper() + ";\n"
            array_range = get_array_range(io.type)
            variable_assignments = variable_assignments + (
                    array_assignment_string
                    .replace("%PORTINDEX%", port_index)
                    .replace("%ARRAYRANGE%", array_range)
                    .replace("%ELEMENTVARIABLE%", io.name + "_element")
                    .replace("%TYPETRANSLATION%", get_)
                )
        elif type_reference[io.type][0] == "ask":
            while True:
                user = input("The port " + io.name + " is of type " + io.type + ", which can be represented either as an array (A) or a scalar (S). Which representation do you prefer for this case?\n")
                if user == 'S':
                    array_elements = array_elements + "VARIABLE file_" + io.name + ": " + io.type.upper() + ";\n"
                    break
                if user == 'A':
                    element_type = ask_user_for_array_element_type(io.name)
                    array_elements = array_elements + "VARIABLE file_" + io.name + "_element: " + element_type.upper() + ";\n"
                    break
        elif type_reference[io.type][0] == "scalar":
            array_elements = array_elements + "VARIABLE file_" + io.name + ": " + io.type.upper() + ";\n"
            if "std_logic_vector" in io.type:
                vector_range = get_array_range(io.type)
                vector_extremes = re.search(r"([^\s]+)\s*(to|downto)\s*([^\s]+)")
                if "downto" in vector_range:
                    word_width = "(" + vector_extremes.group(1) + " - " + vector_extremes.group(3) + " + 1)"
                else:
                    word_width = "(" + vector_extremes.group(3) + " - " + vector_extremes.group(1) + " + 1)"

            variable_assignments = variable_assignments

    print(array_elements)
    return ""


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
    testbench_file = generate_testbench_file(path, entity_name, vhdl_file)
    write_file("testbench.vhdl", testbench_file)


main()
