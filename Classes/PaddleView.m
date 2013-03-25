//
//  PaddleView.m
//  Pong
//
//  Created by Joseph Miller on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaddleView.h"

#define PADDLE_IMAGE_NAME @"paddle.png"
#define NORMAL_SPEED 2.5f

@implementation PaddleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        paddleImageName = PADDLE_IMAGE_NAME;  
        height = frame.size.height;
        width = frame.size.width;
        x = frame.origin.x - width/2;
        y = frame.origin.y - height/2;
        home = CGPointMake(x, y);
        UIImage *newPaddleImage = [UIImage imageNamed:paddleImageName];
        UIImageView *newPaddleImageView = [[UIImageView alloc] initWithImage:newPaddleImage];    
        CGRect newPaddleRect = CGRectMake(x,y,width,height);
        [self setFrame:newPaddleRect];
        [self addSubview:newPaddleImageView];
        [newPaddleImageView release];
        self.userInteractionEnabled = NO;
        speed = NORMAL_SPEED;
        paddleXVelocity = speed;
    }
    return self;
}

// Public
- (void)movePaddle
{
    CGFloat newX = x + paddleXVelocity;
    [self movePaddleToX:newX andY:y];
}

- (void)movePaddleToX:(CGFloat) newX andY:(CGFloat) newY {
    x = newX;
    y = newY;
    CGRect newPaddleRect = CGRectMake(x,y,width,height);
    [self setFrame:newPaddleRect];
}

- (void)setPaddleSizeWidth:(CGFloat) newWidth andHeight:(CGFloat) newHeight {
    width = newWidth;
    height = newHeight;
    CGRect newPaddleRect = CGRectMake(x,y,width,height);
    [self setFrame:newPaddleRect];
}

- (void)setXVelocity:(CGFloat) velocity {
    paddleXVelocity = velocity;
}

- (CGFloat)getXVelocity {
    return paddleXVelocity;
}

- (void)reverseXVelocity {
    paddleXVelocity = -paddleXVelocity;
}

- (void)setSpeed:(CGFloat) newSpeed {
    speed = newSpeed;
    if (paddleXVelocity < 0) {
        paddleXVelocity = -newSpeed;
    } else {
        paddleXVelocity = newSpeed;
    }
}

- (CGFloat)getSpeed{
    return speed;
}

- (void)goHome {
    [self movePaddleToX:home.x andY:home.y];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
