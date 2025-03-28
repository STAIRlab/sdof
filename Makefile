
src/sdof/_spectrum%so: src/_spectrum.c src/_integrate.c Makefile
	# clang -DC11THREADS -std=c11 -O3 -o thread src/spectrum.c src/_integrate.c
	gcc -std=c99 -fPIC -O3 -Wall -Wextra -pedantic \
	    -shared -o $@ \
	    src/_spectrum.c src/_integrate.c -lpthread

src/sdof/_integrate.%.so: src/_integrate.c Makefile
	 cc -std=c99 -pedantic -Wall -Wextra -shared -O3 src/_integrate.c -o $@  -fPIC -lm \
	    -fno-math-errno -fno-signaling-nans -fno-trapping-math \
	    -fassociative-math -ffast-math

src/sdof/_integrate.s: src/_integrate.c Makefile
	 cc -S -std=c99 -pedantic -Wall -Wextra -O3 src/_integrate.c -o $@   \
	    -fno-math-errno -fno-signaling-nans -fno-trapping-math \
	    -fassociative-math -ffast-math -march=native


fsdof.js:
	mkdir -p dist/
	emcc src/_spectrum.c src/_integrate.c -O3 -lm -o wasm/fsdof.js \
		-s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -s SINGLE_FILE=1 \
		-s EXPORTED_FUNCTIONS="['_sdof_integrate','_sdof_spectrum','_malloc','_free']" \
		-sINCOMING_MODULE_JS_API="['onRuntimeInitialized']" \
		-s EXPORTED_RUNTIME_METHODS="['cwrap','getValue','setValue']"

docs/_static/js/sdof.js: src/_integrate.c src/_spectrum.c
	mkdir -p dist/
	emcc src/_spectrum.c src/_integrate.c -O3 -pthread -lm -o $@ \
		-s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -s SINGLE_FILE=1 \
		-s EXPORTED_FUNCTIONS="['_sdof_integrate','_sdof_spectrum','_malloc','_free']" \
		-sINCOMING_MODULE_JS_API="['onRuntimeInitialized']" \
		-s EXPORTED_RUNTIME_METHODS="['cwrap','getValue','setValue']"

# src/sdof/_integrate.%.so: src/_integrate.c Makefile
# 	 gcc -g -fsanitize=address -std=c99 -pedantic -Wall -Wextra -shared -Og src/_integrate.c -o $@  -fPIC -lm


thread: src/_spectrum.c src/_integrate.c
	# clang -DC11THREADS -std=c11 -O3 -o thread src/tsdof.c src/fsdof.c
	gcc -std=c11 -DHAVE_MAIN -O3 -o thread src/_spectrum.c src/_integrate.c -lpthread


#
# Documentation
#
publish:
	cp -r _build/html/* site/
	git add site && git commit -m'cmp - rebuild site' && git subtree push --prefix site/ origin gh-pages
		 
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = docs
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)


# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)


.PHONY: help Makefile publish
