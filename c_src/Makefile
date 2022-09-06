# Variables to override
#
# CC            C compiler
# CROSSCOMPILE  crosscompiler prefix, if any
# CFLAGS        compiler flags for compiling all C files
# LDFLAGS       linker flags for linking all binaries

# Initialize some variables if not set
LDFLAGS ?=
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter
CFLAGS += -std=c99 -D_GNU_SOURCE

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

# Normal build
SRC = c_src/RGB.c \
  c_src/rpi_ws281x/dma.c c_src/rpi_ws281x/mailbox.c c_src/rpi_ws281x/pwm.c \
  c_src/rpi_ws281x/rpihw.c c_src/rpi_ws281x/pcm.c c_src/rpi_ws281x/ws2811.c

HEADERS =$(wildcard c_src/*.h)

OBJ=$(SRC:c_src/%.c=$(BUILD)/%.o)

calling_from_make:
	mix compile

all: $(PREFIX) $(PREFIX)/c_src

$(PREFIX):
	mkdir -p $@

$(BUILD):
	mkdir -p $@

$(BUILD)/rpi_ws281x:
	mkdir -p $@

$(BUILD)/%.o: c_src/%.c $(BUILD) $(BUILD)/rpi_ws281x
	$(CC) $(CFLAGS) -c $< -o $@

$(PREFIX)/c_src: $(OBJ)
	$(CC) $^ $(LDFLAGS) -o $@

clean:
	rm -rf $(PREFIX)/* $(BUILD)/*

.PHONY: all clean calling_from_make
