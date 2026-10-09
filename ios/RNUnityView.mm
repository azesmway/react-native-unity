#import "RNUnityView.h"
#ifdef DEBUG
#include <mach-o/ldsyms.h>
#endif
#ifdef RCT_NEW_ARCH_ENABLED
using namespace facebook::react;
#endif

NSString *bundlePathStr = @"/Frameworks/UnityFramework.framework";
int gArgc = 1;

UnityFramework* UnityFrameworkLoad() {
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: bundlePathStr];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
#ifdef DEBUG
      [ufw setExecuteHeader: &_mh_dylib_header];
#else
      [ufw setExecuteHeader: &_mh_execute_header];
#endif
    }

    [ufw setDataBundleId: [bundle.bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding]];

    return ufw;
}

UIWindow* RNUnityHostWindow(UIView* view, UIWindow* exclude) {
    if (view.window != nil && view.window != exclude) {
        return view.window;
    }

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [[UIApplication sharedApplication] connectedScenes]) {
            // Foreground-inactive still counts: unload can arrive while a system overlay is up.
            if (scene.activationState == UISceneActivationStateUnattached ||
                scene.activationState == UISceneActivationStateBackground ||
                ![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }

            id<UISceneDelegate> sceneDelegate = scene.delegate;
            if ([sceneDelegate respondsToSelector:@selector(window)]) {
                UIWindow *window = [(id<UIWindowSceneDelegate>)sceneDelegate window];
                if (window != nil && window != exclude) {
                    return window;
                }
            }

            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow && window != exclude) {
                    return window;
                }
            }
        }
    }

    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate respondsToSelector:@selector(window)] && appDelegate.window != exclude) {
        return appDelegate.window;
    }

    return nil;
}

@implementation RNUnityView {
    // YES once the Fabric view paused Unity for recycling, so we know to resume
    // the shared instance when the view comes back on screen (#180).
    BOOL _pausedForRecycle;
    // YES once this view tore Unity down; prevents a late layoutSubviews retry
    // from resurrecting the engine during teardown.
    BOOL _unloaded;
}

NSDictionary* appLaunchOpts;

- (bool)unityIsInitialized {
    return [self ufw] && [[self ufw] appController];
}

- (void)initUnityModule {
    @try {
        if([self unityIsInitialized]) {
            return;
        }

        [self setUfw: UnityFrameworkLoad()];
        [[self ufw] registerFrameworkListener: self];

        unsigned count = (int) [[[NSProcessInfo processInfo] arguments] count];
        char **array = (char **)malloc((count + 1) * sizeof(char*));

        for (unsigned i = 0; i < count; i++)
        {
             array[i] = strdup([[[[NSProcessInfo processInfo] arguments] objectAtIndex:i] UTF8String]);
        }
        array[count] = NULL;

        [[self ufw] runEmbeddedWithArgc: gArgc argv: array appLaunchOpts: appLaunchOpts];
        [[self ufw] appController].quitHandler = ^(){ NSLog(@"AppController.quitHandler called"); };
        [self.ufw.appController.rootView removeFromSuperview];

        if (@available(iOS 13.0, *)) {
            [[[[self ufw] appController] window] setWindowScene: nil];
        } else {
            [[[[self ufw] appController] window] setScreen: nil];
        }

        [[[[self ufw] appController] window] addSubview: self.ufw.appController.rootView];
        [[[[self ufw] appController] window] makeKeyAndVisible];
        [[[[[[self ufw] appController] window] rootViewController] view] setNeedsLayout];

        [NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:self];
    }
    @catch (NSException *e) {
        NSLog(@"%@",e);
    }
}

- (void)layoutSubviews {
   [super layoutSubviews];

   // Under Fabric, updateProps: is not reliably dispatched on the initial mount, so Unity
   // must also be initialized from layoutSubviews or it may never start (#174, #175).
   // Guard on _unloaded so a pending retry can't resurrect a torn-down engine.
   if(!_unloaded && ![self unityIsInitialized]) {
      [self initUnityModule];
   }

   if([self unityIsInitialized] && self.ufw.appController.rootView != nil) {
      self.ufw.appController.rootView.frame = self.bounds;
      [self addSubview:self.ufw.appController.rootView];

      // Coming back on screen after the view was recycled: resume the shared
      // instance that prepareForRecycle paused (#180).
      if (_pausedForRecycle) {
         [[self ufw] pause:NO];
         _pausedForRecycle = NO;
      }
   } else if (!_unloaded) {
      // Unity boots asynchronously: when the view mounts once at app start (persistent-host
      // setups), the engine finishes booting AFTER the last layout pass and nobody attaches
      // its root view — the screen stays black while the game runs. Retry until it exists.
      // Weak self so the 0.25s retry timer never keeps a dead view alive.
      __weak RNUnityView *weakSelf = self;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [weakSelf setNeedsLayout];
      });
   }
}

