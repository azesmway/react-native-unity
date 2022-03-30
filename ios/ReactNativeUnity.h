#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#include <mach-o/ldsyms.h>
#include <UnityFramework/UnityFramework.h>

@protocol RNUnityAppController <UIApplicationDelegate, UnityFrameworkListener>

- (UIWindow *)window;
- (UIView *)rootView;
- (UnityView *)unityView;

@end

@protocol RNUnityFramework <NSObject>

+ (id<RNUnityFramework>)getInstance;
- (id<RNUnityAppController>)appController;

- (void)setExecuteHeader:(const typeof(_mh_execute_header)*)header;
- (void)setDataBundleId:(const char*)bundleId;

- (void)registerFrameworkListener:(id<RNUnityFramework>)obj;
- (void)unregisterFrameworkListener:(id<RNUnityFramework>)obj;
- (void)frameworkWarmup:(int)argc argv:(char*[])argv;

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

