include $(PORT_BUILD)/localvar.mk

#> Start of global variable
# The global variable could be used in local makefile, and the name
# would not be changed in future
SHELL       := /bin/bash
TMP_DIR     := out
ZIP_DIR     := $(TMP_DIR)/ZIP
OUT_ZIP     := $(TMP_DIR)/$(OUT_ZIP_FILE)
TOOL_DIR    := $(PORT_ROOT)/tools
PROP_FILE   := $(ZIP_DIR)/system/build.prop
SKIA_FILE	:= $(ZIP_DIR)/system/lib/libskia.so
SYSOUT_DIR  := $(OUT_SYS_PATH)
DATAOUT_DIR  := $(OUT_DATA_PATH)
STOCKROM_DIR := $(basename $(ZIP_FILE))

# Tool alias used in the makefile
APKTOOL     := $(TOOL_DIR)/apktool $(APK_VERBOSE)
AAPT        := $(TOOL_DIR)/aapt
SIGN        := $(TOOL_DIR)/sign.sh $(VERBOSE)
ADDLEWA     := $(TOOL_DIR)/add_lewa_smail.sh $(VERBOSE)
PREPARE_PRELOADED_CLASSES := $(TOOL_DIR)/prepare_preloaded_classes.sh $(VERBOSE)
ADDLEWARES  := $(TOOL_DIR)/add_lewa_res.sh $(VERBOSE)
PATCH_LEWA_APP  := $(TOOL_DIR)/patch_lewa_app.sh $(VERBOSE)
FIX_9PATCH_PNG  := $(TOOL_DIR)/fix_9patch_png.sh $(VERBOSE)
SETPROP     := $(TOOL_DIR)/set_build_prop.sh
REWRITE		:= $(TOOL_DIR)/rewrite.py
UNZIP       := unzip $(VERBOSE)
ZIP         := zip $(VERBOSE)
MERGE_RES   := $(TOOL_DIR)/ResValuesModify/jar/ResValuesModify $(VERBOSE)
MERGE_RULE  := $(TOOL_DIR)/ResValuesModify/jar/config
RM_REDEF    := $(TOOL_DIR)/remove_redef.py $(VERBOSE)
PATCH_LEWA_FRAMEWORK  := $(TOOL_DIR)/patch_lewa_framework.sh $(INFO)
RLZ_SOURCE  := $(TOOL_DIR)/release_source.sh $(VERBOSE)
FIX_PLURALS := $(TOOL_DIR)/fix_plurals.sh $(VERBOSE)
RESTORE_OBSOLETE_KEYGUARD := $(TOOL_DIR)/restore_obsolete_keyguard.sh $(VERBOSE)
BUILD_TARGET_FILES := $(TOOL_DIR)/build_target_files.sh $(INFO)
ADB         := adb
#< End of global variable

ROM_BUILD_NUMBER  := $(shell date +%y.%m.%d)

ifeq ($(USE_ANDROID_OUT),true)
    LEWA_SRC_DIR:=$(ANDROID_TOP)
else
    LEWA_SRC_DIR:=$(PORT_ROOT)/lewa/src
endif
LEWA_OVERLAY_RES_DIR:=$(LEWA_SRC_DIR)/frameworks/lewa/overlay/frameworks/base/core/res/res
LEWA_RES_DIR:=$(LEWA_SRC_DIR)/frameworks/lewa/core/res/res
OVERLAY_RES_DIR:=overlay/framework-res/res  $(LEWA_OVERLAY_RES_DIR)
OVERLAY_LEWA_RES_DIR:=overlay/lewa-res/res

JARS        := $(LEWA_JARS) $(PHONE_JARS)
BLDAPKS     := $(addprefix $(TMP_DIR)/,$(addsuffix .apk,$(APPS)))
JARS_OUTDIR := $(addsuffix .jar.out,$(LEWA_JARS))
APPS_OUTDIR := $(APPS) framework-res
BLDJARS     := $(addprefix $(TMP_DIR)/,$(addsuffix .jar,$(JARS)))
PHN_BLDJARS := $(addsuffix -phone,$(BLDJARS))
ZIP_BLDJARS := $(addsuffix -tozip,$(BLDJARS))

