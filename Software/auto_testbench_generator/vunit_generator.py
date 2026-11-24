from file_operations import get_child_path, get_parent_path, remove_parent_path, open_file, write_file, find_file


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

    set_generics = ""
    for generic in vhdl_file.entity.generics:
        set_generics = set_generics + 'lib.set_generic("' + generic.name + '", ' + generic.default_value + ')\n'

    main_entity_import = remove_parent_path(path)

    testbench_import = main_entity_import.replace(".vhdl", "_tb.vhdl")

    dofile_import = main_entity_import.replace(".vhdl", ".do")

    test_file_path = main_entity_import.replace(".vhdl", ".txt")

    vunit_template = open_file("file_templates/vunit.txt")
    vunit_file = (
            vunit_template
            .replace("%VUNIT_OUT_PATH%", vunit_out_path)
            .replace("%IMPORTED_MODULES%", module_imports)
            .replace("%INSTANTIATED_ENTITIES%", instance_imports)
            .replace("%MAIN_FILE%", main_entity_import)
            .replace("%TESTBENCH_FILE%", testbench_import)
            .replace("%DO_FILE%", dofile_import)
            .replace("%SETGENERICS%", set_generics)
            .replace("%TEST_FILE%", test_file_path)
        )
    return vunit_file
