#
#   java-wrapper.make
#
#   Makefile rules to build a java wrapper for a GNUstep base library.
#
#   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
#
#   This file is part of JIGS, the GNUstep Java Interface
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
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make


# The name of the java wrapper is in the JAVA_WRAPPER_NAME variable.
# This name must be the same as the name of the library you want to
# wrap, with the leading `lib' removed, such as `gnustep-base' when
# you wrap the libgnustep-base library.

# Assuming that xxx is the name of the java wrapper:

# The name of the header file of the library to wrap is in the
# xxx_HEADER_FILES variable.  If you don't set it, xxx.h is assumed.
# Please note that it should be a single header.
# It should be in the full form you use for including it into C source
# code, such as in `Foundation/Foundation.h'.  It must be in this form
# because it *will* end up in a C source file :-).

# The name of the directory where the library header file is located
# is in the xxx_HEADER_FILES_DIR (eg, ../Nicola/).  If not specified,
# then the current directory is searched; failing that,
# $GNUSTEP_SYSTEM_ROOT/Headers, $GNUSTEP_NETWORK_ROOT/Headers,
# $GNUSTEP_LOCAL_ROOT/Headers and $GNUSTEP_USER_ROOT/Headers are
# searched.

# Put any special -I flags needed to read the library header files in
# the xxx_ADDITIONAL_CPP_FLAGS - these are the same flags you would
# need to use in any library/application compiled against this
# library.

# If your library is installed in a standard location, it will be
# found.  Otherwise, you might specify any additional -L directives
# needed by using ADDITIONAL_LIB_DIRS in your
# GNUmakefile.wrapper.objc.postamble.  For example, if you are creating the
# wrappers on site with the library, you need to use
# ADDITIONAL_LIB_DIRS = -L../../$(GNUSTEP_OBJ_DIR)
# in GNUmakefile.wrapper.objc.postamble.

# The name of the wrapper dir is JavaWrapper or JavaWrapper_debug if
# you use debugging; you can modify it by setting the WRAPPER_DIR_NAME
# variable.


JAVA_WRAPPER_NAME:=$(strip $(JAVA_WRAPPER_NAME))


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
internal-java_wrapper-all:: before-$(TARGET)-all java-wrapper \
                               after-$(TARGET)-all

before-$(TARGET)-all::
	@if [ "$(shared)" = "no" ]; then \
	 echo "* WARNING *: static Java Wrappers are meaningless!";\
	fi

ifneq ($(BUILD_JAVA_WRAPPER_AUTOMATICALLY),no)

after-$(TARGET)-all::
	cd $(WRAPPER_DIR); unset MAKEFLAGS; $(MAKE)

internal-java_wrapper-install::
	cd $(WRAPPER_DIR); unset MAKEFLAGS; $(MAKE) install

internal-java_wrapper-uninstall::
	cd $(WRAPPER_DIR); unset MAKEFLAGS; $(MAKE) uninstall

else 

after-$(TARGET)-all::

internal-java_wrapper-install::

internal-java_wrapper-uninstall::

endif # BUILD_JAVA_WRAPPER_AUTOMATICALLY

#
# The file containing instructions about which classes to wrap and how.
# A rule generates .jigs from .jobs if needed (TODO).
#
JIGS_FILE = $(JAVA_WRAPPER_NAME).jigs

# The suffix to use for the wrapper library directory.  NB: you are
# warned to use the same flags (debug/profile) you used for the
# library you are wrapping 
TMP_LONG_SUFFIX =

ifeq ($(debug), yes)
  TMP_LONG_SUFFIX =_debug
endif

ifeq ($(profile), yes)
  TMP_LONG_SUFFIX +=_profile
endif

# Replace space with nothing
empty_j:=
space_j:= $(empty_j) $(empty_j)
JIGS_LONG_SUFFIX = $(subst $(space_j),,$(TMP_LONG_SUFFIX))

# The directory to create and where to put the automatically generated 
# wrapper library
ifeq ($(WRAPPER_DIR_NAME),)
WRAPPER_DIR_NAME = JavaWrapper$(JIGS_LONG_SUFFIX)
endif
WRAPPER_DIR = $(shell pwd)/$(WRAPPER_DIR_NAME)
# The subdirs containing the java and the objc code
JAVA_WRAPPER_DIR = $(WRAPPER_DIR)/Java
OBJC_WRAPPER_DIR = $(WRAPPER_DIR)/Objc

# The name of the library we are wrapping
LIBRARY_NAME = lib$(JAVA_WRAPPER_NAME)

# The header file - please note that you can only use a single one
ifeq ($(HEADER_FILES),)
HEADER_FILE = $(JAVA_WRAPPER_NAME).h
else
HEADER_FILE = $(HEADER_FILES)
endif

# Try to find the header file - WRAPPER_HEADER is the full absolute
# path of the header file.  NB: in the rule which uses WRAPPER_HEADER,
# we check that it is non-null - it is null if it couldn't be found.
# That check should *not* be moved here, because otherwise the check
# would be done always - which is more inefficient and would also
# prevent other targets (eg, make distclean) from working just because
# the header is not found.
WRAPPER_HEADER = $(shell $(GNUSTEP_MAKEFILES)/search_header.sh \
                          $(HEADER_FILE) $(HEADER_FILES_DIR))
LIBRARY_HEADER_FLAGS = -I$(dir $(WRAPPER_HEADER))

WRAP_CREATOR = opentool WrapCreator

# Run WrapCreator in silent mode unless `verbose=yes' was passed on the
# make command line
ifneq ($(verbose), yes)
  SILENT_FLAGS = --no-verbose
endif

