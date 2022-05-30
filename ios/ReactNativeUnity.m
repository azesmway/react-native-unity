#import "ReactNativeUnity.h"

UnityFramework* UnityFrameworkLoad()
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }

    [ufw setDataBundleId: [bundle.bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding]];

    return ufw;
}

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
    id ufw = UnityFrameworkLoad();
    [self setUfw: ufw];

    unsigned count = (int) [[[NSProcessInfo processInfo] arguments] count];
    char **array = (char **)malloc((count + 1) * sizeof(char*));

    for (unsigned i = 0; i < count; i++)
    {
         array[i] = strdup([[[[NSProcessInfo processInfo] arguments] objectAtIndex:i] UTF8String]);
    }
    array[count] = NULL;

    [[self ufw] runEmbeddedWithArgc: gArgc argv: array appLaunchOpts: applaunchOptions];

    return self.ufw;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onUnityMessage", @"onPlayerUnload", @"onPlayerQuit"];
}

@end
