#
#   java-wrapper.make
#
#   Makefile rules to build a java wrapper for a GNUstep base library.
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk> 
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# prevent multiple inclusions
ifeq ($(JAVA_WRAPPER_MAKE_LOADED),)
JAVA_WRAPPER_MAKE_LOADED=yes

#
# Include this file after your library.make.
#
# Note the trick: we use the same variables the library uses.
# This way, we have access to all the variables and special settings 
# used to compile the library :-)
#
#

JAVA_WRAPPER_NAME:=$(strip $(LIBRARY_NAME))

ifeq ($(INTERNAL_java_wrapper_NAME),)

# This part gets included by the first invoked make process.
internal-all:: $(JAVA_WRAPPER_NAME:=.all.java-wrapper.variables)

internal-install:: $(JAVA_WRAPPER_NAME:=.install.java-wrapper.variables)

internal-uninstall:: $(JAVA_WRAPPER_NAME:=.uninstall.java-wrapper.variables)

internal-clean:: $(JAVA_WRAPPER_NAME:=.clean.java-wrapper.variables)

internal-distclean:: $(JAVA_WRAPPER_NAME:=.distclean.java-wrapper.variables)

java-wrapper-make::
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.java-wrapper.variables
else

#
# Targets
#
internal-java_wrapper-all:: before-$(TARGET)-all java-wrapper after-$(TARGET)-all

before-$(TARGET)-all::
	@if [ "$(shared)" = "no" ]; then \
	 echo "* WARNING *: Java Wrappers of static libraries are meaningless!";\
	fi

ifneq ($(BUILD_JAVA_WRAPPER_AUTOMATICALLY),no)

after-$(TARGET)-all::
	cd $(WRAPPER_DIR); unset MAKEFLAGS; $(MAKE)

install-java_wrapper::
	cd $(WRAPPER_DIR); unset MAKEFLAGS; $(MAKE) install

uninstall-java_wrapper::
	cd $(WRAPPER_DIR); unset MAKEFLAGS; $(MAKE) uninstall

endif # BUILD_JAVA_WRAPPER_AUTOMATICALLY

after-$(TARGET)-all::

internal-java_wrapper-install:: internal-java_wrapper-all install-java_wrapper

internal-install-java-dirs::

install-java_wrapper:: internal-install-java-dirs

uninstall-java_wrapper::

#
# The file containing instructions about which classes to wrap and how.
# A rule generates .jigs from .jobs if needed (TODO).
#
JIGS_FILE = $(LIBRARY_NAME).jigs


# The suffix to use for the wrapper library directory.
# NB: debug/profile refer to the library we are wrapping; the wrapper 
# library for simplicity is compiled with exactly the same flags.
TMP_LONG_SUFFIX = 

ifeq ($(debug), yes)
  TMP_LONG_SUFFIX =_debug
endif

ifeq ($(profile), yes)
  TMP_LONG_SUFFIX +=_profile
endif

JIGS_LONG_SUFFIX = $(shell echo $(TMP_LONG_SUFFIX) | sed 's/ //g')

# The directory to create and where to put the automatically generated 
# wrapper library
WRAPPER_DIR = $(shell pwd)/JavaWrapper$(JIGS_LONG_SUFFIX)
# The subdirs containing the java and the objc code
JAVA_WRAPPER_DIR = $(WRAPPER_DIR)/Java
OBJC_WRAPPER_DIR = $(WRAPPER_DIR)/Objc

# FIXME - this needs to remove 'lib' from the beginning of the name
LIBRARY_SHORT_NAME = $(subst lib,,$(LIBRARY_NAME))

# This is a wild guess which usually needs to be corrected 
# in GNUmakefile.wrapper.  It is the header which should include 
# all the declarations of the classes you want to expose
ifeq ($(HEADER_FILES_DIR),)
WRAPPER_HEADER = $(LIBRARY_SHORT_NAME).h
else
WRAPPER_HEADER = $(HEADER_FILES_DIR)/$(LIBRARY_SHORT_NAME).h
endif

WRAP_CREATOR = opentool WrapCreator

# Run WrapCreator in silent mode if `verbose=no' was passed on the
# make command line
ifeq ($(verbose), no)
  SILENT_FLAGS = --no-verbose
endif

