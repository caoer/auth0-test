// A0WebViewAuthenticator.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0WebViewAuthenticator.h"
#import "A0WebViewController.h"
#import "A0WebKitViewController.h"
#import "A0Theme.h"
#import "A0ModalPresenter.h"

NSString * const A0WebViewAuthenticatorTitleBarTintColor = @"A0WebViewAuthenticatorTitleBarTintColor";
NSString * const A0WebViewAuthenticatorTitleBarBarTintColor = @"A0WebViewAuthenticatorTitleBarBarTintColor";
NSString * const A0WebViewAuthenticatorTitleTextColor = @"A0WebViewAuthenticatorTitleTextColor";
NSString * const A0WebViewAuthenticatorTitleTextFont = @"A0WebViewAuthenticatorTitleTextFont";

@interface A0WebViewAuthenticator ()
@property (strong, nonatomic) A0APIClient *client;
@property (copy, nonatomic) NSString *connectionName;
@end

@implementation A0WebViewAuthenticator

-(instancetype)initWithConnectionName:(NSString * __nonnull)connectionName client:(A0APIClient * __nonnull)client {
    self = [super init];
    if (self) {
        _client = client;
        _connectionName = [connectionName copy];
    }
    return self;
}

- (void)authenticateWithParameters:(A0AuthParameters * __nonnull)parameters success:(A0IdPAuthenticationBlock __nonnull)success failure:(A0IdPAuthenticationErrorBlock __nonnull)failure {
    UIViewController<A0WebAuthenticable> *controller = [self newWebControllerWithParameters:parameters];
    controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    controller.onAuthentication = success;
    controller.onFailure = failure;
    controller.localizedCancelButtonTitle = self.localizedCancelButtonTitle;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    [self applyThemeToNavigationBar:navigation.navigationBar];
    A0ModalPresenter *presenter = [[A0ModalPresenter alloc] init];
    [presenter presentController:navigation completion:nil];
}

- (BOOL)handleURL:(NSURL * __nonnull)url sourceApplication:(nullable NSString *)sourceApplication {
    return NO;
}

- (NSString * __nonnull)identifier {
    return self.connectionName;
}

- (void)clearSessions {
}

- (UIViewController<A0WebAuthenticable> *)newWebControllerWithParameters:(A0AuthParameters *)parameters {
    if (NSClassFromString(@"WKWebView")) {
        return [[A0WebKitViewController alloc] initWithAPIClient:self.client connectionName:self.connectionName parameters:parameters];
    } else {
        return [[A0WebViewController alloc] initWithAPIClient:self.client connectionName:self.connectionName parameters:parameters];
    }
}

- (void)applyThemeToNavigationBar:(UINavigationBar *)navigationBar {
    A0Theme *theme = [A0Theme sharedInstance];
    navigationBar.barTintColor = [theme colorForKey:A0WebViewAuthenticatorTitleBarBarTintColor defaultColor:navigationBar.barTintColor];
    navigationBar.tintColor = [theme colorForKey:A0WebViewAuthenticatorTitleBarTintColor defaultColor:navigationBar.tintColor];
    navigationBar.translucent = YES;
    UIFont *titleFont = [theme fontForKey:A0WebViewAuthenticatorTitleTextFont];
    UIColor *titleTextColor = [theme colorForKey:A0WebViewAuthenticatorTitleTextColor];
    NSMutableDictionary *attributes = [@{} mutableCopy];
    if (titleFont) {
        attributes[NSFontAttributeName] = titleFont;
    }
    if (titleTextColor) {
        attributes[NSForegroundColorAttributeName] = titleTextColor;
    }
    if (attributes.count != 0) {
        navigationBar.titleTextAttributes = attributes;
    }
}
@end
