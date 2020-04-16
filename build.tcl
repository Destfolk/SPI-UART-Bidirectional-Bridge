set origin_dir "."

set _xil_proj_name_ "Bidirectional_Bridge_tcl"

variable script_file
set script_file "Bidirectional_Bridge.tcl"

set orig_proj_dir "[file normalize "$origin_dir/"]"

create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xc7a200tffv1156-1

set proj_dir [get_property directory [current_project]]

set obj [get_filesets sources_1]

set obj [get_filesets sim_1]
set files [list \
 [file normalize "${origin_dir}/../UART/UART.srcs/sim_1/new/Counter.vhd"] \
 [file normalize "${origin_dir}/../UART/UART.srcs/sim_1/new/UART Tx.vhd"] \
 [file normalize "${origin_dir}/../UART/UART.srcs/sim_1/new/UART Rx.vhd"] \
 [file normalize "${origin_dir}/../SPI_Master/SPI_Master.srcs/sim_1/new/SPI_Master.vhd"] \
]
add_files -norecurse -fileset $obj $files

set files [list \
 [file normalize "${origin_dir}/Bidirectional_Bridge.srcs/sim_1/new/Bridge.vhd" ]\
 [file normalize "${origin_dir}/Bidirectional_Bridge.srcs/sim_1/new/SPI_UART.vhd" ]\
 [file normalize "${origin_dir}/Bidirectional_Bridge.srcs/sim_1/new/tb.vhd" ]\
]
set imported_files [import_files -fileset sim_1 $files]

