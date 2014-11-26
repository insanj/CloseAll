THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 armv7s arm64
# DEBUG = 1

include theos/makefiles/common.mk

TWEAK_NAME = CloseAll
CloseAll_FILES = CloseAll.xm
CloseAll_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 MobileSafari"
	