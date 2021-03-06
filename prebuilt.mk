add-prebuilt-app-jellybean:
	@echo To add prebuilt apps
	$(hide) mkdir -p $(ZIP_DIR)/data/media
	$(hide) cp -rf $(DATAOUT_DIR)/media/preinstall_apps/ $(ZIP_DIR)/data/media/

add-prebuilt-app-jellybean42:
	@echo To add prebuilt apps
	$(hide) mkdir -p $(ZIP_DIR)/system/vendor/operator/app
	$(hide) cp -f $(DATAOUT_DIR)/media/preinstall_apps/* $(ZIP_DIR)/system/vendor/operator/app/

add-prebuilt-binaries:
	@echo To add prebuilt binaries
	$(hide) cp -f $(SYSOUT_DIR)/bin/su0 $(ZIP_DIR)/system/bin/
	$(hide) cp -f $(SYSOUT_DIR)/xbin/busybox $(ZIP_DIR)/system/xbin/
	$(hide) cp -f $(SYSOUT_DIR)/xbin/su $(ZIP_DIR)/system/xbin/
	$(hide) cp -f $(SYSOUT_DIR)/usr/share/phoneloc.dat $(ZIP_DIR)/system/usr/share/

add-prebuilt-libraries:
	@echo To add prebuilt libraries
	$(hide) cp -f $(SYSOUT_DIR)/framework/lewa-framework.jar $(ZIP_DIR)/system/framework/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libams-1.1.0.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libapollo-1.1.2.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libcryptor-1.0.0.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblbs.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblocation-1.0.0.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libnative-1.0.0.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libphoneloc_jni.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libsmschecker-1.0.1.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libsmsparser-1.0.0.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libphoneloc_jni.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblewa_imageutils.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblewa_shell.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblocSDK4.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libOfflineWordSelection.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libapkpatch.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libaudiocore.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libaudiofp.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libBDmfemusic_V1.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libams-1.1.0-legacy.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libcryptor-1.0.0-legacy.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblocation-1.0.0-legacy.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libgetuiext.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libSynclewa.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libBaiduMapSDK_v2_3_1.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblocSDK4.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libPinguoImageSDK.so $(ZIP_DIR)/system/lib/

add-prebuilt-media:
	@echo To add prebuilt media files
	$(hide) cp -rf $(SYSOUT_DIR)/media $(ZIP_DIR)/system

add-prebuilt-etc-files:
	@echo To add prebuilt files under etc
	$(hide) cp -f $(SYSOUT_DIR)/etc/icons_alias.xml $(ZIP_DIR)/system/etc/
	$(hide) cp -f $(SYSOUT_DIR)/etc/permissions/com.lewa.software.themes.xml $(ZIP_DIR)/system/etc/permissions/
	$(hide) cp -f $(SYSOUT_DIR)/etc/system_fonts.xml $(ZIP_DIR)/system/etc/

add-prebuilt-fonts:
	@echo To add prebuilt fonts:
	$(hide) cp -f $(SYSOUT_DIR)/fonts/NeoSans-Light.otf $(ZIP_DIR)/system/fonts/
	
add-prebuilt-google-files:
	@echo To add prebuilt google files
	$(hide) cp -f $(SYSOUT_DIR)/app/NetworkLocation.apk $(ZIP_DIR)/system/app/
	$(hide) cp -f $(SYSOUT_DIR)/app/ChromeBookmarksSyncAdapter.apk $(ZIP_DIR)/system/app/
	$(hide) cp -f $(SYSOUT_DIR)/app/GoogleCalendarSyncAdapter.apk $(ZIP_DIR)/system/app/
	$(hide) cp -f $(SYSOUT_DIR)/app/GoogleContactsSyncAdapter.apk $(ZIP_DIR)/system/app/
	$(hide) cp -f $(SYSOUT_DIR)/app/GoogleLoginService.apk $(ZIP_DIR)/system/app/
	$(hide) cp -f $(SYSOUT_DIR)/app/GoogleServicesFramework.apk $(ZIP_DIR)/system/app/
	$(hide) cp -f $(SYSOUT_DIR)/etc/permissions/com.google.android.maps.xml $(ZIP_DIR)/system/etc/permissions/
	$(hide) cp -f $(SYSOUT_DIR)/etc/permissions/com.google.android.media.effects.xml $(ZIP_DIR)/system/etc/permissions/
	$(hide) cp -f $(SYSOUT_DIR)/etc/permissions/features.xml $(ZIP_DIR)/system/etc/permissions/
	$(hide) cp -f $(SYSOUT_DIR)/framework/com.google.android.maps.jar $(ZIP_DIR)/system/framework/
	$(hide) cp -f $(SYSOUT_DIR)/framework/com.google.android.media.effects.jar $(ZIP_DIR)/system/framework/

add-prebuilt-lewa-sqlite-library:
	@echo To add prebuilt lewa sqlite library
	$(hide) cp -f $(SYSOUT_DIR)/lib/libsqlite.so $(ZIP_DIR)/system/lib/

add-lewa-prebuilt: add-prebuilt-app-$(PATCHROM_BRANCH) add-prebuilt-binaries add-prebuilt-libraries add-prebuilt-media add-prebuilt-etc-files add-prebuilt-fonts add-prebuilt-google-files
	@echo Add lewa prebuilt completed!
