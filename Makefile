PROJECT_NAME = dantto4k

SRC_DIR = src
OBJ_DIR = build

SRC_FILES = $(filter-out $(SRC_DIR)/bonTuner.cpp $(SRC_DIR)/dllmain.cpp, $(wildcard $(SRC_DIR)/*.cpp))

OBJ_FILES = $(SRC_FILES:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)

ifeq ($(STATIC_TSDUCK), 1)
    TSDUCK_BIN_DIR = $(wildcard thirdparty/tsduck/bin/release-*-linux)
    TSDUCK_INC = -Ithirdparty/tsduck/bin/include -Ithirdparty/tsduck/src/libtsduck -Ithirdparty/tsduck/src/libtscore
    TSDUCK_LIB = -Wl,--whole-archive $(TSDUCK_BIN_DIR)/libtsduck.a $(TSDUCK_BIN_DIR)/libtscore.a -Wl,--no-whole-archive -lcrypto -lcurl -lstdc++ -lm -ldl -lpthread -lrt -latomic
    CXXFLAGS_EXTRA = -DTSDUCK_STATIC_LIBRARY -DTSCORE_STATIC_LIBRARY
else
    TSDUCK_INC = $(shell pkg-config --cflags-only-I tsduck)
    TSDUCK_LIB = $(shell pkg-config --libs tsduck)
    CXXFLAGS_EXTRA =
endif

PCSC_INC = $(shell pkg-config --cflags-only-I libpcsclite)
PCSC_LIB = $(shell pkg-config --libs libpcsclite)

CXX = g++
CXXFLAGS = -std=c++20 -Wall -maes -msse4.1 $(CXXFLAGS_EXTRA) $(TSDUCK_INC) $(PCSC_INC) -Ithirdparty/asio/asio/include
LDFLAGS = $(TSDUCK_LIB) $(PCSC_LIB)

EXEC = $(OBJ_DIR)/$(PROJECT_NAME)

all: $(EXEC)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(EXEC): $(OBJ_FILES)
	$(CXX) $(OBJ_FILES) $(LDFLAGS) -o $(EXEC)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)

install:
	cp $(EXEC) /usr/local/bin/$(PROJECT_NAME)

.PHONY: all clean install