# Ask WrapCreator not to generate javadoc comments if `javadoc=no' was passed
# on the make command line
ifeq ($(javadoc), no)
  SILENT_FLAGS += --no-javadoc
endif

ifeq ($(debug),yes)
  JAVA_WRAPPER_TOP_TEMPLATE=java-wrapper.top.debug.template
else
  JAVA_WRAPPER_TOP_TEMPLATE=java-wrapper.top.template
endif

java-wrapper:: $(WRAPPER_DIR)/stamp-file

$(WRAPPER_DIR)/stamp-file:: $(JIGS_FILE)
	@if [ -z "$(WRAPPER_HEADER)" ]; then \
	  echo "Could not find wrapper header $(HEADER_FILE)"; \
	  exit 1; \
	 fi;
	@echo Creating the Wrapper Directories and GNUmakefiles...
	@$(MKDIRS) $(WRAPPER_DIR)
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/$(JAVA_WRAPPER_TOP_TEMPLATE) \
	                 $(WRAPPER_DIR)/GNUmakefile
ifneq ($(GNUSTEP_INSTALLATION_DIR),)
	@mv $(WRAPPER_DIR)/GNUmakefile $(WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e \
	 's/# GNUSTEP_INSTALLATION_DIR =/GNUSTEP_INSTALLATION_DIR = $(subst /,\/,$(GNUSTEP_INSTALLATION_DIR))/' \
	       $(WRAPPER_DIR)/GNUmakefile.tmp > $(WRAPPER_DIR)/GNUmakefile
	@rm $(WRAPPER_DIR)/GNUmakefile.tmp
endif
ifneq ($(INSTALL_AS_USER),)
	@mv $(WRAPPER_DIR)/GNUmakefile $(WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e \
	 's/# INSTALL_AS_USER =/export INSTALL_AS_USER = $(INSTALL_AS_USER)/' \
	       $(WRAPPER_DIR)/GNUmakefile.tmp > $(WRAPPER_DIR)/GNUmakefile
	@rm $(WRAPPER_DIR)/GNUmakefile.tmp
endif
ifneq ($(INSTALL_AS_GROUP),)
	@mv $(WRAPPER_DIR)/GNUmakefile $(WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e \
	 's/# INSTALL_AS_GROUP =/export INSTALL_AS_GROUP = $(INSTALL_AS_GROUP)/' \
	       $(WRAPPER_DIR)/GNUmakefile.tmp > $(WRAPPER_DIR)/GNUmakefile
	@rm $(WRAPPER_DIR)/GNUmakefile.tmp
endif
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/java-wrapper.readme.template \
	                 $(WRAPPER_DIR)/README
	@$(MKDIRS) $(JAVA_WRAPPER_DIR)
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/java-wrapper.java.template \
	                 $(JAVA_WRAPPER_DIR)/GNUmakefile
	@mv $(JAVA_WRAPPER_DIR)/GNUmakefile $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/DEBUGHERE/$(debug)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp \
	       > $(JAVA_WRAPPER_DIR)/GNUmakefile
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@mv $(JAVA_WRAPPER_DIR)/GNUmakefile $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/PROFILEHERE/$(profile)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp \
	        > $(JAVA_WRAPPER_DIR)/GNUmakefile
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@mv $(JAVA_WRAPPER_DIR)/GNUmakefile $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/JAVADOCHERE/$(javadoc)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp \
	        > $(JAVA_WRAPPER_DIR)/GNUmakefile
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@mv $(JAVA_WRAPPER_DIR)/GNUmakefile $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/REPLACEME/$(LIBRARY_NAME)/g'           \
	       $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp \
	        > $(JAVA_WRAPPER_DIR)/GNUmakefile
	@rm $(JAVA_WRAPPER_DIR)/GNUmakefile.tmp
	@$(MKDIRS) $(OBJC_WRAPPER_DIR)
	@$(INSTALL_DATA) $(GNUSTEP_MAKEFILES)/java-wrapper.objc.template \
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
	@sed -e 's/REPLACEWITHSHORTNAME/$(JAVA_WRAPPER_NAME)/g'  \
	      $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp   \
	      > $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2
	@rm $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp
	@sed -e 's/REPLACEWITHLIBRARYHEADERFLAGS/$(subst /,\/,$(LIBRARY_HEADER_FLAGS))/g'   \
	      $(OBJC_WRAPPER_DIR)/GNUmakefile.tmp.2        \
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
	@echo Running the preprocessor on the header file...
	$(CC) $(WRAPPER_HEADER) -E -P $(filter-out -MMD -MP, \
	   $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS)) \
	      -o $(WRAPPER_DIR)/preprocessedHeader
	@echo Generating the code with Wrap Creator...
	$(WRAP_CREATOR) --jigs-file $(JIGS_FILE) \
	                --wrapper-dir $(WRAPPER_DIR) \
	                --preprocessed-header $(WRAPPER_DIR)/preprocessedHeader \
	                --library-name $(LIBRARY_NAME) \
	                --library-header $(HEADER_FILE) \
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
	else                                                                 \
	  echo "Now automatically compiling the wrapper library for you..."; \
	fi
	@echo

#
# Cleaning targets
#
internal-java_wrapper-clean::
	rm -Rf $(WRAPPER_DIR)

internal-java_wrapper-distclean::
	-rm -Rf JavaWrapper
	-rm -Rf JavaWrapper_debug
	-rm -Rf JavaWrapper_profile
	-rm -Rf JavaWrapper_debug_profile

endif # INTERNAL_java_wrapper_NAME

endif # java-wrapper.make loaded

## Local variables:
## mode: makefile
## End:


