# For Linux
TARGET_EXEC := fw_inventory
BUILD_DIR := ./build
SRC_DIR := ./src
DEP_DIR := ./dep
FREERTOS_DIR := $(DEP_DIR)/FreeRTOS
TI_DIR := $(DEP_DIR)/ti
THIRD_PARTY_DIR := $(DEP_DIR)/third_party

GCC_ARMCOMPILER ?= ${HOME}/ti/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux/gcc-arm-none-eabi-10.3-2021.10/

CC = "$(GCC_ARMCOMPILER)/bin/arm-none-eabi-gcc"
LNK = "$(GCC_ARMCOMPILER)/bin/arm-none-eabi-gcc"

SRCS := $(shell find $(SRC_DIR) -name '*.c' -or -name '*.s')
OBJECTS := $(SRCS:%=$(BUILD_DIR)/%.o)

FREERTOS_SRCS := $(shell find $(FREERTOS_DIR) -name '*.c' -or -name '*.s')
FREERTOS_OBJECTS := $(FREERTOS_SRCS:%=$(BUILD_DIR)/%.o)

TI_SRCS := $(shell find $(DEP_DIR)/ti -name '*.c' -or -name '*.s')
TI_OBJECTS := $(TI_SRCS:%=$(BUILD_DIR)/%.o)

# Add include paths
INC_DIRS := \
    $(DEP_DIR) \
	$(SRC_DIR) \
    $(TI_DIR) \
    $(THIRD_PARTY_DIR)/CMSIS/Include \
	$(TI_DIR)/devices/msp432p4xx/driverlib \
    $(GCC_ARMCOMPILER)/arm-none-eabi/include/newlib-nano \
    $(GCC_ARMCOMPILER)/arm-none-eabi/include \
    ${DEP_DIR}/FreeRTOS/include \
    ${DEP_DIR}/FreeRTOS/portable/GCC/ARM_CM4F

INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# Add lib paths
LD_DIRS := \
    $(GCC_ARMCOMPILER)/arm-none-eabi/lib/thumb/v7e-m/fpv4-sp/hard \
    $(DEP_DIR)

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
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJECTS) $(FREERTOS_OBJECTS) $(TI_OBJECTS)
	$(LNK) $(OBJECTS) $(FREERTOS_OBJECTS) $(TI_OBJECTS) -o $@ $(LFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
