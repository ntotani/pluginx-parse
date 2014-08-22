#import "UserParse.h"
#import "UserWrapper.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation UserParse

@synthesize debug = __debug;

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
    [Parse setApplicationId:cpInfo[@"ApplicationID"] clientKey:cpInfo[@"ClientKey"]];
    NSString* twitterConsumerKey = cpInfo[@"TwitterConsumerKey"];
    NSString* twitterConsumerSecret = cpInfo[@"TwitterConsumerSecret"];
    if (twitterConsumerKey != nil && twitterConsumerSecret != nil) {
        [PFTwitterUtils initializeWithConsumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecret];
    }
}

- (void) login
{
    PFLogInViewController* vc = [[PFLogInViewController alloc] init];
    vc.fields = PFLogInFieldsDefault | PFLogInFieldsTwitter;
    vc.delegate = self;
    [[AdsWrapper getCurrentRootViewController] presentViewController:vc animated:YES completion:nil];
}

- (void) logout
{
}

- (NSNumber*) isLogined
{
    return [PFUser currentUser] == nil ? @0 : @1;
}

- (NSString*) getSessionID
{
    if ([PFUser currentUser]) {
        return [PFUser currentUser].username;
    }
    return nil;
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    self.debug = isDebugMode;
}

- (NSString*) getSDKVersion
{
    return @"1.2.20";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:user.username];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:[error localizedDescription]];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"cancel"];
}

- (void)enableAutomaticUser
{
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
}

- (void)saveUserAttr:(NSMutableDictionary*)attrs
{
    NSNumber* runCount = attrs[@"Param1"];
    NSNumber* cupCount = attrs[@"Param2"];
    PFUser* user = [PFUser currentUser];
    user[@"runCount"] = runCount;
    user[@"cupCount"] = cupCount;
    [user saveInBackground];
}

- (NSNumber*)getUserAttr:(NSString*)attrName
{
    return [PFUser currentUser][attrName];
}

- (NSString*)twitterApi:(NSMutableDictionary*)params
{
    NSString* api = params[@"Param1"];
    params = params[@"Param2"];
    NSMutableArray* paramsArr = [@[] mutableCopy];
    for (NSString* e in params) {
        [paramsArr addObject:[NSString stringWithFormat:@"%@=%@", e, params[e]]];
    }
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/%@.json?%@", api, [paramsArr componentsJoinedByString:@"&"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSError* error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        OUTPUT_LOG(@"%@", [error localizedDescription]);
        return @"";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