SIGNAPKS    := 
TOZIP_APKS  :=
CLEANJAR    :=
CLEANLEWAAPP:=
RELEASE_LEWA:=
RELEASE_PATH:= $(PORT_ROOT)/lewa
MAKE_ATTOP  := make -C $(ANDROID_TOP)

# helper functions
define all-files-under-dir
$(strip $(filter-out $(1),$(shell find $(1) -name "*.*" 2>/dev/null)))
endef

#
# Extract the jar file from ZIP file and replaced the modified smails
# with LEWA features, and these smali files are stored in xxxx.jar.out
# $1: the jar name, such as services
# $2: the dir under build for apktool-decoded files, such as .build/services
define JAR_template
$(TMP_DIR)/$(1).jar-phone:$(TMP_DIR)/$(1).jar
	$(ADB) remount
	$(ADB) shell stop
	$(ADB) push $$< /system/framework/$(1).jar
	$(ADB) shell start

$(TMP_DIR)/$(1).jar-tozip:$(TMP_DIR)/$(1).jar
	$(hide) cp $$< $(ZIP_DIR)/system/framework/$(1).jar
	@touch $$@

source-files-for-$(1) := $$(call all-files-under-dir,$(1).jar.out)

$(TMP_DIR)/$(1).jar: $(2)_lewa $$(source-files-for-$(1))
	@echo ">>> build $$@..."
	$(hide) rm -rf $(2)
	$(hide) cp -r $(1).jar.out/ $(2)
	$(ADDLEWA) $(2)_lewa $(2)
	$(APKTOOL) b $(2) $$@
	$(PREPARE_PRELOADED_CLASSES) $(ZIP_FILE) $(2) $(OUT_JAR_PATH)
	$(hide) if [ -f $(1).jar.out/preloaded-classes ]; then \
		jar -uf $$@ -C $(1).jar.out preloaded-classes; \
	elif [ -f $(2)/preloaded-classes ];then \
		jar -uf $$@ -C $(2) preloaded-classes; \
	fi
	@echo "<<< build $$@ completed!"

$(2)_lewa: $(OUT_JAR_PATH)/$(1).jar
	$(APKTOOL) d -f $$< $$@

ifeq ($(USE_ANDROID_OUT),true)
$(OUT_JAR_PATH)/$(1).jar: $(ERR_REPORT)
	$(MAKE_ATTOP) $(1)

CLEANJAR += clean-$(1)
clean-$(1):
	$(MAKE_ATTOP) clean-$(1)

RELEASE_LEWA += $(RELEASE_PATH)/$(DENSITY)/system/framework/$(1).jar
$(RELEASE_PATH)/$(DENSITY)/system/framework/$(1).jar: $(OUT_JAR_PATH)/$(1).jar
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/framework
	$(hide) cp $$< $$@
endif

# targets for initial workspace
$(1).jar.out:  $(ZIP_FILE)
	$(UNZIP) $(ZIP_FILE) system/framework/$(1).jar -d $(TMP_DIR)
	$(APKTOOL) d -f $(TMP_DIR)/system/framework/$(1).jar $$@
	$(hide) rm $(TMP_DIR)/system/framework/$(1).jar

endef

#
# Template to apktool-build the jar-file that is from phone(i.e, not LEWA)
# the decoded smali files are located at JARNAME.jar.out
# $1: the jar name, such as framework2
define JAR_PHONE_template
$(TMP_DIR)/$(1).jar-phone:$(TMP_DIR)/$(1).jar
	$(ADB) push $$< /system/framework/$(1).jar

$(TMP_DIR)/$(1).jar-tozip:$(TMP_DIR)/$(1).jar
	$(hide) cp $$< $(ZIP_DIR)/system/framework/$(1).jar
	@touch $$@

