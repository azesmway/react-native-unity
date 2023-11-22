#import <Foundation/Foundation.h>

@protocol NativeCallsProtocol
@required

- (void) sendMessageToMobileApp:(NSString*)message;

@end

__attribute__ ((visibility("default")))
@interface FrameworkLibAPI : NSObject

+(void) registerAPIforNativeCalls:(id<NativeCallsProtocol>) aApi;

@end
