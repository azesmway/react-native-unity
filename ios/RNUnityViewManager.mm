#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridgeModule.h>
#import <RNUnityView.h>

@interface RNUnityViewManager : RCTViewManager <RCTBridgeModule>
@end

@implementation RNUnityViewManager

RCT_EXPORT_MODULE(RNUnityView)
RCT_EXPORT_VIEW_PROPERTY(onUnityMessage, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerUnload, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerQuit, RCTBubblingEventBlock)

RNUnityView *unity;

- (UIView *)view {
    unity = [[RNUnityView alloc] init];
    UIWindow * main = [[[UIApplication sharedApplication] delegate] window];

    if(main != nil) {
        [main makeKeyAndVisible];
    }

    return unity;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber*) reactTag gameObject:(NSString*_Nonnull) gameObject methodName:(NSString*_Nonnull) methodName message:(NSString*_Nonnull) message) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        RNUnityView *view = (RNUnityView*) viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[RNUnityView class]]) {
            RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
            return;
        }
        [unity postMessage:(NSString *)gameObject methodName:(NSString *)methodName message:(NSString *)message];
    }];
}

RCT_EXPORT_METHOD(pauseUnity:(nonnull NSNumber*) reactTag pause:(BOOL * _Nonnull)pause) {
   [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
       RNUnityView *view = (RNUnityView*) viewRegistry[reactTag];
       if (!view || ![view isKindOfClass:[RNUnityView class]]) {
           RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
           return;
       }
       [unity pauseUnity:(BOOL * _Nonnull)pause];
   }];
}

RCT_EXPORT_METHOD(resumeUnity:(nonnull NSNumber*) reactTag) {
   [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
       RNUnityView *view = (RNUnityView*) viewRegistry[reactTag];
       if (!view || ![view isKindOfClass:[RNUnityView class]]) {
           RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
           return;
       }
       [unity pauseUnity:(BOOL * _Nonnull)false];
   }];
}

RCT_EXPORT_METHOD(unloadUnity:(nonnull NSNumber*) reactTag) {
   [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
       RNUnityView *view = (RNUnityView*) viewRegistry[reactTag];
       if (!view || ![view isKindOfClass:[RNUnityView class]]) {
           RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
           return;
       }
       [unity unloadUnity];
   }];
}

- (NSArray<NSString *> *)supportedEvents {
   return @[@"onUnityMessage", @"onPlayerUnload", @"onPlayerQuit"];
}

@end
