#import <Foundation/Foundation.h>
#import "InterfaceUser.h"
#import <Parse/Parse.h>

@interface UserParse : NSObject <InterfaceUser, PFLogInViewControllerDelegate>
{
}

@property BOOL debug;

/**
 interfaces from InterfaceUser
 */
- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
- (void) login;
- (void) logout;
- (BOOL) isLogined;
- (NSString*) getSessionID;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user;
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error;
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController;

- (NSString*)twitterApi:(NSMutableDictionary*)params;

@end
