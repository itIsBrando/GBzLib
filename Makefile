LIB_FILES = video sprite

SOURCE_FILES = $(wildcard *.asm)
OFILES = $(foreach dir, $(basename $(SOURCE_FILES)), $(dir).o) \
	$(addsuffix .o, $(LIB_FILES))

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
lib: lib/video.asm lib/memory.asm lib/sprite.asm
	@rgbasm -o build/video.o lib/video.asm
	@rgbasm -o build/sprite.o lib/sprite.asm
	@rgbasm -o build/memory.o lib/memory.asm 
	@echo Assembled libraries.

img:
	rgbgfx tiles.png -o tiles.2bpp

clean:
	@rm -fr $(addprefix build/, $(OFILES))
	@echo cleaning build directory...