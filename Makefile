PRE_JS = build/pre.js
POST_JS_SYNC = build/post-sync.js
POST_JS_WORKER = build/post-worker.js

COMMON_FILTERS = 
COMMON_DEMUXERS =     wav  
COMMON_DECODERS =     mp3 aac pcm_s16le  

WEBM_MUXERS =   null
WEBM_ENCODERS =  
FFMPEG_WEBM_BC = build/ffmpeg-webm/ffmpeg.bc
FFMPEG_WEBM_PC_PATH = ../opus/dist/lib/pkgconfig
WEBM_SHARED_DEPS = \

MP4_MUXERS =  mp3 null
MP4_ENCODERS =  libmp3lame aac
FFMPEG_MP4_BC = build/ffmpeg-mp4/ffmpeg.bc
FFMPEG_MP4_PC_PATH = ../x264/dist/lib/pkgconfig
MP4_SHARED_DEPS = \
	build/lame/dist/lib/libmp3lame.so \

all:  

clean: clean-js \
	 clean-libvpx clean-ffmpeg-webm \
	clean-lame  
clean-js:
	rm -f ffmpeg*.js

clean-libvpx:
	cd build/libvpx && git clean -xdf

clean-lame:
	cd build/lame && git clean -xdf

build/libvpx/dist/lib/libvpx.so:
	cd build/libvpx && \
	git reset --hard && \
	patch -p1 < ../libvpx-fix-ld.patch && \
	emconfigure ./configure \
		--prefix="$$(pwd)/dist" \
		--target=generic-gnu \
		--disable-dependency-tracking \
		--disable-multithread \
		--disable-runtime-cpu-detect \
		--enable-shared \
		--disable-static \
		\
		--disable-examples \
		--disable-docs \
		--disable-unit-tests \
		--disable-webm-io \
		--disable-libyuv \
		--disable-vp8-decoder \
		--disable-vp9 \
		&& \
	emmake make -j33 && \
	emmake make install

build/lame/dist/lib/libmp3lame.so:
	cd build/lame/lame && \
	git reset --hard && \
	patch -p2 < ../../lame-fix-ld.patch && \
	emconfigure ./configure \
		CFLAGS="-DNDEBUG -O3" \
		--prefix="$$(pwd)/../dist" \
		--host=x86-none-linux \
		--disable-static \
		\
		--disable-gtktest \
		--disable-analyzer-hooks \
		--disable-decoder \
		--disable-frontend \
		&& \
	emmake make -j33 && \
	emmake make install

FFMPEG_COMMON_ARGS = \
	--cc=emcc \
	--ranlib=emranlib \
	--enable-cross-compile \
	--target-os=none \
	--arch=x86 \
	--disable-runtime-cpudetect \
	--disable-asm \
	--disable-fast-unaligned \
	--disable-pthreads \
	--disable-w32threads \
	--disable-os2threads \
	--disable-debug \
	--disable-stripping \
	--disable-safe-bitstream-reader \
	\
	--disable-all \
	--enable-ffmpeg \
	--enable-avcodec \
	--enable-avformat \
	--enable-avfilter \
	--enable-swresample \
	--enable-swscale \
	--disable-network \
	--disable-d3d11va \
	--disable-dxva2 \
	--disable-vaapi \
	--disable-vdpau \
	$(addprefix --enable-decoder=,$(COMMON_DECODERS)) \
	$(addprefix --enable-demuxer=,$(COMMON_DEMUXERS)) \
	--enable-protocol=file \
	$(addprefix --enable-filter=,$(COMMON_FILTERS)) \
	--disable-bzlib \
	--disable-iconv \
	--disable-libxcb \
	--disable-lzma \
	--disable-sdl2 \
	--disable-securetransport \
	--disable-xlib \
	--enable-zlib



EMCC_COMMON_ARGS = \
	-O3 \
	--closure 1 \
	--memory-init-file 0 \
	-s WASM=0 \
	-s WASM_ASYNC_COMPILATION=0 \
	-s ASSERTIONS=0 \
	-s EXIT_RUNTIME=1 \
	-s NODEJS_CATCH_EXIT=0 \
	-s NODEJS_CATCH_REJECTION=0 \
	-s TOTAL_MEMORY=700mb \
	-lnodefs.js -lworkerfs.js \
	--pre-js $(PRE_JS) \
	-o $@