# Ask WrapCreator not to generate javadoc comments if `javadoc=no' was passed
# on the make command line
ifeq ($(javadoc), no)
  SILENT_FLAGS = --no-javadoc
endif

# The following should override, if needed: 
# JIGS_FILE, WRAPPER_DIR, WRAPPER_HEADER
-include GNUmakefile.wrapper

#
# This is needed to remake only if the library changed.
# It must be kept in sync with library.make
#
LIBRARY_FILE = $(LIBRARY_NAME)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE).$(VERSION)

#
# We copy the RPM .spec.in and .script.in files 
#
ifeq ($(debug),yes)
  JAVA_WRAPPER_TOP_TEMPLATE=java-wrapper.top.debug.template
  WRAPPER_SPEC_IN_FILE=$(PACKAGE_NAME)-wrapper-debug.spec.in
  WRAPPER_SCRIPT_IN_FILE=$(PACKAGE_NAME)-wrapper-debug.script.spec.in
  WRAPPER_REQUIRES="Requires: $(PACKAGE_NAME)-wrapper = $(VERSION)"
else
  JAVA_WRAPPER_TOP_TEMPLATE=java-wrapper.top.template
  WRAPPER_SPEC_IN_FILE=$(PACKAGE_NAME)-wrapper.spec.in
  WRAPPER_SCRIPT_IN_FILE=$(PACKAGE_NAME)-wrapper.script.spec.in
  WRAPPER_REQUIRES=""
endif

java-wrapper:: $(WRAPPER_DIR)/stamp-file

