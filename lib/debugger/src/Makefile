#
# %CopyrightBegin%
#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright Ericsson AB 1997-2025. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# %CopyrightEnd%
#
include $(ERL_TOP)/make/target.mk
include $(ERL_TOP)/make/$(TARGET)/otp.mk

# ----------------------------------------------------
# Application version
# ----------------------------------------------------
include ../vsn.mk
VSN=$(DEBUGGER_VSN)

# ----------------------------------------------------
# Release directory specification
# ----------------------------------------------------
RELSYSDIR = $(RELEASE_PATH)/lib/debugger-$(VSN)

# ----------------------------------------------------
# Common Macros
# ----------------------------------------------------

MODULES= \
	debugger \
	i \
	int \
	dbg_debugged \
	dbg_icmd \
	dbg_idb \
	dbg_ieval \
	dbg_iload \
	dbg_iserver \
	dbg_istk \
	dbg_wx_break \
	dbg_wx_break_win \
	dbg_wx_code \
	dbg_wx_filedialog_win \
	dbg_wx_interpret \
	dbg_wx_mon \
	dbg_wx_mon_win \
	dbg_wx_settings \
	dbg_wx_src_view \
	dbg_wx_trace \
	dbg_wx_trace_win \
	dbg_wx_view \
	dbg_wx_win \
	dbg_wx_winman


HRL_FILES=

INTERNAL_HRL_FILES= dbg_ieval.hrl dbg_wx_filedialog_win.hrl

ERL_FILES= $(MODULES:%=%.erl)

TARGET_FILES = $(MODULES:%=$(EBIN)/%.$(EMULATOR)) $(APP_TARGET) $(APPUP_TARGET)

#TOOLBOX_FILES= debugger.tool debugger.gif
#TARGET_TOOLBOX_FILES= $(EBIN)/debugger.tool $(EBIN)/debugger.gif

APP_FILE =  debugger.app
APPUP_FILE = debugger.appup

APP_SRC = $(APP_FILE).src
APPUP_SRC = $(APPUP_FILE).src

APP_TARGET = $(EBIN)/$(APP_FILE)
APPUP_TARGET = $(EBIN)/$(APPUP_FILE)

# ----------------------------------------------------
# FLAGS
# ----------------------------------------------------
ERL_COMPILE_FLAGS += -Werror -I $(ERL_TOP)/lib -pa $(ERL_TOP)/lib/wx/ebin


# ----------------------------------------------------
# Targets
# ----------------------------------------------------

$(TYPES): $(TARGET_FILES) $(TARGET_TOOLBOX_FILES)

clean:
	rm -f $(TARGET_FILES) $(TARGET_TOOLBOX_FILES)
	rm -f errs core *~

$(APP_TARGET): $(APP_SRC) ../vsn.mk
	$(vsn_verbose)sed -e 's;%VSN%;$(VSN);' $< > $@

$(APPUP_TARGET): $(APPUP_SRC) ../vsn.mk
	$(vsn_verbose)sed -e 's;%VSN%;$(VSN);' $< > $@

docs:

# ----------------------------------------------------
# Special Targets
# ----------------------------------------------------

# ----------------------------------------------------
# Release Target
# ---------------------------------------------------- 
include $(ERL_TOP)/make/otp_release_targets.mk

release_spec: opt
	$(INSTALL_DIR) "$(RELSYSDIR)/src"
	$(INSTALL_DATA) $(ERL_FILES) $(INTERNAL_HRL_FILES) $(TOOLBOX_FILES) "$(RELSYSDIR)/src"
	$(INSTALL_DIR) "$(RELSYSDIR)/ebin"
	$(INSTALL_DATA) $(TARGET_FILES) $(TARGET_TOOLBOX_FILES) "$(RELSYSDIR)/ebin"

release_docs_spec:

# ----------------------------------------------------
# Dependencies
# ----------------------------------------------------
include $(ERL_TOP)/make/dep.mk
