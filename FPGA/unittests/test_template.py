#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Template for ML-KEM-VPN
# Cheloyong Bae, Oscar Gustafsson

from os.path import join, dirname, abspath
from vunit import VUnit, VUnitCLI

# Get parent directory -> tsea84_repo
root = dirname(dirname(__file__)) 

# Set output directory of VUnit -> has to be done before vunit instance is created
cli = VUnitCLI()
cli.parser.set_defaults(output_path=join(root, "unittests/vunit_out"))
args = cli.parse_args()

# Pass on the args to vunit instance together with output path
vu = VUnit.from_args(args=args)

vu.add_vhdl_builtins()

lib = vu.add_library("lib")

# Add VHDL files for the standard design
lib.add_source_files(join(root, "hdl/module_name.vhdl"))

# Add testbenches
lib.add_source_files(join(root, "testbenches/tb_name.vhdl"))

# Add files required for the synthesized version
lib.add_source_files(join(root, "hdl/.vo")) # POSTRUN: uncomment
lib.add_source_files("/courses/TSEA84/src/verilog/src/altera_primitives.v") # POSTRUN: uncomment
lib.add_source_files("/courses/TSEA84/src/verilog/src/cycloneive_atoms.v") # POSTRUN: uncomment

# Set flags for coverage
# lib.set_compile_option("modelsim.vcom_flags", ["+cover=bs"])
# lib.set_compile_option("modelsim.vlog_flags", ["+cover=bs"])
# lib.set_sim_option("enable_coverage", True)

# Load do-file that set up waveforms
lib.set_sim_option("modelsim.init_file.gui", join(root, "simulation/dofile_name.do"))

# Set generics
lib.set_generic("varname", value)

# Set if logic_op is an enum or binary
# False: use enum
# True: use binary (for Verilog and synthesized)
lib.set_generic("logic_op", True) # POSTRUN: set to True for verilog, otherwise set to False

# Coverage callback
#def post_run(results):
#    results.merge_coverage(file_name=join(root, "unittests/coverage_data"))
#vu.main(post_run=post_run)

vu.main()
