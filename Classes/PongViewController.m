//
//  PongViewController.m
//  Pong
//
//  Created by Joe Miller on 6/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PongViewController.h"

#define ANIMATION_INTERVAL 0.02f
#define AI_INTERVAL 0.5f
#define EASY_SPEED 1.5f
#define NORMAL_SPEED 2.5f
#define HARD_SPEED 3.5f
#define SHORT_INTERVAL 0.25f
#define NORMAL_INTERVAL 0.5f
#define LONG_INTERVAL 0.75f
#define GAME_POINTS 5
#define BALL_SIZE 20
#define PADDLE_WIDTH 100
#define PADDLE_THICKNESS 20
#define COUNT_DOWN_INTERVAL 1.0f
#define COUNT_DOWN 3
#define TEXT_BUFFER 40
#define SOUND_HIT_WALL @"pong_2"
#define SOUND_HIT_PADDLE @"pong_4"
#define SOUND_MISS @"pong_8"
#define SOUND_START_GAME @"go"
#define SOUND_END_GAME  @"game_over"
#define SOUND_FILE_TYPE @"wav"
#define SOUND_BUTTON_CLICK @"pong_9"
#define SOUND_COUNT_DOWN @"pong_7"

@interface PongViewController()
@end

@implementation PongViewController
@synthesize topView = _topView;
@synthesize bottomView = _bottomView;
@synthesize playerScoreLabel = _playerScoreLabel;
@synthesize opponentScoreLabel = _opponentScoreLabel;
@synthesize startButton = _startButton;
@synthesize gameMessage = _gameMessage;
@synthesize playersSelector = _playersSelector;
@synthesize difficultySelector = _difficultySelector;
@synthesize startView = _startView;
@synthesize optionsView = _optionsView;
@synthesize gamePointsStepper = _gamePointsStepper;
@synthesize gamePointsLabel = _gamePointsLabel;
@synthesize myAudioPlayer = _myAudioPlayer;


- (void)setUpGame {
    centerX = self.view.frame.size.width/2;
    centerY = self.view.frame.size.height/2;
    players = [self.playersSelector  selectedSegmentIndex]+1;
    [self.difficultySelector setSelectedSegmentIndex:1];
    int difficultyLevel = [self.difficultySelector selectedSegmentIndex];
    [self setDifficulty:difficultyLevel];
    playing = NO;
    soundOn = YES;
    musicOn = YES;   
    CGRect ballRect = CGRectMake(centerX,centerY,BALL_SIZE,BALL_SIZE);
    CGRect opponentPaddleRect = CGRectMake(centerX, PADDLE_THICKNESS/2, PADDLE_WIDTH, PADDLE_THICKNESS);
    CGRect playerPaddleRect = CGRectMake(centerX, self.view.frame.size.height - PADDLE_THICKNESS/2, PADDLE_WIDTH, PADDLE_THICKNESS);
    ballView = [[BallView alloc] initWithFrame:ballRect];
    paddlePlayer = [[PaddleView alloc] initWithFrame:playerPaddleRect];
    paddleOpponent = [[PaddleView alloc] initWithFrame:opponentPaddleRect];
    gamePoints = GAME_POINTS;
    [self.gamePointsStepper setValue:gamePoints];
    NSString *pointsText = [NSString stringWithFormat:@"%d", gamePoints];
    [self.gamePointsLabel setText:pointsText];
    countDownLabel = [[UILabel alloc] init];
    CGRect countDownLabelFrame = CGRectMake(centerX - 20, centerY - 20, 40, 40);
    [countDownLabel setFrame:countDownLabelFrame];
    [countDownLabel setTextColor:[UIColor whiteColor]];
    [countDownLabel setBackgroundColor:[UIColor blackColor]];
    [countDownLabel setTextAlignment:UITextAlignmentCenter];
    [countDownLabel setFont:[UIFont systemFontOfSize:32]];
}

- (void)resetGame
{
    playing = YES;
    // Set scores to 0
    playerScore = 0;
    opponentScore = 0;
    self.playerScoreLabel.text = @"0";
    self.opponentScoreLabel.text = @"0";
    //  Hide Start View
    if (self.startView.superview) {
        [self.startView removeFromSuperview];
    }  if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    // Center paddles at the start of each game
    [paddlePlayer goHome];   
    lastPaddleXPosition = paddlePlayer.frame.origin.x;
    [paddleOpponent goHome];
    [self setUpRound];
}

