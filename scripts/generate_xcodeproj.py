import os

pbxproj_content = """// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		A1000001 /* DeepSeekPeakHoursApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000001 /* DeepSeekPeakHoursApp.swift */; };
		A1000002 /* StatusBarController.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000002 /* StatusBarController.swift */; };
		A1000003 /* HolidayExplainerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000003 /* HolidayExplainerView.swift */; };
		A1000004 /* MenuBarView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000004 /* MenuBarView.swift */; };
		A1000005 /* ScheduleView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000005 /* ScheduleView.swift */; };
		A1000006 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000006 /* SettingsView.swift */; };
		A1000007 /* StatusBadgeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000007 /* StatusBadgeView.swift */; };
		A1000008 /* StatusView.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000008 /* StatusView.swift */; };
		A1000009 /* AppIcon.icns in Resources */ = {isa = PBXBuildFile; fileRef = B1000009 /* AppIcon.icns */; };
		A1000010 /* china-2025.json in Resources */ = {isa = PBXBuildFile; fileRef = B1000010 /* china-2025.json */; };
		A1000011 /* china-2026.json in Resources */ = {isa = PBXBuildFile; fileRef = B1000011 /* china-2026.json */; };
		A1000012 /* china-2027.json in Resources */ = {isa = PBXBuildFile; fileRef = B1000012 /* china-2027.json */; };
		A1000013 /* china-2028.json in Resources */ = {isa = PBXBuildFile; fileRef = B1000013 /* china-2028.json */; };
		A1000014 /* AppSettings.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000014 /* AppSettings.swift */; };
		A1000015 /* ChineseHoliday.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000015 /* ChineseHoliday.swift */; };
		A1000016 /* PeakPeriod.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000016 /* PeakPeriod.swift */; };
		A1000017 /* PeakStatus.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000017 /* PeakStatus.swift */; };
		A1000018 /* PeakStatusInfo.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000018 /* PeakStatusInfo.swift */; };
		A1000019 /* HolidayProvider.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000019 /* HolidayProvider.swift */; };
		A1000020 /* HolidayService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000020 /* HolidayService.swift */; };
		A1000021 /* LaunchAtLoginService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000021 /* LaunchAtLoginService.swift */; };
		A1000022 /* NotificationService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000022 /* NotificationService.swift */; };
		A1000023 /* PeakHourCalculator.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000023 /* PeakHourCalculator.swift */; };
		A1000024 /* TimeService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000024 /* TimeService.swift */; };
		A1000025 /* StatusViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000025 /* StatusViewModel.swift */; };
		A1000026 /* main.swift in Sources */ = {isa = PBXBuildFile; fileRef = B1000026 /* main.swift */; };
		A1000027 /* DeepSeekPeakHoursCore.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = C1000002 /* DeepSeekPeakHoursCore.framework */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		B1000001 /* DeepSeekPeakHoursApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DeepSeekPeakHoursApp.swift; sourceTree = "<group>"; };
		B1000002 /* StatusBarController.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StatusBarController.swift; sourceTree = "<group>"; };
		B1000003 /* HolidayExplainerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HolidayExplainerView.swift; sourceTree = "<group>"; };
		B1000004 /* MenuBarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MenuBarView.swift; sourceTree = "<group>"; };
		B1000005 /* ScheduleView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ScheduleView.swift; sourceTree = "<group>"; };
		B1000006 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
		B1000007 /* StatusBadgeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StatusBadgeView.swift; sourceTree = "<group>"; };
		B1000008 /* StatusView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StatusView.swift; sourceTree = "<group>"; };
		B1000009 /* AppIcon.icns */ = {isa = PBXFileReference; lastKnownFileType = image.icns; path = AppIcon.icns; sourceTree = "<group>"; };
		B1000010 /* china-2025.json */ = {isa = PBXFileReference; lastKnownFileType = text.json; path = "china-2025.json"; sourceTree = "<group>"; };
		B1000011 /* china-2026.json */ = {isa = PBXFileReference; lastKnownFileType = text.json; path = "china-2026.json"; sourceTree = "<group>"; };
		B1000012 /* china-2027.json */ = {isa = PBXFileReference; lastKnownFileType = text.json; path = "china-2027.json"; sourceTree = "<group>"; };
		B1000013 /* china-2028.json */ = {isa = PBXFileReference; lastKnownFileType = text.json; path = "china-2028.json"; sourceTree = "<group>"; };
		B1000014 /* AppSettings.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppSettings.swift; sourceTree = "<group>"; };
		B1000015 /* ChineseHoliday.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ChineseHoliday.swift; sourceTree = "<group>"; };
		B1000016 /* PeakPeriod.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PeakPeriod.swift; sourceTree = "<group>"; };
		B1000017 /* PeakStatus.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PeakStatus.swift; sourceTree = "<group>"; };
		B1000018 /* PeakStatusInfo.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PeakStatusInfo.swift; sourceTree = "<group>"; };
		B1000019 /* HolidayProvider.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HolidayProvider.swift; sourceTree = "<group>"; };
		B1000020 /* HolidayService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HolidayService.swift; sourceTree = "<group>"; };
		B1000021 /* LaunchAtLoginService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LaunchAtLoginService.swift; sourceTree = "<group>"; };
		B1000022 /* NotificationService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NotificationService.swift; sourceTree = "<group>"; };
		B1000023 /* PeakHourCalculator.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PeakHourCalculator.swift; sourceTree = "<group>"; };
		B1000024 /* TimeService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TimeService.swift; sourceTree = "<group>"; };
		B1000025 /* StatusViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StatusViewModel.swift; sourceTree = "<group>"; };
		B1000026 /* main.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = main.swift; sourceTree = "<group>"; };
		B1000027 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		C1000001 /* DeepSeek Peak Hours.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "DeepSeek Peak Hours.app"; sourceTree = BUILT_PRODUCTS_DIR; };
		C1000002 /* DeepSeekPeakHoursCore.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = DeepSeekPeakHoursCore.framework; sourceTree = BUILT_PRODUCTS_DIR; };
		C1000003 /* DeepSeekPeakHoursTests */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; path = DeepSeekPeakHoursTests; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		D1000001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000027 /* DeepSeekPeakHoursCore.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		D1000002 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		D1000003 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000027 /* DeepSeekPeakHoursCore.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		E1000000 = {
			isa = PBXGroup;
			children = (
				E1000001 /* Sources */,
				E1000002 /* Support */,
				E1000003 /* Tests */,
				E1000004 /* Products */,
			);
			sourceTree = "<group>";
		};
		E1000001 /* Sources */ = {
			isa = PBXGroup;
			children = (
				E1000005 /* DeepSeekPeakHours */,
				E1000006 /* DeepSeekPeakHoursCore */,
			);
			path = Sources;
			sourceTree = "<group>";
		};
		E1000002 /* Support */ = {
			isa = PBXGroup;
			children = (
				B1000027 /* Info.plist */,
				B1000009 /* AppIcon.icns */,
			);
			path = Support;
			sourceTree = "<group>";
		};
		E1000003 /* Tests */ = {
			isa = PBXGroup;
			children = (
				B1000026 /* main.swift */,
			);
			path = Tests/DeepSeekPeakHoursTests;
			sourceTree = "<group>";
		};
		E1000004 /* Products */ = {
			isa = PBXGroup;
			children = (
				C1000001 /* DeepSeek Peak Hours.app */,
				C1000002 /* DeepSeekPeakHoursCore.framework */,
				C1000003 /* DeepSeekPeakHoursTests */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		E1000005 /* DeepSeekPeakHours */ = {
			isa = PBXGroup;
			children = (
				B1000001 /* DeepSeekPeakHoursApp.swift */,
				B1000002 /* StatusBarController.swift */,
				B1000003 /* HolidayExplainerView.swift */,
				B1000004 /* MenuBarView.swift */,
				B1000005 /* ScheduleView.swift */,
				B1000006 /* SettingsView.swift */,
				B1000007 /* StatusBadgeView.swift */,
				B1000008 /* StatusView.swift */,
			);
			path = DeepSeekPeakHours;
			sourceTree = "<group>";
		};
		E1000006 /* DeepSeekPeakHoursCore */ = {
			isa = PBXGroup;
			children = (
				B1000014 /* AppSettings.swift */,
				B1000015 /* ChineseHoliday.swift */,
				B1000016 /* PeakPeriod.swift */,
				B1000017 /* PeakStatus.swift */,
				B1000018 /* PeakStatusInfo.swift */,
				B1000019 /* HolidayProvider.swift */,
				B1000020 /* HolidayService.swift */,
				B1000021 /* LaunchAtLoginService.swift */,
				B1000022 /* NotificationService.swift */,
				B1000023 /* PeakHourCalculator.swift */,
				B1000024 /* TimeService.swift */,
				B1000025 /* StatusViewModel.swift */,
				B1000010 /* china-2025.json */,
				B1000011 /* china-2026.json */,
				B1000012 /* china-2027.json */,
				B1000013 /* china-2028.json */,
			);
			path = DeepSeekPeakHoursCore;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		F1000001 /* DeepSeek Peak Hours */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = G1000001 /* Build configuration list for PBXNativeTarget "DeepSeek Peak Hours" */;
			buildPhases = (
				H1000001 /* Sources */,
				D1000001 /* Frameworks */,
				J1000001 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				K1000001 /* PBXTargetDependency */,
			);
			name = "DeepSeek Peak Hours";
			productName = "DeepSeek Peak Hours";
			productReference = C1000001 /* DeepSeek Peak Hours.app */;
			productType = "com.apple.product-type.application";
		};
		F1000002 /* DeepSeekPeakHoursCore */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = G1000002 /* Build configuration list for PBXNativeTarget "DeepSeekPeakHoursCore" */;
			buildPhases = (
				H1000002 /* Sources */,
				D1000002 /* Frameworks */,
				J1000002 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = DeepSeekPeakHoursCore;
			productName = DeepSeekPeakHoursCore;
			productReference = C1000002 /* DeepSeekPeakHoursCore.framework */;
			productType = "com.apple.product-type.framework";
		};
		F1000003 /* DeepSeekPeakHoursTests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = G1000003 /* Build configuration list for PBXNativeTarget "DeepSeekPeakHoursTests" */;
			buildPhases = (
				H1000003 /* Sources */,
				D1000003 /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
				K1000001 /* PBXTargetDependency */,
			);
			name = DeepSeekPeakHoursTests;
			productName = DeepSeekPeakHoursTests;
			productReference = C1000003 /* DeepSeekPeakHoursTests */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		E1000007 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					F1000001 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = G1000000 /* Build configuration list for PBXProject "DeepSeekPeakHours" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = E1000000;
			productRefGroup = E1000004 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				F1000001 /* DeepSeek Peak Hours */,
				F1000002 /* DeepSeekPeakHoursCore */,
				F1000003 /* DeepSeekPeakHoursTests */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		J1000001 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000009 /* AppIcon.icns in Resources */,
				A1000010 /* china-2025.json in Resources */,
				A1000011 /* china-2026.json in Resources */,
				A1000012 /* china-2027.json in Resources */,
				A1000013 /* china-2028.json in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		J1000002 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000010 /* china-2025.json in Resources */,
				A1000011 /* china-2026.json in Resources */,
				A1000012 /* china-2027.json in Resources */,
				A1000013 /* china-2028.json in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		H1000001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000001 /* DeepSeekPeakHoursApp.swift in Sources */,
				A1000002 /* StatusBarController.swift in Sources */,
				A1000003 /* HolidayExplainerView.swift in Sources */,
				A1000004 /* MenuBarView.swift in Sources */,
				A1000005 /* ScheduleView.swift in Sources */,
				A1000006 /* SettingsView.swift in Sources */,
				A1000007 /* StatusBadgeView.swift in Sources */,
				A1000008 /* StatusView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		H1000002 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000014 /* AppSettings.swift in Sources */,
				A1000015 /* ChineseHoliday.swift in Sources */,
				A1000016 /* PeakPeriod.swift in Sources */,
				A1000017 /* PeakStatus.swift in Sources */,
				A1000018 /* PeakStatusInfo.swift in Sources */,
				A1000019 /* HolidayProvider.swift in Sources */,
				A1000020 /* HolidayService.swift in Sources */,
				A1000021 /* LaunchAtLoginService.swift in Sources */,
				A1000022 /* NotificationService.swift in Sources */,
				A1000023 /* PeakHourCalculator.swift in Sources */,
				A1000024 /* TimeService.swift in Sources */,
				A1000025 /* StatusViewModel.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		H1000003 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000026 /* main.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		K1000001 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = F1000002 /* DeepSeekPeakHoursCore */;
			targetProxy = L1000001 /* PBXContainerItemProxy */;
		};
/* End PBXTargetDependency section */

/* Begin PBXContainerItemProxy section */
		L1000001 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = E1000007 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = F1000002;
			remoteInfo = DeepSeekPeakHoursCore;
		};
/* End PBXContainerItemProxy section */

/* Begin XCBuildConfiguration section */
		M1000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CODE_SIGN_STYLE = Manual;
				CODE_SIGN_IDENTITY = "-";
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Support/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.deepseek.peakhours";
				PRODUCT_NAME = "DeepSeek Peak Hours";
				SDKROOT = macosx;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		M1000002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CODE_SIGN_STYLE = Manual;
				CODE_SIGN_IDENTITY = "-";
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Support/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.deepseek.peakhours";
				PRODUCT_NAME = "DeepSeek Peak Hours";
				SDKROOT = macosx;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
		M1000003 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Manual;
				CODE_SIGN_IDENTITY = "-";
				DEFINES_MODULE = YES;
				DYLIB_COMPATIBILITY_VERSION = 1;
				DYLIB_CURRENT_VERSION = 1;
				DYLIB_INSTALL_NAME_BASE = "@rpath";
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.deepseek.peakhours.core";
				PRODUCT_NAME = "$(TARGET_NAME:c99extidentifier)";
				SDKROOT = macosx;
				SKIP_INSTALL = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		M1000004 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Manual;
				CODE_SIGN_IDENTITY = "-";
				DEFINES_MODULE = YES;
				DYLIB_COMPATIBILITY_VERSION = 1;
				DYLIB_CURRENT_VERSION = 1;
				DYLIB_INSTALL_NAME_BASE = "@rpath";
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.deepseek.peakhours.core";
				PRODUCT_NAME = "$(TARGET_NAME:c99extidentifier)";
				SDKROOT = macosx;
				SKIP_INSTALL = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
		M1000005 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Manual;
				CODE_SIGN_IDENTITY = "-";
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		M1000006 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Manual;
				CODE_SIGN_IDENTITY = "-";
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
		M1000007 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_OBJC_ARC = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				SDKROOT = macosx;
			};
			name = Debug;
		};
		M1000008 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_OBJC_ARC = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				SDKROOT = macosx;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		G1000000 /* Build configuration list for PBXProject "DeepSeekPeakHours" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				M1000007 /* Debug */,
				M1000008 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		G1000001 /* Build configuration list for PBXNativeTarget "DeepSeek Peak Hours" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				M1000001 /* Debug */,
				M1000002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		G1000002 /* Build configuration list for PBXNativeTarget "DeepSeekPeakHoursCore" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				M1000003 /* Debug */,
				M1000004 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		G1000003 /* Build configuration list for PBXNativeTarget "DeepSeekPeakHoursTests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				M1000005 /* Debug */,
				M1000006 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

	};
	rootObject = E1000007 /* Project object */;
}
"""

os.makedirs("DeepSeekPeakHours.xcodeproj", exist_ok=True)
with open("DeepSeekPeakHours.xcodeproj/project.pbxproj", "w") as f:
    f.write(pbxproj_content)

print("Created DeepSeekPeakHours.xcodeproj/project.pbxproj")
