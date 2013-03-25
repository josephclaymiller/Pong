//
//  PongAppDelegate.h
//  Pong
//
//  Created by Joe Miller on 6/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PongViewController;

@interface PongAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PongViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PongViewController *viewController;

@end