// at start of each round
- (void)setUpRound
{
    NSLog(@"set up round");
    [ballView goHome];
    // If single player, reset opponent paddle    
    if (players == 1) {
        [paddleOpponent goHome];
    }
    count = COUNT_DOWN;
	countDownTimer = [NSTimer scheduledTimerWithTimeInterval: COUNT_DOWN_INTERVAL target: self selector: @selector(coutDownTimerFired:) userInfo: nil repeats: YES];
    [self.view addSubview:countDownLabel];
    NSString *countString = [NSString stringWithFormat:@"%i", count];
    [countDownLabel setText:countString];
}    

- (void) startRound {
    gameOver = NO;
    playing = YES;
    if (countDownLabel.superview) {
        [countDownLabel removeFromSuperview];
    }
    [countDownTimer invalidate];
    int range = 90;
    int minAngle = 225;
    if (players == 2 && (arc4random() % 2 > 0)) {
        minAngle = 45;
    }
    int randomAngle = (arc4random() % range) + minAngle;
    [ballView setAngle:randomAngle];
    // Set animation timer to move the ball and the opponent paddle
	animationTimer = [NSTimer scheduledTimerWithTimeInterval: ANIMATION_INTERVAL target: self selector: @selector(timerFired:) userInfo: nil repeats: YES];
    opponentTimer = [NSTimer scheduledTimerWithTimeInterval: (opponentInterval) target: self selector: @selector(opponentTimerFired:) userInfo: nil repeats: YES];
}

- (void) endRound {
    [ballView setVelocity:(CGPointMake(0, 0))];
    [opponentTimer invalidate];
    [animationTimer invalidate];
    if(!gameOver) {
        [self playSoundFile:SOUND_MISS ofType:SOUND_FILE_TYPE];
        [self setUpRound];
    }
}

- (void) displayEndGameMessage:(int)winner {
    NSString *endGameMessage;
    NSString *messagePlayer = @"You";
    NSString *messageEvent = @"Won!";
    gameOver = YES;
    if ((players == 1) && (winner > 1)) {
        messageEvent = @"Lost";
    } else if (players == 2) {
        messagePlayer = [NSString stringWithFormat: @"Player %i", winner];
    }
    endGameMessage = [NSString stringWithFormat:@"%@ %@", messagePlayer, messageEvent];
    [self.gameMessage setText:endGameMessage];
    NSLog(@"%@",self.gameMessage.text);
    // change start button text
    [self.startButton setTitle:@"Play Again" forState:UIControlStateNormal];
    int newButtonWidth = self.startButton.titleLabel.frame.size.width + TEXT_BUFFER;
    CGRect widerButton = CGRectMake(centerX - newButtonWidth/2, self.startButton.frame.origin.y, newButtonWidth, self.startButton.frame.size.height);
    [self.startButton setFrame:widerButton];
}

- (void)endGame
{
    int winner;
    NSLog(@"Game Over");
    playing = NO;
    // display win/lose
    if (playerScore > opponentScore) {
        winner = 1;
    } else {
        winner = 2;
    }
    if (countDownLabel.superview) {
        [countDownLabel removeFromSuperview];
    }
    // change game message
    [self displayEndGameMessage:winner];
    // return to start view
    [self.view addSubview:self.startView];
    [self playSoundFile:SOUND_END_GAME ofType:SOUND_FILE_TYPE];
}

- (void) increaseScore:(int) score ofPlayer:(UIView *) player {
    if ([player isEqual:paddlePlayer]) {
        playerScore += score;
        NSLog(@"Player score %i",playerScore);
        NSString *playerScoreText = [NSString stringWithFormat:@"%d", playerScore];
        self.playerScoreLabel.text = playerScoreText;
    }
    if ([player isEqual:paddleOpponent]) {
        opponentScore += score;
        NSLog(@"Opponent score: %i",opponentScore);
        NSString *opponentScoreText = [NSString stringWithFormat:@"%d", opponentScore];
        self.opponentScoreLabel.text = opponentScoreText;
    }
    if ((opponentScore >= gamePoints) || (playerScore >= gamePoints)) {
        [self endGame];
    }
}

// Check Ball Collision with walls
- (void)checkBallCollisionWithWalls
{
    float ballXVelocity = [ballView getVelocity].x;
    BOOL reverseXVelocity = NO;
    // detect collision with edges and reverse ball direction
    if (ballView.frame.origin.x >= (self.view.bounds.size.width - ballView.frame.size.width) && ballXVelocity > 0) {
        reverseXVelocity = YES;
    }
    if (ballView.frame.origin.x  <= 0 && ballXVelocity < 0) {
        reverseXVelocity = YES;
    } 
    if (reverseXVelocity) {
        [ballView reverseXVelocity];
        [self playSoundFile:SOUND_HIT_WALL ofType:SOUND_FILE_TYPE];
    }
}

