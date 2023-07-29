ELF_File := $(ELF)
Binary_File := $(basename $(ELF)).bin
Bin_Path := ../my_first_ada/bin

Local_GDBInit_File := .gdbinit
User_GDBInit_File := $(HOME)/.gdbinit

GDB_Server_Port := 2331
GDB_Server_Host := localhost


#List of possible target devices can be found at
# https://www.segger.com/supported-devices
Target_Device := EFM32PG22CxxxF128

Debugger_Speed := auto
Debugger_Interface := SWD
Debugger_Flash_Script := .flash.jlink

Debugger_Flash_Command := JLinkExe -commanderscript $(Debugger_Flash_Script)

Debugger_Service_Description := JLink GDB Service

define Debugger_GDB_Server_Command :=
	$(strip
		JLinkGDBServer
			-device $(Target_Device)
			-speed $(Debugger_Speed)
			-if $(Debugger_Interface)
	)
endef

Debugger_Service_Unit_File := gdb-server.service
Service_Install_Path := $(HOME)/.config/systemd/user
Debugger_Service_Installed := $(Service_Install_Path)/$(Debugger_Service_Unit_File)

define Create_Bin_Command := 
	$(strip
		arm-none-eabi-objcopy
			-O binary
			$(Bin_Path)/$(ELF_File)
			$(Bin_Path)/$(Binary_File)
	)
endef

Flash_Utility_File := .flash.jlink

define Flash_Command :=
	$(strip
		JLinkExe -commanderscript $(Flash_Utility_File)
	)
endef

Target_Flash_Base_Address := 0x00000000