- (void)pauseUnity:(BOOL)pause {
    if([self unityIsInitialized]) {
        [[self ufw] pause:pause];
    }
}

- (void)resumeUnity {
    _pausedForRecycle = NO;
    if([self unityIsInitialized]) {
        [[self ufw] pause:NO];
    }
}

- (void)unloadUnity {
    _unloaded = YES;
    _pausedForRecycle = NO;
    UIWindow * unityWindow = [self unityIsInitialized] ? [[[self ufw] appController] window] : nil;
    UIWindow * main = RNUnityHostWindow(self, unityWindow);
    if(main != nil) {
        [main makeKeyAndVisible];
    }

    // Unload even without a host window: skipping it silently leaves the engine resident.
    if([self unityIsInitialized]) {
        [[self ufw] unloadApplication];
    }
}

- (void)sendMessageToMobileApp:(NSString *)message {
    if (self.onUnityMessage) {
        NSDictionary* data = @{
            @"message": message
        };

        self.onUnityMessage(data);
    }
}

- (void)unityDidUnload:(NSNotification*)notification {
    if([self unityIsInitialized]) {
        [[self ufw] unregisterFrameworkListener:self];
        [self setUfw: nil];

        if (self.onPlayerUnload) {
            self.onPlayerUnload(nil);
        }
    }
}

- (void)unityDidQuit:(NSNotification*)notification {
    if([self unityIsInitialized]) {
        [[self ufw] unregisterFrameworkListener:self];
        [self setUfw: nil];

        if (self.onPlayerQuit) {
            self.onPlayerQuit(nil);
        }
    }
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onUnityMessage", @"onPlayerUnload", @"onPlayerQuit"];
}

- (void)postMessage:(NSString *)gameObject methodName:(NSString*)methodName message:(NSString*) message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self ufw] sendMessageToGOWithName:[gameObject UTF8String] functionName:[methodName UTF8String] message:[message UTF8String]];
    });
}

#ifdef RCT_NEW_ARCH_ENABLED
- (void)prepareForRecycle {
    [super prepareForRecycle];

    // Unity-as-a-Library is a single instance per process: unloading it on Fabric view
    // recycling kills the engine, and any later mount shows a black screen (#180).
    // Pause instead — the next mount resumes the same instance.
    if ([self unityIsInitialized]) {
      [[self ufw] pause:true];
      _pausedForRecycle = YES;
    }

    // <UnityView> calls unloadUnity on unmount. The recycled instance serves the next
    // mount, so clear the teardown latch or layoutSubviews never starts Unity again.
    _unloaded = NO;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
    return concreteComponentDescriptorProvider<RNUnityViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RNUnityViewProps>();
    _props = defaultProps;

    self.onUnityMessage = [self](NSDictionary* data) {
      if (_eventEmitter != nil) {
        auto gridViewEventEmitter = std::static_pointer_cast<RNUnityViewEventEmitter const>(_eventEmitter);
        facebook::react::RNUnityViewEventEmitter::OnUnityMessage event = {
          .message=[[data valueForKey:@"message"] UTF8String]
        };
        gridViewEventEmitter->onUnityMessage(event);
      }
    };

    // Fabric delivers events through the C++ EventEmitter, not the props blocks,
    // so onPlayerUnload/onPlayerQuit have to be wired the same way as onUnityMessage
    // or they never reach JS on the new architecture.
    self.onPlayerUnload = [self](NSDictionary* data) {
      if (_eventEmitter != nil) {
        auto emitter = std::static_pointer_cast<RNUnityViewEventEmitter const>(_eventEmitter);
        facebook::react::RNUnityViewEventEmitter::OnPlayerUnload event = {
          .message = data ? [[data valueForKey:@"message"] UTF8String] : ""
        };
        emitter->onPlayerUnload(event);
      }
    };

    self.onPlayerQuit = [self](NSDictionary* data) {
      if (_eventEmitter != nil) {
        auto emitter = std::static_pointer_cast<RNUnityViewEventEmitter const>(_eventEmitter);
        facebook::react::RNUnityViewEventEmitter::OnPlayerQuit event = {
          .message = data ? [[data valueForKey:@"message"] UTF8String] : ""
        };
        emitter->onPlayerQuit(event);
      }
    };
  }

  return self;
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter {
    [super updateEventEmitter:eventEmitter];
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps {
    if (![self unityIsInitialized]) {
      [self initUnityModule];
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)handleCommand:(nonnull const NSString *)commandName args:(nonnull const NSArray *)args {
    RCTRNUnityViewHandleCommand(self, commandName, args);
}

Class<RCTComponentViewProtocol> RNUnityViewCls(void) {
    return RNUnityView.class;
}

#else

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self initUnityModule];
    }

    return self;
}

#endif

@end
