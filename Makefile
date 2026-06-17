TARGET_EXEC := stc8prog
BUILD_DIR := ./build
RELEASE_DIR := ./release
SRC_DIRS := ./src

TARGET_OS :=
ifeq ($(OS),Windows_NT)
	TARGET_OS := win32
	SRC_DIRS += ./src/serial/win32
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		TARGET_OS := Linux
		SRC_DIRS += ./src/serial/linux
	endif
	ifeq ($(UNAME_S),Darwin)
		TARGET_OS := Darwin
		SRC_DIRS += ./src/serial/linux
	endif
endif

ifeq ($(origin CC),default)
	ifeq ($(TARGET_OS),win32)
		CC := gcc
	endif
endif

TARGET_EXT :=
ifeq ($(TARGET_OS),win32)
	TARGET_EXT := .exe
endif
TARGET_BIN := $(RELEASE_DIR)/$(TARGET_EXEC)$(TARGET_EXT)

# Find all the C files we want to compile
SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))

# String substitution for every source file.
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# Every folder in ./src will need to be passed to GCC so that it can find header files
INC_DIRS := $(SRC_DIRS)
# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# The final build step.
$(TARGET_BIN): $(OBJS)
	@mkdir -p $(dir $@)
ifeq ($(TARGET_OS),win32)
	@echo -e "\e[34mMKPE\e[0m	" $@
else
	@echo -e "\e[34mMKELF\e[0m	" $@
endif
	@$(CC) $(OBJS) -o $@ $(LDFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(dir $@)
	@echo -e "\e[32mCC\e[0m	" $@
	@$(CC) $(CFLAGS) $(INC_FLAGS) -c $< -o $@

install:
ifeq ($(TARGET_OS),win32)	
	@echo "Windows users must copy binary to desired location manually"
else
	@echo "It is better to use the system installer of your distribution"
	@echo "For gentoo - rasdark overlay, dev-embedded/stc8prog"
#Binary path from XuHg-zjcn	
	install $(TARGET_BIN) /usr/local/bin
endif

.PHONY: clean
clean:
	@rm -f -r $(BUILD_DIR)
	@rm -f -r $(RELEASE_DIR)
	@rm -f ./$(TARGET_EXEC) ./$(TARGET_EXEC).exe