source-files-for-$(1) := $$(call all-files-under-dir,$(1).jar.out)
$(TMP_DIR)/$(1).jar: $$(source-files-for-$(1)) | $(TMP_DIR)
	@echo ">>> build $$@..."
	#$(hide) rm -rf $(TMP_DIR)/$(1).jar.out
	$(hide) cp -r $(1).jar.out $(TMP_DIR)/
	$(APKTOOL) b $(TMP_DIR)/$(1).jar.out $$@
	@echo "<<< build $$@ completed!"

endef

#
# To apktool build one apk from the decoded dirctory under .build
# $1: the apk name, such as LogsProvider
# $2: the dir name, might be different from apk name
# $3: to specify if the smali files should be decoded from LEWA first
# $4: to specify app dir, for kitkat only
define APP_template
source-files-for-$(2) := $$(call all-files-under-dir,$(2))
$(TMP_DIR)/$(1).apk: $$(source-files-for-$(2)) $(3) | $(TMP_DIR)
	@echo ">>> build $$@..."
	$(hide) cp -r $(2) $(TMP_DIR)
	$(hide) find $(TMP_DIR)/$(2) -name "*.part" -exec rm {} \;
	$(hide) find $(TMP_DIR)/$(2) -name "*.smali.method" -exec rm {} \;
	$(APKTOOL) b  $(TMP_DIR)/$(2) $$@
	@echo "9Patch png fix $$@..."
ifeq ($(3),)
	$(FIX_9PATCH_PNG) $(1) $(STOCKROM_DIR)/system/$(4) $(TMP_DIR)
else
	$(FIX_9PATCH_PNG) $(1) $(OUT_APK_PATH:app=$(4)) $(TMP_DIR) $(1)/res
endif
	@echo "fix $$@ completed!"
	@echo "<<< build $$@ completed!"

$(3): $(OUT_APK_PATH:app=$(4))/$(1).apk
	$(hide) rm -rf $(3)
	$(APKTOOL) d -t lewa -f $(OUT_APK_PATH:app=$(4))/$(1).apk $(3)
	$(hide) sed -i "/tag:/d" $(3)/apktool.yml
	$(PATCH_LEWA_APP) $(2) $(3)

endef

# Target to build framework-res.apk
# copy the framework-res, add the lewa overlay then build
#TODO need to add changed files for all related, and re-install framework-res.apk make sense?
framework-res-source-files := $(call all-files-under-dir,framework-res)
framework-res-overlay-files:= $(call all-files-under-dir,$(LEWA_OVERLAY_RES_DIR)) $(call all-files-under-dir,overlay)

$(TMP_DIR)/framework-res.apk: $(TMP_DIR)/apktool-if $(framework-res-source-files) $(framework-res-overlay-files)
	@echo ">>> build $@..."
	$(hide) rm -rf $(TMP_DIR)/framework-res
	$(hide) cp -r framework-res $(TMP_DIR)
	#for call ./customize_framework-res.sh
	$(hide) $(ADDLEWARES) $(TMP_DIR)/framework-res/res $(TMP_DIR)/framework-res/res
	$(hide) $(AAPT) p -f -x --min-sdk-version $(subst v,,$(ANDROID_PLATFORM)) --target-sdk-version $(subst v,,$(ANDROID_PLATFORM)) \
		$(addprefix -S ,$(wildcard $(OVERLAY_RES_DIR))) \
		-S $(TMP_DIR)/framework-res/res -A $(TMP_DIR)/framework-res/assets \
		-M $(TMP_DIR)/framework-res/AndroidManifest.xml -F $@
	@echo "9Patch png fix $@..."
	#$(FIX_9PATCH_PNG) framework-res $(STOCKROM_DIR)/system/framework $(TMP_DIR) $(LEWA_OVERLAY_RES_DIR) $(OVERLAY_RES_DIR)
	@echo "fix $@ completed!"
	$(APKTOOL) if $@
	@echo "<<< build $@ completed!"

