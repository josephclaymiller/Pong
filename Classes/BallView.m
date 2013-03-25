//
//  BallView.m
//  Pong
//
//  Created by Joseph Miller on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BallView.h"

#define BALL_IMAGE_NAME @"ball.png";

#define MAX_SPEED 5.0f
#define MIN_SPEED 1.0f
#define DEGREES_TO_RADIANS(angle) ((angle) * M_PI / 180)
#define RADIANS_TO_DEGREES(angle) ((angle) * 180 / M_PI)

@implementation BallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        ballImageName = BALL_IMAGE_NAME;  
        height = frame.size.height;
        width = frame.size.width;
        x = frame.origin.x - width/2;
        y = frame.origin.y - height/2;
        home = CGPointMake(x, y);
        [self placeNewBall];
        self.userInteractionEnabled = NO;
        ballSpeed = MAX_SPEED;
    }
    return self;
}

// Private
- (void)placeNewBall
{
    UIImage *newBallImage = [UIImage imageNamed:ballImageName];
    UIImageView *newBallImageView = [[UIImageView alloc] initWithImage:newBallImage];    
    CGRect newBallRect = CGRectMake(x,y,width,height);
    [self setFrame:newBallRect];
    [self addSubview:newBallImageView];
    [newBallImageView release];
}

// Public
- (void)setRandomBallVelocity {
    int range = 360; // random angle to determine random ball velocity
    int randomAngle = (arc4random() % range);
    [self setAngle:randomAngle];
}

- (void)moveBall
{
    CGFloat newX = x + ballVelocity.x;
    CGFloat newY = y + ballVelocity.y;
    [self moveBallToX:newX andY:newY];
}

- (void)moveBallToX:(CGFloat)newX andY:(CGFloat)newY {
    x = newX;
    y = newY;
    CGRect newBallRect = CGRectMake(x,y,width,height);
    [self setFrame:newBallRect];
}

- (void)goHome {
    [self moveBallToX:home.x andY:home.y];
}

- (void)setBallSizeWidth:(CGFloat) newWidth andHeight:(CGFloat) newHeight {
    width = newWidth;
    height = newHeight;
    CGRect newBallRect = CGRectMake(x,y,width,height);
    [self setFrame:newBallRect];
}

- (void)setAngle:(int)angle {
    ballAngle = angle;
    CGFloat ballAngleInRadians = DEGREES_TO_RADIANS(angle);
    CGFloat newXVelocity = cosf(ballAngleInRadians) * ballSpeed;
    CGFloat newYVelocity = sinf(ballAngleInRadians) * ballSpeed;
    CGPoint newballVelocity = CGPointMake(newXVelocity, newYVelocity);
    ballVelocity = newballVelocity;
    NSLog(@"ball angle:%i in radians:%f", ballAngle, ballAngleInRadians);
}

- (void)addAngle:(int)angle {
    [self setAngle:((ballAngle + angle) % 360)];
}

- (void)setVelocity:(CGPoint)velocity {
    ballVelocity = velocity;
    CGFloat ballAngleInRadians = atan2(ballVelocity.x, ballVelocity.y);
    int ballAngleInDegrees = RADIANS_TO_DEGREES(ballAngleInRadians);
    ballAngle = ballAngleInDegrees;
}

- (void)addVelocity:(CGPoint)velocity {
    ballVelocity.x += velocity.x;
    ballVelocity.y += velocity.y;
    CGFloat ballAngleInRadians = atan2(ballVelocity.x, ballVelocity.y);
    int ballAngleInDegrees = RADIANS_TO_DEGREES(ballAngleInRadians);
    ballAngle = ballAngleInDegrees;
}

- (CGPoint)getVelocity {
    return ballVelocity;
}

- (void) reverseXVelocity {
    CGPoint newVelocity = CGPointMake(-ballVelocity.x, ballVelocity.y);
    [self setVelocity:newVelocity];
}

- (void) reverseYVelocity {
    CGPoint newVelocity = CGPointMake(ballVelocity.x, -ballVelocity.y);
    [self setVelocity:newVelocity];
}

- (CGFloat)getSpeed {
    return ballSpeed;
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
