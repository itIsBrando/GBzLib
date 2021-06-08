LIB_FILES = video sprite joypad

SOURCE_FILES = $(wildcard *.asm)
	
	
# Don't touch varibles down here

OFILES = $(foreach dir, $(basename $(SOURCE_FILES)), $(dir).o) \
$(addsuffix .o, $(LIB_FILES))


define NEWLINE

endef

LIB_ASM = $(wildcard lib/*.asm)

test.gb : $(addsuffix .o, $(basename $(SOURCE_FILES)))
	@rgblink -o test.gb $(foreach dir, $(OFILES), build/$(dir))
	@echo Linking project...
	@rgbfix -v test.gb
	@echo ROM fixed.


$(addsuffix .o, $(basename $(SOURCE_FILES))) : $(SOURCE_FILES)
	@echo Linking object file: $@
	@rgbasm -o build/$@ $(basename $@).asm

test:
	@echo Object files: $(OFILES)
	@echo Sources: $(SOURCE_FILES)

# build library files
lib: $(LIB_ASM)
	@$(foreach dir, $(LIB_ASM), rgbasm -o build/$(notdir $(basename $(dir))).o lib/$(basename $(notdir $(dir))).asm;)
	@echo Assembled libraries.

img:
	rgbgfx tiles.png -o tiles.2bpp

clean:
	@rm -fr $(addprefix build/, $(OFILES))
	@echo cleaning build directory...