- (BOOL)ballCollisionWith:(UIView *)paddle {
    CGPoint ballPosition = ballView.frame.origin;
    CGPoint paddlePosition = paddle.frame.origin;
    float ballOffset = ballView.frame.size.height/2;
    float paddleWidth = paddle.frame.size.width;
    float paddleOuterRangeLeft = paddlePosition.x - ballOffset;
    float paddleOuterRangeRight = paddlePosition.x + paddleWidth;
    // Check Paddle and Ball Collision
    if (ballPosition.x >= paddleOuterRangeLeft && ballPosition.x <= paddleOuterRangeRight) {
        return YES;
    }
    return NO;
}

// Check Ball Collision with Paddles 
- (void)checkBallCollisionDetectionPaddles
{
    CGPoint ballVelocity = [ballView getVelocity];
    BOOL roundOver = NO;
    BOOL bounce = NO;
    float ballOffset = ballView.frame.size.height;
    CGPoint ballPosition = ballView.frame.origin;
        
    // Player goal line
    if (ballPosition.y >= self.view.bounds.size.height-(ballOffset+paddlePlayer.frame.size.height) && ballVelocity.y > 0) {
        // Check Player Paddle and Ball Collision
        if ([self ballCollisionWith:paddlePlayer]) {
            NSLog(@"Player Hit Ball");
            CGPoint velocityIncrease = CGPointMake(playerPaddleXVelociy, 0);
            [ballView addVelocity:velocityIncrease];
            bounce = YES;
        }
        // Player missed ball
        if (ballPosition.y >= self.view.bounds.size.height-ballOffset) {
            // Opponent scores a point if ball hits the bottom of the screen
            [self increaseScore:1 ofPlayer:paddleOpponent];
            roundOver = YES;
        } 
    }
    // Opponenet goal line
    if (ballView.frame.origin.y <= ballOffset && ballVelocity.y < 0) {
        if ([self ballCollisionWith:paddleOpponent]) {
            NSLog(@"Opponent Hit Ball");   
            CGPoint velocityIncrease = CGPointMake([paddleOpponent getXVelocity], 0);
            [ballView addVelocity:velocityIncrease];
            bounce = YES;
        }        
        // Opponent missed ball
        if (ballView.frame.origin.y <= 0) {
            // Player scores a point if ball hits the top of the screen
            [self increaseScore:1 ofPlayer:paddlePlayer];
            roundOver = YES;
        }       
    }  
    if (bounce) {
        [ballView reverseYVelocity];
        [self playSoundFile:SOUND_HIT_PADDLE ofType:SOUND_FILE_TYPE];
    }
    if (roundOver) {
        [self endRound];
    }
}

// Move the ball
- (void)moveBall
{
    if (playing) {
        [self checkBallCollisionWithWalls];
        [self checkBallCollisionDetectionPaddles];
        [ballView moveBall];
    }
}

// Move the opponent paddle
- (void)moveOpponentPaddle
{
    [paddleOpponent movePaddle];
    if ((paddleOpponent.frame.origin.x < 0) || ((paddleOpponent.frame.origin.x + paddleOpponent.frame.size.width) > self.view.frame.size.width)){
        [paddleOpponent reverseXVelocity];
    }
}

- (void)checkPlayerPaddlePosition {
    playerPaddleXVelociy = paddlePlayer.frame.origin.x - lastPaddleXPosition;
    if (playerPaddleXVelociy > maxSpeed) {
        playerPaddleXVelociy = maxSpeed;
    } else if (playerPaddleXVelociy < -maxSpeed) {
        playerPaddleXVelociy = -maxSpeed;
    }
    lastPaddleXPosition = paddlePlayer.frame.origin.x;
}

