.PHONY: all
all: twofa

.PHONY: twofa
twofa:
	./build.sh
	mv ./.build/x86_64-apple-macosx10.10/release/{TwoFa,twofa}

# This rule tells make to delete hello and hello.o
.PHONY: clean
clean:
	rm -f .build