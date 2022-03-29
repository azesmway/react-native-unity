#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#include <mach-o/ldsyms.h>

@protocol RNUnityAppController <UIApplicationDelegate>

- (UIWindow *)window;
- (UIView *)rootView;

@end

@protocol RNUnityFramework <NSObject>

+ (id<RNUnityFramework>)getInstance;
- (id<RNUnityAppController>)appController;

- (void)setExecuteHeader:(const typeof(_mh_execute_header)*)header;
- (void)setDataBundleId:(const char*)bundleId;

- (void)runEmbeddedWithArgc:(int)argc argv:(char*[])argv appLaunchOpts:(NSDictionary*)appLaunchOpts;

- (void)unloadApplication;

- (void)showUnityWindow;

- (void)quitApplication:(int)exitCode;

- (void)pause:(bool)pause;

- (void)sendMessageToGOWithName:(const char*)goName functionName:(const char*)name message:(const char*)msg;

@end

@interface ReactNativeUnity : RCTEventEmitter <RCTBridgeModule>

@property (atomic, class) id<RNUnityFramework> ufw;

+ (id<RNUnityFramework>)launchWithOptions:(NSDictionary*)launchOptions;

@end