- (void)opponentAI {
    int opponentPaddleCenter = paddleOpponent.frame.origin.x + paddleOpponent.frame.size.width/2;
    //float tolerance = paddleOpponent.frame.size.width/2 - ballView.frame.size.width;
    float ballXPosition = ballView.frame.origin.x;
    float opponentPaddleXVelociy = [paddleOpponent getXVelocity];
    float ballDistanceFromPaddleCenter = (ballXPosition - opponentPaddleCenter);   
    float newVelocity = [paddleOpponent getSpeed];
    //if (((opponentPaddleXVelociy < 0) && (ballXPosition > (opponentPaddleCenter + tolerance))) || ((opponentPaddleXVelociy > 0) &&(ballXPosition < (opponentPaddleCenter - tolerance)))) {
      //  [paddleOpponent reverseXVelocity];
    //}
    if (abs(ballDistanceFromPaddleCenter) < abs(opponentPaddleXVelociy)) {
        [paddleOpponent setXVelocity:ballDistanceFromPaddleCenter];
        NSLog(@"new velocity %f", ballDistanceFromPaddleCenter);
    } else {
        if (ballDistanceFromPaddleCenter < 0) {
            newVelocity *= -1;
        }
        [paddleOpponent setXVelocity:newVelocity];
    }
}

- (void)movePaddle:(UIView *)paddle alongXAxis:(int)distance {
    //NSLog(@"Distance paddle%@ moved=%g", paddle, distance);
    CGFloat xCoords = paddle.frame.origin.x;
    CGFloat xMove = xCoords + distance;
    if (xMove < 0) {
        xMove = 0;
    }
    if (xMove > (self.view.frame.size.width - paddle.frame.size.width)) {
        xMove = self.view.frame.size.width - paddle.frame.size.width;
    }
    CGRect playerPaddlePosition = CGRectMake(xMove, paddle.frame.origin.y, paddle.frame.size.width, paddle.frame.size.height);
    [paddle setFrame:playerPaddlePosition];
}

// Sound
- (void) playSoundFile:(NSString *)path ofType:(NSString *)type {
     if (soundOn) {
    NSString *soundFIlePath = [[NSBundle mainBundle] pathForResource:path ofType:type];
    if (!soundFIlePath) {
        NSLog(@"Incorrect path for sound file");
        return;
    }
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFIlePath];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.myAudioPlayer = newPlayer;
    [fileURL release];
    [newPlayer release];
    [_myAudioPlayer prepareToPlay];
    [_myAudioPlayer setDelegate: self];
    [self.myAudioPlayer play];
     }
}

