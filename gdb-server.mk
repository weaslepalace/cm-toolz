include config.mk

Line_Prefix := ....
Nothing :=

define GDBInit_Template

....#Auto generated by Makefile. Do not modify.
....
....file $(Bin_Path)/$(ELF_File)
....
....target remote $(GDB_Server_Host):$(GDB_Server_Port)
....
....monitor device $(Target_Device)
....monitor si $(Debugger_Interface)
....monitor speed $(Debugger_Speed)
....
....define run
....    load
....    monitor reset
....end
....
....define flash
....    shell $(Debugger_Flash_Command)
....end

endef

Script := $(subst $(Line_Prefix),$(Nothing), $(GDBInit_Template))

define Debugger_Service_Template

....#Auto generated by Makefile. Do not modify.
....
....[Unit]
....Description=$(Debugger_Service_Description)
....After=default.target
....
....[Service]
....ExecStart=$(Debugger_GDB_Server_Command)
....Type=simple
....
....[Install]
....WantedBy=default.target

endef

Unit_File := $(subst $(Line_Prefix),$(Nothing), $(Debugger_Service_Template))

define Flash_Utility_Template

....#Auto generated by Makefile. Do not modify.
....
....exitonerror 1
....
....device $(Target_Device)
....si $(Debugger_Interface)
....speed $(Debugger_Speed)
....h
....r
....erase
....loadbin $(Bin_Path)/$(Binary_File) $(Target_Flash_Base_Address)
....verifybin $(Bin_Path)/$(Binary_File) $(Target_Flash_Base_Address)
....exit

endef

Flash_Utility := $(subst $(Line_Prefix),$(Nothing), $(Flash_Utility_Template))

register_safe_path := add-auto-load-safe-path $(PWD)/$(Local_GDBInit_File)

.PHONY: all clean

all: $(Local_GDBInit_File) $(Debugger_Service_Installed)

$(Local_GDBInit_File): config.mk gdb-server.mk
	$(info $@)
	$(info $(Script))
	$(file >$@, $(Script))
	$(file >>$(User_GDBInit_File),$(register_safe_path))
	echo "Created $(@)"

$(Debugger_Service_Unit_File): config.mk gdb-server.mk
	$(info $(Unit_File))
	$(file >$@, $(Unit_File))
	echo "Created $(@)"

$(Debugger_Service_Install_Location):
	mkdir -p $@

$(Debugger_Service_Installed): $(Service_Install_Path) $(Debugger_Service_Unit_File)
	cp $(Debugger_Service_Unit_File) $(Service_Install_Path)
	systemctl --user daemon-reload

$(Flash_Utility_File): config.mk gdb-server.mk
	$(info $(Flash_Utility))
	$(file >$@, $(Flash_Utility))
	echo "Created $@"

Start_Debug_Service: $(Debugger_Service_Installed)
	systemctl --user start $(Debugger_Service_Unit_File)

Stop_Debug_Service: $(Debugger_Service_Installed)
	systemctl --user stop $(Debugger_Service_Unit_File)

clean:
	rm $(Local_GDBInit_File)
	rm $(Debugger_Service_Installed)
	rm $(Debugger_Service_Unit_File)
