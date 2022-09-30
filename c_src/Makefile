# Variables to override
#
# CC            C compiler
# CROSSCOMPILE  crosscompiler prefix, if any
# CFLAGS        compiler flags for compiling all C files
# LDFLAGS       linker flags for linking all binaries

# Initialize some variables if not set
LDFLAGS += -lm
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -Iinclude
CFLAGS += -std=c99 -D_GNU_SOURCE

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

SRC = c_src/RGB.c c_src/hsv.c \
  c_src/rpi_ws281x/dma.c c_src/rpi_ws281x/mailbox.c c_src/rpi_ws281x/pwm.c \
  c_src/rpi_ws281x/rpihw.c c_src/rpi_ws281x/pcm.c c_src/rpi_ws281x/ws2811.c

HEADERS = $(wildcard c_src/*.h) $(wildcard c_src/rpi_ws281x/*.h)

OBJ = $(patsubst c_src/%, $(BUILD)/%, $(SRC:.c=.o))

calling_from_make:
	mix compile

all: $(PREFIX) $(BUILD) $(BUILD)/rpi_ws281x $(PREFIX)/RGB

$(PREFIX) $(BUILD) $(BUILD)/rpi_ws281x:
	mkdir -p $@

$(BUILD)/%.o: c_src/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(CFLAGS) -o $@ $<

$(PREFIX)/RGB: $(OBJ)
	@echo " LD $(notdir $@)"
	$(CC) $^ $(LDFLAGS) -o $@

clean:
	rm -rf $(PREFIX)/* $(BUILD)/*

.PHONY: all clean calling_from_make