$(WRAPPER_DIR)/stamp-file:: $(JIGS_FILE) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE)
	@echo Creating the Wrapper Directories and GNUmakefiles...
	@$(MKDIRS) $(WRAPPER_DIR)
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/$(JAVA_WRAPPER_TOP_TEMPLATE)   \
	      $(WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/PACKAGEHERE/$(PACKAGE_NAME)/g' $(WRAPPER_DIR)/GNUmakefile.tmp   \
	      > $(WRAPPER_DIR)/GNUmakefile 
	@rm $(WRAPPER_DIR)/GNUmakefile.tmp
	@mv $(WRAPPER_DIR)/GNUmakefile $(WRAPPER_DIR)/GNUmakefile.tmp 
	@sed -e 's/VERSIONHERE/$(VERSION)/g' $(WRAPPER_DIR)/GNUmakefile.tmp   \
	      > $(WRAPPER_DIR)/GNUmakefile 
	@rm $(WRAPPER_DIR)/GNUmakefile.tmp
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/java-wrapper.readme.template       \
	      $(WRAPPER_DIR)/README
	@$(MKDIRS) $(JAVA_WRAPPER_DIR)
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/java-wrapper.java.template         \
	      $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/DEBUGHERE/$(debug)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp        \
	        > $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp.2
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/PROFILEHERE/$(profile)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp.2        \
	        > $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp.2
	@sed -e 's/JAVADOCHERE/$(javadoc)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp        \
	        > $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp.2
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/REPLACEME/$(LIBRARY_NAME)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp.2          \
	        > $(JAVA_WRAPPER_DIR)/GNUmakefile
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp.2
	@$(MKDIRS) $(OBJC_WRAPPER_DIR)
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/java-wrapper.objc.template         \
	      $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp 
	@sed -e 's/DEBUGHERE/$(debug)/g'           \
	       $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp        \
	        > $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2
	@rm $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/PROFILEHERE/$(profile)/g'           \
	       $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2        \
	        > $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp
	@rm $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2
	@sed -e 's/VERSIONHERE/$(VERSION)/g'           \
	       $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp        \
	        > $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2
	@rm $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/REPLACEME/$(LIBRARY_NAME)/g' \
	      $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2 \
	      > $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp
	@rm $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2
	@sed -e 's/REPLACEWITHSHORTNAME/$(LIBRARY_SHORT_NAME)/g'           \
	      $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp                          \
	      > $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2
	@rm $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/REPLACEWITHLIBRARYHEADERDIRS/$(HEADER_FILES_DIR)/g'      \
	      $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2                         \
	      > $(OBJC_WRAPPER_DIR)/GNUmakefile
	@rm $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2
	@echo Copying Custom GNUmakefiles...
	@if [ -f GNUmakefile.wrapper.java.preamble ]; then           \
	  $(INSTALL_DATA) GNUmakefile.wrapper.java.preamble         \
	                  $(JAVA_WRAPPER_DIR)/GNUmakefile.preamble; \
        fi;
	@if [ -f GNUmakefile.wrapper.java.postamble ]; then           \
	  $(INSTALL_DATA) GNUmakefile.wrapper.java.postamble         \
	                  $(JAVA_WRAPPER_DIR)/GNUmakefile.postamble; \
        fi;
	@if [ -f GNUmakefile.wrapper.objc.preamble ]; then           \
	  $(INSTALL_DATA) GNUmakefile.wrapper.objc.preamble         \
	                  $(OBJC_WRAPPER_DIR)/GNUmakefile.preamble; \
        fi;
	@if [ -f GNUmakefile.wrapper.objc.postamble ]; then           \
	  $(INSTALL_DATA) GNUmakefile.wrapper.objc.postamble         \
	                  $(OBJC_WRAPPER_DIR)/GNUmakefile.postamble; \
        fi;
	@if [ -f $(WRAPPER_SPEC_IN_FILE) ]; then              \
	  echo "Copying $(WRAPPER_SPEC_IN_FILE)...";          \
	  cp $(WRAPPER_SPEC_IN_FILE) $(WRAPPER_DIR);          \
	  echo "Adding RPM dependency on $(PACKAGE_NAME)-wrapper"; \
	  mv $(WRAPPER_DIR)/$(WRAPPER_SPEC_IN_FILE) $(WRAPPER_DIR)/spec.tmp; \
	  echo "$(WRAPPER_REQUIRES)" > $(WRAPPER_DIR)/$(WRAPPER_SPEC_IN_FILE);\
	  cat $(WRAPPER_DIR)/spec.tmp >> $(WRAPPER_DIR)/$(WRAPPER_SPEC_IN_FILE); \
	  rm $(WRAPPER_DIR)/spec.tmp; \
	fi
	@if [ -f $(WRAPPER_SCRIPT_IN_FILE) ]; then              \
	  echo "Copying $(WRAPPER_SCRIPT_IN_FILE)...";          \
	  cp $(WRAPPER_SCRIPT_IN_FILE) $(WRAPPER_DIR);          \
	fi
	@echo Running the preprocessor on the header file...
	$(CC) $(WRAPPER_HEADER) -E $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) \
	      -o $(WRAPPER_DIR)/preprocessedHeader
	@echo Generating the code with Wrap Creator...
	$(WRAP_CREATOR) --jigs-file $(JIGS_FILE) \
	                --wrapper-dir $(WRAPPER_DIR) \
	                --preprocessed-header $(WRAPPER_DIR)/preprocessedHeader \
	                --library-name $(LIBRARY_NAME) \
	                --library-header $(WRAPPER_HEADER) \
	         	$(SILENT_FLAGS)
	@echo Removing the temporary preprocessor header...
	@rm $(WRAPPER_DIR)/preprocessedHeader
	@echo Creating the stamp file...
	@touch $(WRAPPER_DIR)/stamp-file
	@echo 
	@if [ "$(BUILD_JAVA_WRAPPER_AUTOMATICALLY)" = "no" ]; then           \
	  echo "To compile and install the wrapper library, please go into"; \
	  echo "the $(WRAPPER_DIR) directory,";                              \
	  echo "and make, make install there.";                              \
	  echo "Add \`BUILD_JAVA_WRAPPER_AUTOMATICALLY=yes' to the makefile";\
	  echo "if you want me to do this for you automatically next time";  \
	else                                                                 \
	  echo "Now trying to automatically compile the wrapper library for you..."; \
	  echo "Add \`BUILD_JAVA_WRAPPER_AUTOMATICALLY=no' in the makefile to disable this."; \
	fi
	@echo

#
# Cleaning targets
#
internal-java_wrapper-clean::
	rm -Rf $(WRAPPER_DIR)

internal-java_wrapper-distclean::
	-rm -Rf $(shell pwd)/JavaWrapper
	-rm -Rf $(shell pwd)/JavaWrapper_debug
	-rm -Rf $(shell pwd)/JavaWrapper_profile
	-rm -Rf $(shell pwd)/JavaWrapper_debug_profile

endif # INTERNAL_java_wrapper_NAME

endif # java-wrapper.make loaded

## Local variables:
## mode: makefile
## End:


