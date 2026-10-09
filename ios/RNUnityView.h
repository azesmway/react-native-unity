#import <React/RCTView.h>
#import <React/RCTEventDispatcher.h>
#import <UIKit/UIKit.h>
#include <UnityFramework/UnityFramework.h>
#include <UnityFramework/NativeCallProxy.h>

// The host app's window. Under the UIScene life cycle (required by the iOS 27 SDK,
// default in Expo SDK 58) the app delegate owns no window, so `delegate.window` is nil.
FOUNDATION_EXTERN UIWindow * _Nullable RNUnityHostWindow(UIView * _Nullable view, UIWindow * _Nullable exclude);

// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#import <react/renderer/components/unityview/ComponentDescriptors.h>
#import <react/renderer/components/unityview/EventEmitters.h>
#import <react/renderer/components/unityview/Props.h>
#import <react/renderer/components/unityview/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

#ifndef UnityViewNativeComponent_h
#define UnityViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface RNUnityView : RCTViewComponentView <UIApplicationDelegate, RCTRNUnityViewViewProtocol, NativeCallsProtocol, UnityFrameworkListener>

@property UnityFramework* ufw;

@property (nonatomic, strong) UIView* _Nullable uView;

@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onUnityMessage;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onPlayerUnload;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onPlayerQuit;

- (void)unloadUnity;
- (void)pauseUnity:(BOOL)pause;
- (void)resumeUnity;
- (void)postMessage:(NSString* _Nonnull )gameObject methodName:(NSString* _Nonnull)methodName message:(NSString* _Nonnull) message;

@end

NS_ASSUME_NONNULL_END

#endif /* UnityViewNativeComponent_h */
#else

#import <React/RCTView.h>

@interface RNUnityView : RCTView <UIApplicationDelegate, NativeCallsProtocol, UnityFrameworkListener>

@property UnityFramework* ufw;

@property (nonatomic, strong) UIView* _Nullable uView;

@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onUnityMessage;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onPlayerUnload;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onPlayerQuit;

- (void)unloadUnity;
- (void)pauseUnity:(BOOL)pause;
- (void)resumeUnity;
- (void)postMessage:(NSString* _Nonnull )gameObject methodName:(NSString* _Nonnull)methodName message:(NSString* _Nonnull) message;


@end

#endif /* RCT_NEW_ARCH_ENABLED */