# Target to build lewa-res.apk
$(TMP_DIR)/lewa-res.apk: $(TMP_DIR)/framework-res.apk $(OUT_JAR_PATH)/lewa-res.apk
	@echo ">>> build $@..."
	$(hide) rm -rf $(TMP_DIR)/lewa-res
	$(APKTOOL) d -f -t lewa $(OUT_JAR_PATH)/lewa-res.apk $(TMP_DIR)/lewa-res
	$(hide) sed -i "/tag:/d" $(TMP_DIR)/lewa-res/apktool.yml
	$(hide) rm -rf $(TMP_DIR)/lewa-res/res
	$(hide) sed -i "s/- 1/- 1\n  - 2\n  - 3\n  - 4\n  - 5\n  - 6\n  - 7\n  - 8/g" $(TMP_DIR)/lewa-res/apktool.yml
	$(hide) $(AAPT) p -f -x --auto-add-overlay \
		--min-sdk-version $(subst v,,$(ANDROID_PLATFORM)) --target-sdk-version $(subst v,,$(ANDROID_PLATFORM)) \
        $(addprefix -S ,$(wildcard $(OVERLAY_LEWA_RES_DIR))) \
		-S $(LEWA_RES_DIR) -M $(TMP_DIR)/lewa-res/AndroidManifest.xml \
		-I $(APKTOOL_IF_RESULT_FILE)/1.apk -I $(APKTOOL_IF_RESULT_FILE)/8.apk -F $@
	@echo "<<< build $@ completed!"

#
# To prepare the workspace to modify the APKs from zip file
# $1 the apk name, also the dir name to save the smali files
# $2 the apk location under system, such as app or framework
define APP_WS_template
$(1): $(ZIP_FILE)
	if $(UNZIP) $(ZIP_FILE) system/$(2)/$(1).apk -d $(TMP_DIR) 2>/dev/null; then \
	$(APKTOOL) d -f $(TMP_DIR)/system/$(2)/$(1).apk $$@ ; else \
	echo system/$(2)/$(1).apk does not exist, ignored!;  fi
	$(hide) rm -f $(TMP_DIR)/system/$(2)/$(1).apk

endef

# To decide dir of the apk
# $1 the apk name
define MOD_DIR_template
ifeq ($(USE_ANDROID_OUT),true)
ifeq ($(wildcard $(ANDROID_OUT)/system/priv-app/$(1).apk),$(wildcard $(STOCKROM_DIR)/system/priv-app/$(1).apk))
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/app/$(1).apk)
else
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/priv-app/$(1).apk)
endif
else
ifeq ($(wildcard $(RELEASE_PATH)/$(DENSITY)/system/priv-app/$(1).apk),$(wildcard $(STOCKROM_DIR)/system/priv-app/$(1).apk))
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/app/$(1).apk)
else
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/priv-app/$(1).apk)
endif
endif
endef

# To decide dir of the apk
# $1 the apk name
# $2: to specify if the smali files should be decoded from LEWA first
define APP_DIR_template
ifeq ($(USE_ANDROID_OUT),true)
ifeq ($(wildcard $(ANDROID_OUT)/system/priv-app/$(1).apk),)
	$(call APP_template,$(1),$(1),$(2),app)
else
	$(call APP_template,$(1),$(1),$(2),priv-app)
endif
else
ifeq ($(wildcard $(RELEASE_PATH)/$(DENSITY)/system/priv-app/$(1).apk),)
	$(call APP_template,$(1),$(1),$(2),app)
else
	$(call APP_template,$(1),$(1),$(2),priv-app)
endif
endif
endef

#
# Used to sign one single file, e.g: make .build/LogsProvider.apk.sign
# for zipfile target, just to copy the unsigned file to correct ZIP-directory.
# also create a seperate target for command line, such as : make LogsProvider.apk.sign
# $1: the apk file need to be signed
# $2: the path/filename in the phone
define SIGN_template
SIGNAPKS += $(1).sign
$(notdir $(1)).sign $(1).sign: $(1)
	@echo sign apk $(1) and push to phone as $(2)...
	#java -jar $(TOOL_DIR)/signapk.jar $(PORT_ROOT)/build/security/platform.x509.pem $(PORT_ROOT)/build/security/platform.pk8 $(1) $(1).signed
	java -jar $(TOOL_DIR)/signapk.jar $(PORT_ROOT)/build/security/testkey.x509.pem $(PORT_ROOT)/build/security/testkey.pk8 $(1) $(1).signed
	$(ADB) remount
	$(ADB) push $(1).signed $(2)

