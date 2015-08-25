PACKAGE_NAME := WrenchFu-Demo
VERSION_STRING := $(if $(VERSION),$(VERSION),$(error "No version supplied, please add it as 'VERSION=x.y.z'"))

OUTPUT_NAME := $(PACKAGE_NAME)_$(VERSION_STRING)
OUTPUT_DIR := pkg/$(OUTPUT_NAME)

# Files and folders that just need to be present in the output with no changes whatsoever.
PKG_FILES := $(wildcard *.md)
PKG_DIRS := locale

# Files that need to be put through the sed replacements for supported {{tags}}
SED_FILES := $(shell find . -iname '*.json' -type f) $(shell find . -iname '*.lua' -type f)
OUT_FILES := $(SED_FILES:%=$(OUTPUT_DIR)/%)

all: package

$(OUTPUT_DIR)/%: %
	@mkdir -p $(@D)
	sed -e 's/{{VERSION}}/$(VERSION_STRING)/g' $< > $@

package-copy: $(PKG_DIRS) $(PKG_FILES)
	mkdir -p $(OUTPUT_DIR)
ifneq ($(PKG_DIRS),)
	cp -r $(PKG_DIRS) pkg/$(OUTPUT_NAME)
endif
ifneq ($(PKG_FILES),)
	cp $(PKG_FILES) pkg/$(OUTPUT_NAME)
endif

package: package-copy $(OUT_FILES)
	cd pkg && zip -mr $(OUTPUT_NAME).zip $(OUTPUT_NAME)

clean:
	rm -rf pkg/$(OUTPUT_NAME).zip
