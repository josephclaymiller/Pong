//
//  PaddleView.h
//  Pong
//
//  Created by Joseph Miller on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaddleView : UIView {
    CGFloat x;
    CGFloat y;
    CGFloat height;
    CGFloat width;

    CGFloat paddleXVelocity;
    
    NSString *paddleImageName;
    UIImage *paddleImage;
    
    CGPoint home;
    
    CGFloat speed;
}

- (void)movePaddle;
- (void)movePaddleToX:(CGFloat) newX andY:(CGFloat) newY;
- (void)setPaddleSizeWidth:(CGFloat) newWidth andHeight:(CGFloat) newHeight;
- (void)setXVelocity:(CGFloat) velocity;
- (CGFloat)getXVelocity;
- (void)goHome;
- (void)setSpeed:(CGFloat) newSpeed;
- (CGFloat)getSpeed;
- (void)reverseXVelocity;

@end
