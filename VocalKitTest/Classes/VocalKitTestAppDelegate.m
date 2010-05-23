//
//  VocalKitTestAppDelegate.m
//  VocalKitTest
//
//  Created by Brian King on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "HomeViewController.h"
#import "VocalKitTestAppDelegate.h"

@implementation VocalKitTestAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  // Override point for customization after app launch
  HomeViewController *controller = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
  
  [window addSubview:controller.view];
  [window makeKeyAndVisible];
	
	return YES;
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