mark-tozip-for-$(1) := $(TMP_DIR)/$$(shell basename $(1))-tozip
TOZIP_APKS += $$(mark-tozip-for-$(1))
$$(mark-tozip-for-$(1)) : $(1)
	$(hide) cp $(1) $(ZIP_DIR)$(2)
	@touch $$@
endef

#
# Used to build and clean the lewa apk, e.g: make clean-Launcher2
# $1: the apk name
# $2: the dir name
define BUILD_CLEAN_APP_template
ifeq ($(USE_ANDROID_OUT),true)
$(OUT_APK_PATH:app=$(2))/$(1).apk:
	$(MAKE_ATTOP) $(1)

CLEANLEWAAPP += clean-$(1)
clean-$(1):
	$(MAKE_ATTOP) $$@
endif
endef

define RELEASE_LEWA_APP_template
ifeq ($(USE_ANDROID_OUT),true)
RELEASE_LEWA += $(RELEASE_PATH)/$(DENSITY)/system/$(2)/$(1).apk
$(RELEASE_PATH)/$(DENSITY)/system/$(2)/$(1).apk: $(OUT_APK_PATH:app=$(2))/$(1).apk
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/$(2)
	$(hide) cp $$< $$@
endif
endef

zipone: zipfile $(ACT_AFTER_ZIP)

otapackage: metadata target_files
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP)

#> TARGETS EXPANSION START
$(foreach jar, $(LEWA_JARS), \
	$(eval $(call JAR_template,$(jar),$(TMP_DIR)/$(jar))))
$(foreach jar, $(PHONE_JARS), \
	$(eval $(call JAR_PHONE_template,$(jar))))

$(foreach app, $(APPS), \
	$(eval $(call APP_template,$(app),$(app))))

$(foreach app, $(LEWAAPPS_MOD), \
	$(eval $(call APP_template,$(app),$(app),$(TMP_DIR)/$(app))))

$(foreach app, $(APPS) $(LEWAAPPS_MOD), \
	$(eval $(call SIGN_template,$(TMP_DIR)/$(app).apk,/system/app/$(app).apk)))

$(foreach app, $(LEWAAPPS), \
	$(eval $(call SIGN_template,$(OUT_APK_PATH)/$(app).apk,/system/app/$(app).apk)))

$(foreach app, $(PRIV_LEWAAPPS) , \
	$(eval $(call SIGN_template,$(OUT_APK_PATH:app=priv-app)/$(app).apk,/system/priv-app/$(app).apk)))

$(eval $(call SIGN_template,$(TMP_DIR)/lewa-res.apk,/system/framework/lewa-res.apk))

$(eval $(call SIGN_template,$(TMP_DIR)/framework-res.apk,/system/framework/framework-res.apk))

$(foreach app, $(LEWAAPPS) $(LEWAAPPS_MOD), $(eval $(call BUILD_CLEAN_APP_template,$(app))))

$(foreach app, $(PRIV_LEWAAPPS), $(eval $(call BUILD_CLEAN_APP_template,$(app),priv-app)))

$(foreach app, $(ALL_LEWAAPPS), $(eval $(call RELEASE_LEWA_APP_template,$(app))))

$(foreach app, $(ALL_PRIV_LEWAAPPS), $(eval $(call RELEASE_LEWA_APP_template,$(app),priv-app)))

$(foreach app, $(APPS), \
	$(eval $(call APP_WS_template,$(app),app)))

$(foreach app, $(APPS), \
	$(eval $(call APP_WS_template,$(app),priv-app)))

$(eval $(call APP_WS_template,framework-res,framework))

# for release
ifeq ($(USE_ANDROID_OUT),true)
RELEASE_LEWA += $(RELEASE_PATH)/$(DENSITY)/system/framework/lewa-res.apk
$(RELEASE_PATH)/$(DENSITY)/system/framework/lewa-res.apk:
	cp $(OUT_JAR_PATH)/lewa-res.apk $@
