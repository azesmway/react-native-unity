#import "RNUnityView.h"

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
        [ufw setExecuteHeader: &_mh_execute_header];
    }

    [ufw setDataBundleId: [bundle.bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding]];

    return ufw;
}

@implementation RNUnityView

NSDictionary* appLaunchOpts;

static RNUnityView *sharedInstance;

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

   if([self unityIsInitialized]) {
      self.ufw.appController.rootView.frame = self.bounds;
      [self addSubview:self.ufw.appController.rootView];
   }
}

- (void)pauseUnity:(BOOL * _Nonnull)pause {
    if([self unityIsInitialized]) {
        [[self ufw] pause:pause];
    }
}

- (void)unloadUnity {
    UIWindow * main = [[[UIApplication sharedApplication] delegate] window];
    if(main != nil) {
        [main makeKeyAndVisible];

        if([self unityIsInitialized]) {
            [[self ufw] unloadApplication];
        }
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

    if ([self unityIsInitialized]) {
      [[self ufw] unloadApplication];

      NSArray *viewsToRemove = self.subviews;
      for (UIView *v in viewsToRemove) {
          [v removeFromSuperview];
      }

      [self setUfw:nil];
    }
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
