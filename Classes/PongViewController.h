//
//  PongViewController.h
//  Pong
//
//  Created by Joe Miller on 6/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BallView.h"
#import "PaddleView.h"

@interface PongViewController : UIViewController <AVAudioPlayerDelegate> {
	NSTimer *animationTimer;
    int playerScore;
    int opponentScore;
    BOOL playing;
    int centerX;
    int centerY;
    int players;
    CGPoint lastTopTouchPoint;
    CGPoint lastBottomTouchPoint;
    BOOL soundOn;
    BOOL musicOn;
    BallView *ballView;
    PaddleView *paddlePlayer;
    PaddleView *paddleOpponent;
    int gamePoints;
    NSTimer *countDownTimer;
    UILabel *countDownLabel;
    int count;
    BOOL gameOver;
    NSTimer *opponentTimer;
    CGFloat opponentInterval;
    float playerPaddleXVelociy;
    int lastPaddleXPosition;
    float maxSpeed;
}

@property (nonatomic, retain) IBOutlet UIView *topView;
@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UILabel *playerScoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *opponentScoreLabel;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UILabel *gameMessage;
@property (nonatomic, retain) IBOutlet UISegmentedControl *playersSelector;
@property (nonatomic, retain) IBOutlet UISegmentedControl *difficultySelector;
@property (nonatomic, retain) IBOutlet UIView *startView;
@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) IBOutlet UIStepper *gamePointsStepper;
@property (nonatomic, retain) IBOutlet UILabel *gamePointsLabel;
@property (nonatomic, retain) AVAudioPlayer *myAudioPlayer;

@end

