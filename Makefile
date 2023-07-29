include config.mk

include gdb-server.mk

.PHONY: all build_dir flash debug_init jlink_stop jlink jlink_flash

all: debug

$(Binary_File):
	$(Create_Bin_Command)

flash: $(Flash_Utility_File) $(Binary_File)
	$(Flash_Command)

debug: $(Debugger_Service_Installed) $(Local_GDBInit_File) Start_Debug_Service
	gdb

stop_debug: Stop_Debug_Service
