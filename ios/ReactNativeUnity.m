#import "ReactNativeUnity.h"

int gArgc = 1;

@implementation ReactNativeUnity

static id<RNUnityFramework> Unity_ufw;

+ (id<RNUnityFramework>)ufw {
    @synchronized (self) {
        return Unity_ufw;
    }
}

+ (void)setUfw:(id<RNUnityFramework>)ufw {
    @synchronized (self) {
        Unity_ufw = ufw;
    }
}

+ (id<RNUnityFramework>) launchWithOptions:(NSDictionary*)applaunchOptions {

    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    id<RNUnityFramework> framework = [bundle.principalClass getInstance];

    if (![framework appController]) {
        [framework setExecuteHeader: &_mh_execute_header];
    }

    [framework setDataBundleId: [bundle.bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding]];

    unsigned count = (int) [[[NSProcessInfo processInfo] arguments] count];
    char **array = (char **)malloc((count + 1) * sizeof(char*));

    for (unsigned i = 0; i < count; i++)
    {
         array[i] = strdup([[[[NSProcessInfo processInfo] arguments] objectAtIndex:i] UTF8String]);
    }
    array[count] = NULL;

    [framework runEmbeddedWithArgc: gArgc argv: array appLaunchOpts: applaunchOptions];

    [self setUfw:framework];
    [framework registerFrameworkListener:self.ufw];

    return self.ufw;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onUnityMessage"];
}

@end
