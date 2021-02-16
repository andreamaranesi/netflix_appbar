#import "NetflixAppbarPlugin.h"
#if __has_include(<netflix_appbar/netflix_appbar-Swift.h>)
#import <netflix_appbar/netflix_appbar-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "netflix_appbar-Swift.h"
#endif

@implementation NetflixAppbarPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNetflixAppbarPlugin registerWithRegistrar:registrar];
}
@end
