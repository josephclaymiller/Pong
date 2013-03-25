//
//  BallView.h
//  Pong
//
//  Created by Joseph Miller on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BallView : UIView {
    NSString *ballImageName;
    UIImage *ballImage;

	CGFloat height;
	CGFloat width;	
    CGFloat x;
	CGFloat y;
    CGPoint home;
	
    CGFloat ballSpeed;
    int ballAngle;
	//CGFloat ballXVelocity;
	//CGFloat ballYVelocity;
    
    CGPoint ballVelocity;
}

- (void)setBallSizeWidth:(CGFloat)newWidth andHeight:(CGFloat)newHeight;
- (void)moveBall;
- (void)moveBallToX:(CGFloat)newX andY:(CGFloat) newY;
- (void)setVelocity:(CGPoint)velocity;
- (void)addVelocity:(CGPoint)velocity;
- (CGPoint)getVelocity;
- (void)goHome;
- (void)setRandomBallVelocity;
- (void)setAngle:(int)angle;
- (void)addAngle:(int)angle;
- (void)reverseXVelocity;
- (void)reverseYVelocity;
- (CGFloat)getSpeed;

@end
