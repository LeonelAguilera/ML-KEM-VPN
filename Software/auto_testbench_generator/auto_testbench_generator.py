# TODO:
# [x] Generate vunit.py
# [x] Generate unit_tb.vhdl
# [x] Generate unit.do file in simulation
# [x] Generate unit.txt file in testbench


import sys
import re
import os

from vhdl_parsing import parse_vhdl_file
from vunit_generator import generate_vunit_file
from file_operations import get_child_path, open_file, write_file, get_parent_path


type_reference = {
        "std_logic": ("scalar", "std_logic"),
        "std_logic_vector": ("scalar", "integer"),
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
\t\t\t\tREAD(array_elements(i), file_%ELEMENTVARIABLE%_element);
\t\t\t\tdata1.%ELEMENTVARIABLE%(i) <= %TYPETRANSLATION%
\t\t\tEND LOOP;\n\n
"""


def get_array_range(array_type):
    if array_type == "poly_t":
        return "0 TO 255"
    else:
        return re.search(r"\(([^)]+)\)", array_type).group(1)


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
    if type_name == "poly_t":
        return "STD_LOGIC_VECTOR(TO_UNSIGNED(%ELEMENTNAME%, COEFF_WL));"
    if type_name == "byte_array_t":
        return "STD_LOGIC_VECTOR(TO_UNSIGNED(%ELEMENTNAME%, 8));"
    else:
        return input("Write the function to turn the string in the file into the type required for " + type_name + ".\nUse %ELEMENTNAME% as a placeholder for the input variable.\nExample: STD_LOGIC_VECTOR(TO_UNSIGNED(%ELEMENTNAME%, 8));\n")




def generate_testbench_file(path, entity_name, vhdl_file):
    if len(vhdl_file.imports) > 0:
        module_imports = "LIBRARY work;\n"
        for imported_module in vhdl_file.imports:
            module_imports = module_imports + "USE work." + imported_module + '.ALL;\n'
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
        rangeless_type = re.search(r"([^( ]*)", io.type).group(1)

        if type_reference[rangeless_type][0] == "array":
            element_variable_name = "file_" + io.name + "_element"
            array_elements = array_elements + "VARIABLE " + element_variable_name + ": " + type_reference[rangeless_type][1].upper() + ";\n"
            array_range = get_array_range(io.type)
            variable_assignments = variable_assignments + (
                    array_assignment_string
                    .replace("%PORTINDEX%", str(port_index))
                    .replace("%ARRAYRANGE%", array_range)
                    .replace("%ELEMENTVARIABLE%", io.name)
                    .replace("%TYPETRANSLATION%", get_type_conversion_function(rangeless_type).replace("%ELEMENTNAME%", element_variable_name))
                )
        elif type_reference[rangeless_type][0] == "scalar":
            array_elements = array_elements + "VARIABLE file_" + io.name + ": " + io.type.upper() + ";\n"
            variable_assignments = variable_assignments + "READ(chk_line(" + str(port_index) + "), file_" + io.name + ");\n"
            if "std_logic_vector" in io.type:
                vector_range = get_array_range(io.type)
                vector_extremes = re.search(r"([^\s]+)\s*(to|downto)\s*([^\s]+)")
                if "downto" in vector_range:
                    word_width = "(" + vector_extremes.group(1) + " - " + vector_extremes.group(3) + " + 1)"
                else:
                    word_width = "(" + vector_extremes.group(3) + " - " + vector_extremes.group(1) + " + 1)"
                variable_assignments = variable_assignments + "data1." + io.name + " <= STD_LOGIC_VECTOR(TO_UNSIGNED(file_" + io.name + ", " + word_width + "))\n"
            elif "unsigned" in io.type:
                if "downto" in vector_range:
                    word_width = "(" + vector_extremes.group(1) + " - " + vector_extremes.group(3) + " + 1)"
                else:
                    word_width = "(" + vector_extremes.group(3) + " - " + vector_extremes.group(1) + " + 1)"
                variable_assignments = variable_assignments + "data1." + io.name + " <= TO_UNSIGNED(file_" + io.name + ", " + word_width + ")\n"
            elif "signed" in io.type:
                if "downto" in vector_range:
                    word_width = "(" + vector_extremes.group(1) + " - " + vector_extremes.group(3) + " + 1)"
                else:
                    word_width = "(" + vector_extremes.group(3) + " - " + vector_extremes.group(1) + " + 1)"
                variable_assignments = variable_assignments + "data1." + io.name + " <= TO_SIGNED(file_" + io.name + ", " + word_width + ")\n"
            else:
                variable_assignments = variable_assignments + "data1." + io.name + " <= file_" + io.name + ";\n"
        else:  # type_reference[io.type][0] == "ask":
            while True:
                user = input("The port " + io.name + " is of type " + io.type + ", which can be represented either as an array (A) or a scalar (S). Which representation do you prefer for this case?\n")
                if user == 'S':
                    array_elements = array_elements + "VARIABLE file_" + io.name + ": " + io.type.upper() + ";\n"
                    break
                if user == 'A':
                    element_type = ask_user_for_array_element_type(io.name)
                    array_elements = array_elements + "VARIABLE file_" + io.name + "_element: " + element_type.upper() + ";\n"
                    break
            print("I'm afraid to notify that by te time I reached this section I ran out of brainjuice and decided to not implement the assignment for " + io.name + ". Sorry, you will have to do this part on your own")

    write_output = ""
    for io in vhdl_file.entity.ports:
        if io.direction == "out":
            write_output = "\t\t\t" + write_output + io.name + "_d <= " + io.name + ";\n"

    generic_map = ""
    if len(vhdl_file.entity.generics) > 0:
        generic_map = generic_map + "GENERIC MAP(\n"
        for generic in vhdl_file.entity.generics:
            generic_map = generic_map + "\t\t\t" + generic.name + " => " + generic.name + ",\n"
        generic_map = generic_map[:-2] + "\n\t\t)\n"

    port_map = ""
    for port in vhdl_file.entity.ports:
        if port.direction == "in":
            port_map = port_map + "\t\t\t" + port.name + " => data1." + port.name + ",\n"
        else:
            port_map = port_map + "\t\t\t" + port.name + " => " + port.name + ",\n"
    port_map = port_map[:-2]

    test_check = ""
    for port in vhdl_file.entity.ports:
        if port.direction == "out":
            test_check = test_check + '\t\t\t\t\tCHECK_EQUAL(' + port.name + '_d, ref_data.' + port.name + ', "Inputs: [THIS IS A PLACEHOLDER, TO GET INPUT DISPLAY MODIFY THE TESTBENCH DIRECTLY]");\n'

    testbench_template = open_file("file_templates/testbench.txt")
    testbench_file = (
            testbench_template
            .replace("%IMPORTEDMODULES%", module_imports)
            .replace("%ENTITYNAME%", entity_name)
            .replace("%GENERICS%", generics)
            .replace("%ENTITYIO%", entity_io)
            .replace("%OUTPUTSIGNALS%", output_signals)
            .replace("%ARRAYELEMENTS%", array_elements)
            .replace("%VARIABLEASSIGNMENTS%", variable_assignments)
            .replace("%WRITEOUTPUT%", write_output)
            .replace("%GENERICMAP%", generic_map)
            .replace("%PORTMAP%", port_map)
            .replace("%TESTCHECK%", test_check)
        )
    return testbench_file


def main():
    if (len(sys.argv) != 2):
        print("Usage of the script:\n$python auto_testbench_generator.py ./path/to/your/file.vhdl")
        return

    path = sys.argv[1].replace("\\", "/")
    file_content = open_file(path).lower()

    entity_name = re.findall(r"[^.]*", os.path.basename(path))[0]
    vhdl_file = parse_vhdl_file(file_content, entity_name)

    vunit_file = generate_vunit_file(path, entity_name, vhdl_file)
    vunit_file_path = (
                path
                .replace(entity_name + ".vhdl", "test_" + entity_name + ".py")
                .replace("hdl", "unittests")
            )
    write_file(vunit_file_path, vunit_file)

    testbench_file = generate_testbench_file(path, entity_name, vhdl_file)
    testbench_file_path = (
            path
            .replace("hdl", "testbenches", 1)
            .replace(entity_name, entity_name + "_tb")
            )
    write_file(testbench_file_path, testbench_file)

    testbench_file_path = testbench_file_path.replace("_tb.vhdl", ".txt")
    write_file(testbench_file_path, "")

    simulation_file_path = testbench_file_path.replace("testbenches", "simulation").replace("txt", "do")
    write_file(simulation_file_path, "")


main()
