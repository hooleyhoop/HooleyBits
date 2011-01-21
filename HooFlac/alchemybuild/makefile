CC=gcc
CFLAGS=-I -O3 -Wall
DEPS = ordinals.h bitmath.h bitreader.h bitwriter.h cpu.h crc.h fixed.h float.h format.h lpc.h md5.h memory.h stream_decoder.h stream_encoder_framing.h stream_encoder.h window.h
OBJ = AS3_main.o bitmath.o bitreader.o bitwriter.o cpu.o crc.o fixed.o float.o format.o lpc.o md5.o memory.o stream_decoder.o stream_encoder_framing.o stream_encoder.o window.o

# every .o file depends on its .c file and DEPS
#%.o: %.c $(DEPS)
	# compile the o file. $@ is the file on the left of the :   $< is the first dep?
#	$(CC) -c -o $@ $< $(CFLAGS)

hellomake: $(OBJ) $(DEPS)
	$(CC) *.o -Os -std=gnu99 -swc $(DEPS) --combine -o flacEncode.swc




