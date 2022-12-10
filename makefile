# For Linux
TARGET_EXEC := fw_inventory
BUILD_DIR := ./build
SRC_DIR := ./src
DEP_DIR := ./dep

GCC_ARMCOMPILER ?= ${HOME}/ti/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux/gcc-arm-none-eabi-10.3-2021.10/
SIMPLELINK_MSP432_SDK_INSTALL_DIR ?= ${HOME}/ti/simplelink_msp432p4_sdk_3_40_01_02

CC = "$(GCC_ARMCOMPILER)/bin/arm-none-eabi-gcc"
LNK = "$(GCC_ARMCOMPILER)/bin/arm-none-eabi-gcc"

SRCS := $(shell find $(SRC_DIR) -name '*.c' -or -name '*.s')
OBJECTS := $(SRCS:%=$(BUILD_DIR)/%.o)

FREERTOS_SRCS := $(shell find $(DEP_DIR)/FreeRTOS -name '*.c' -or -name '*.s')
FREERTOS_OBJECTS := $(FREERTOS_SRCS:%=$(BUILD_DIR)/%.o)

DPL_SRC := $(SIMPLELINK_MSP432_SDK_INSTALL_DIR)/kernel/freertos/dpl
DPL_SRCS = \
	$(DPL_SRC)/ClockP_freertos.c \
	$(DPL_SRC)/DebugP_freertos.c \
	$(DPL_SRC)/HwiPMSP432_freertos.c \
	$(DPL_SRC)/MutexP_freertos.c \
	$(DPL_SRC)/PowerMSP432_freertos.c \
	$(DPL_SRC)/SemaphoreP_freertos.c \
	$(DPL_SRC)/SystemP_freertos.c

DPL_OBJECTS := $(DPL_SRCS:%=$(BUILD_DIR)/%.o)

# Add include paths
INC_DIRS := \
	$(SRC_DIR) \
    $(SIMPLELINK_MSP432_SDK_INSTALL_DIR)/source \
    $(SIMPLELINK_MSP432_SDK_INSTALL_DIR)/source/third_party/CMSIS/Include \
	$(SIMPLELINK_MSP432_SDK_INSTALL_DIR)/source/ti/devices/msp432p4xx/driverlib \
    $(GCC_ARMCOMPILER)/arm-none-eabi/include/newlib-nano \
    $(GCC_ARMCOMPILER)/arm-none-eabi/include \
    ${DEP_DIR}/FreeRTOS/include \
    ${DEP_DIR}/FreeRTOS/portable/GCC/ARM_CM4F

INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# Add lib paths
LD_DIRS := \
    $(GCC_ARMCOMPILER)/arm-none-eabi/lib/thumb/v7e-m/fpv4-sp/hard \
    $(SIMPLELINK_MSP432_SDK_INSTALL_DIR)/source

LD_FLAGS := $(addprefix -L,$(LD_DIRS))

# Add defines
CDEFINES := \
	__MSP432P401R__ \
	DeviceFamily_MSP432P401x \

D_CFLAGS := $(addprefix -D,$(CDEFINES))

CFLAGS = \
    -mcpu=cortex-m4 \
    -march=armv7e-m \
    -mthumb \
    -std=c99 \
    -mfloat-abi=hard \
    -mfpu=fpv4-sp-d16 \
    -ffunction-sections \
    -fdata-sections \
    -g \
    -gstrict-dwarf \
    -Wunused \
    -Wunknown-pragmas \
	$(D_CFLAGS) \
    $(INC_FLAGS)

LFLAGS = -Wl,-T,$(SRC_DIR)/msp432p401r.lds \
    "-Wl,-Map,$(BUILD_DIR)/$(NAME).map" \
    $(LD_FLAGS) \
    -l:ti/display/lib/display.am4fg \
    -l:ti/grlib/lib/gcc/m4f/grlib.a \
    -l:third_party/spiffs/lib/gcc/m4f/spiffs.a \
    -l:ti/drivers/lib/drivers_msp432p401x.am4fg \
    -l:third_party/fatfs/lib/gcc/m4f/fatfs.a \
    -l:ti/devices/msp432p4xx/driverlib/gcc/msp432p4xx_driverlib.a \
    -march=armv7e-m \
    -mthumb \
    -mfloat-abi=hard \
    -mfpu=fpv4-sp-d16 \
    -static \
    -Wl,--gc-sections \
    -lgcc \
    -lc \
    -lm \
    -lnosys \
    --specs=nano.specs

# The final build step.
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJECTS) $(FREERTOS_OBJECTS) $(DPL_OBJECTS)
	$(LNK) $(OBJECTS) $(FREERTOS_OBJECTS) $(DPL_OBJECTS) -o $@ $(LFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