- (void) stopSound {
    if (self.myAudioPlayer.playing) {
        [self.myAudioPlayer stop];
    }
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player successfully: (BOOL) completed {
    if (completed == YES) {
        [_myAudioPlayer release];
        _myAudioPlayer = NULL;
    }
}

// Timer events
- (void)timerFired:(NSTimer*) timer {
	//NSLog(@"Timer");
    [self moveBall];
    if (players == 1) {
        [self moveOpponentPaddle];
    }
    [self checkPlayerPaddlePosition];
}

- (void)opponentTimerFired:(NSTimer*) timer {
    //NSLog(@"Opponent move");
    [self opponentAI];
}

- (void)coutDownTimerFired:(NSTimer *) timer {
    // countdown timer shows label  3 ... 2 ... 1
    if (count-- <= 1) {
        [self startRound];
        [self playSoundFile:SOUND_START_GAME ofType:SOUND_FILE_TYPE];
        return;
    }
    NSLog(@"countdown %i", count);
    NSString *countString = [NSString stringWithFormat:@"%i", count];
    [countDownLabel setText:countString];
    [self playSoundFile:SOUND_COUNT_DOWN ofType:SOUND_FILE_TYPE];
}

// Stepper
- (IBAction)setGamePoints:(UIStepper *)sender {
    gamePoints = [sender value];
    NSString *pointsText = [NSString stringWithFormat:@"%d", gamePoints];
    [self.gamePointsLabel setText:pointsText];
    [self playSoundFile:SOUND_BUTTON_CLICK ofType:SOUND_FILE_TYPE];
}


// Switch Events
- (IBAction)toggleSound:(id)sender {
    NSLog(@"toggle sound");
    NSLog(@"sender %@", sender);
    if (soundOn) {
        soundOn = NO;
    } else {
        soundOn = YES;
    }
    [self playSoundFile:SOUND_BUTTON_CLICK ofType:SOUND_FILE_TYPE];
}


// Button Events
- (IBAction)tapToStart 
{
    [self.view addSubview:paddlePlayer];
    [self.view addSubview:paddleOpponent];
    [self.view addSubview:ballView];
    [self.view addSubview:self.playerScoreLabel];
    [self.view addSubview:self.opponentScoreLabel];
    [self resetGame];
    [ballView goHome]; // reset the ball to the center
    [self playSoundFile:SOUND_BUTTON_CLICK ofType:SOUND_FILE_TYPE];
}

- (IBAction)selectOptions:(UIButton *)sender {
    [self.view addSubview:self.optionsView];
    [self playSoundFile:SOUND_BUTTON_CLICK ofType:SOUND_FILE_TYPE];
}

- (IBAction)selectBack {
    if ([self.optionsView superview]) {
        [self.optionsView removeFromSuperview];
    }
    [self playSoundFile:SOUND_BUTTON_CLICK ofType:SOUND_FILE_TYPE];
}

- (IBAction)selectNumberOfPlayers:(UISegmentedControl *)sender {
    int selectedNumberOfPlayers = [sender selectedSegmentIndex]+1;
    players = selectedNumberOfPlayers;
    NSLog(@"%i player(s)", players);
    if (self.difficultySelector.superview && selectedNumberOfPlayers > 1) {
        [self.difficultySelector removeFromSuperview];
    }
    else if (selectedNumberOfPlayers == 1) {
        [self.optionsView addSubview:self.difficultySelector];
    }
    [self playSoundFile:SOUND_BUTTON_CLICK ofType:SOUND_FILE_TYPE];
}

- (void) setDifficulty:(int)selectedDifficulty {
    NSLog(@"Selected Level of difficulty %i", selectedDifficulty);
    if (selectedDifficulty == 0) {
        maxSpeed = (EASY_SPEED);
        opponentInterval = LONG_INTERVAL;
    } else if (selectedDifficulty == 1) {
        maxSpeed = (NORMAL_SPEED);
        opponentInterval = NORMAL_INTERVAL;
    } else if (selectedDifficulty == 2) {
        maxSpeed = (HARD_SPEED); 
        opponentInterval = SHORT_INTERVAL;
    }
    [paddleOpponent setSpeed:(maxSpeed)]; 
}

- (IBAction)selectLevelOfDifficulty:(UISegmentedControl *)sender {
    int selectedDifficulty = [sender selectedSegmentIndex];
    [self setDifficulty:selectedDifficulty];
    [self playSoundFile:SOUND_BUTTON_CLICK ofType:SOUND_FILE_TYPE];
}

// Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *topViewTouches = [event touchesForView:self.topView];
    NSSet *bottomViewTouches = [event touchesForView:self.bottomView];
    UITouch *topViewTouch = [topViewTouches anyObject];
    UITouch *bottomViewTouch = [bottomViewTouches anyObject];
    lastTopTouchPoint = [topViewTouch locationInView:self.view];
    lastBottomTouchPoint = [bottomViewTouch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *topViewTouches = [event touchesForView:self.topView];
    NSSet *bottomViewTouches = [event touchesForView:self.bottomView];
    UITouch *topViewTouch = [topViewTouches anyObject];
    UITouch *bottomViewTouch = [bottomViewTouches anyObject];
    CGPoint currentTopTouchPosition = [topViewTouch locationInView:self.view];
    CGPoint currentBottomTouchPosition = [bottomViewTouch locationInView:self.view];
    CGFloat distanceMovedTop = currentTopTouchPosition.x - lastTopTouchPoint.x;
    CGFloat distanceMovedBottom = currentBottomTouchPosition.x - lastBottomTouchPoint.x;
    [self movePaddle:paddlePlayer alongXAxis:distanceMovedBottom];
    if (players == 2) {
        [self movePaddle:paddleOpponent alongXAxis:distanceMovedTop];
    }
    lastTopTouchPoint = currentTopTouchPosition;
    lastBottomTouchPoint = currentBottomTouchPosition;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    lastTopTouchPoint = CGPointZero;
    lastBottomTouchPoint = CGPointZero;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    lastTopTouchPoint = CGPointZero;
    lastBottomTouchPoint = CGPointZero;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"View Loaded");
    if ([self.optionsView superview]) {
        [self.optionsView removeFromSuperview];
    }
    [self setUpGame];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [_playerScoreLabel release];
    _playerScoreLabel = nil;
    [_opponentScoreLabel release];
    _opponentScoreLabel = nil;
    [_startButton release];
    _startButton = nil;
    [_gameMessage release];
    _gameMessage = nil;
    [_optionsView release];
    _optionsView = nil;
    [ballView release];
    ballView = nil;
    [paddlePlayer release];
    paddlePlayer = nil;
    [paddleOpponent release];
    paddleOpponent = nil;
    [_gamePointsStepper release];
    _gamePointsStepper = nil;
    [_gamePointsLabel release];
    _gamePointsLabel = nil;
    
    [super dealloc];
}

@end
