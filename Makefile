ARCHS = arm64e
TARGET = iphone:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ForceBypass

ForceBypass_FILES = Tweak.x
ForceBypass_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
