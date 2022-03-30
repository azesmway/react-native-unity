#import <Foundation/Foundation.h>
#import <React/RCTView.h>
#import <React/RCTEventDispatcher.h>
#include <UnityFramework/NativeCallProxy.h>

@interface ReactNativeUnityView : RCTView <NativeCallsProtocol>

@property (nonatomic, strong) UIView* _Nullable uView;

@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onUnityMessage;

+ (void)UnityPostMessage:(NSString* _Nonnull )gameObject methodName:(NSString* _Nonnull)methodName message:(NSString* _Nonnull) message;
+ (void)unloadUnity;
+ (void)pauseUnity:(BOOL * _Nonnull)pause;

@end
