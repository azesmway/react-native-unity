#import <Foundation/Foundation.h>
#import <React/RCTView.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTBridgeModule.h>
#import <UnityFramework/NativeCallProxy.h>

@interface ReactNativeUnityView : RCTView <RCTBridgeModule, NativeCallsProtocol>

@property (nonatomic, strong) UIView* _Nullable uView;

@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onUnityMessage;

+ (void)UnityPostMessage:(NSString* _Nonnull )gameObject methodName:(NSString* _Nonnull)methodName message:(NSString* _Nonnull) message;
+ (void)unloadUnity;

@end