RELEASE_LEWA += $(RELEASE_PATH)/$(DENSITY)/system/framework/framework-res.apk
$(RELEASE_PATH)/$(DENSITY)/system/framework/framework-res.apk:
	cp $(OUT_JAR_PATH)/framework-res.apk $@
endif

#< TARGET EXPANSION END

#> TARGET FOR ZIPFILE START
$(TMP_DIR):
	$(hide) mkdir -p $(TMP_DIR)

# if the zip file does not exist, would try to generate the zip
# file from the stockrom dirctory if exist
$(ZIP_FILE):
	$(hide) cd $(STOCKROM_DIR) && $(ZIP) -r ../$(ZIP_FILE) ./
	$(hide) touch .delete-zip-file-when-clean

# if the zip dir does not exist, would try to unzip stockrom.zip
$(STOCKROM_DIR): $(ZIP_FILE)
	$(UNZIP) -n $(ZIP_FILE) -d $@

$(ZIP_DIR): $(ZIP_FILE) | $(TMP_DIR)
	$(UNZIP) $(ZIP_FILE) -d $@
ifneq ($(strip $(local-phone-apps)),)
	$(hide) mv $(ZIP_DIR)/system/app $(ZIP_DIR)/system/app.original
	$(hide) mkdir $(ZIP_DIR)/system/app
	$(hide) for apk in $(local-phone-apps); do\
		cp $(ZIP_DIR)/system/app.original/$$apk.apk $(ZIP_DIR)/system/app; \
	done
	$(hide) rm -rf $(ZIP_DIR)/system/app.original
endif
ifneq ($(strip $(local-phone-priv-apps)),)
	$(hide) mv $(ZIP_DIR)/system/priv-app $(ZIP_DIR)/system/priv-app.original
	$(hide) mkdir $(ZIP_DIR)/system/priv-app
	$(hide) for apk in $(local-phone-priv-apps); do\
		cp $(ZIP_DIR)/system/priv-app.original/$$apk.apk $(ZIP_DIR)/system/priv-app; \
	done
	$(hide) rm -rf $(ZIP_DIR)/system/priv-app.original
endif

remove-rund-apks:
	@echo ">>> remove all unnecessary apks from original ZIP file..."
	$(hide) rm -f $(addprefix $(ZIP_DIR)/system/app/, $(addsuffix .apk, $(RUNDAPKS)))
	@echo "<<< remove done!"

pre-zip-misc: set-build-prop

set-build-prop:
	$(SETPROP) $(PROP_FILE) $(PORT_PRODUCT) $(BUILD_NUMBER) $(PARTNER)

rewrite-lib:
	$(hide) if [ $(REWRITE_SKIA_LIB) = "true" ]; then \
		$(REWRITE) $(SKIA_FILE) ANDROID_ROOT ANDROID_DATA; \
	fi

ifeq ($(USE_ANDROID_OUT),true)
RELEASE_LEWA += release-lewa-prebuilt
endif
	
target_files: $(STOCKROM_DIR) | $(ZIP_DIR) 
target_files: $(TMP_DIR)/lewa-res.apk $(ZIP_BLDJARS) $(TOZIP_APKS) add-lewa-prebuilt $(ACT_PRE_ZIP)

# Target to make zipfile which is all signed by testkey. convenient for developement and debug
zipfile: BUILD_NUMBER := $(ROM_BUILD_NUMBER)
zipfile: target_files $(TMP_DIR)/sign-zipfile-dir
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP) -n $(OUT_ZIP_FILE)
	@echo The output zip file is: $(OUT_ZIP)

#TODO add all depend sign..
$(TMP_DIR)/sign-zipfile-dir:
	$(SIGN) sign.zip $(ZIP_DIR)
	#@touch $@

# Target to test if full ota package will be generate
fullota: BUILD_NUMBER := $(ROM_BUILD_NUMBER)
fullota: target_files
	@echo ">>> To build out target file: fullota.zip ..."
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP) fullota.zip
	@echo "<<< build target file completed!"

#< TARGET FOR ZIPFILE END

include $(PORT_BUILD)/util.mk
include $(PORT_BUILD)/prebuilt.mk
