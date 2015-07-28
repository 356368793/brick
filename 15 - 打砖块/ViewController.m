//
//  ViewController.m
//  15 - 打砖块
//
//  Created by 肖晨 on 15/7/18.
//  Copyright (c) 2015年 肖晨. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *blockImages;
@property (weak, nonatomic) IBOutlet UIImageView *paddleImage;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic, strong)CADisplayLink *gameTimer; // 游戏时钟
@property (nonatomic, assign)CGPoint originBallCenter; // 小球初始中心点
@property (nonatomic, assign)CGPoint originPaddleCenter;
@property (nonatomic, assign)CGPoint ballValocity;     // 小球速度
@property (nonatomic, assign)CGFloat paddleValocityX;

@end

@implementation ViewController

// 与屏幕碰撞
- (void)intersectWithScreen{
    if (CGRectGetMidY(_ballImageView.frame) <= 0) {
        _ballValocity.y = ABS(_ballValocity.y);
    }
    
    if (CGRectGetMidY(_ballImageView.frame) >= self.view.bounds.size.height) {
        _tipLabel.hidden = NO;
        _tipLabel.text = @"你输了 %>_<%";
        [_gameTimer invalidate];
        [_tapGesture setEnabled:YES];
    }
    
    if (CGRectGetMaxX(_ballImageView.frame) >= self.view.bounds.size.width) {
        _ballValocity.x = -ABS(_ballValocity.x);
    }
    
    if (CGRectGetMinX(_ballImageView.frame) <= 0) {
        _ballValocity.x = ABS(_ballValocity.x);
    }
}

// 与砖块碰撞
- (void)intersectWithBlocks{

    for (UIImageView *block in _blockImages) {
        if (CGRectIntersectsRect(_ballImageView.frame, block.frame) && ![block isHidden]) {
            [block setHidden:YES];
            _ballValocity.y *= -1;
        }
    }
    BOOL win;
    for (UIImageView *block in _blockImages) {
        if (![block isHidden]) {
            win = NO;
            break;
        }
        if (win) {
            _tipLabel.hidden = NO;
            _tipLabel.text = @"你赢了！~~";
            [_gameTimer invalidate];
            [_tapGesture setEnabled:YES];
        }
    }
}

// 与挡板碰撞
- (void)intersectWithPaddle{
    if (CGRectIntersectsRect(_paddleImage.frame, _ballImageView.frame)) {
        _ballValocity.y *= -1;
        
        _ballValocity.x += _paddleValocityX / 120;
    }
}

// 拖拽挡板
- (IBAction)dragPaddle:(UIPanGestureRecognizer *)sender {
    if (UIGestureRecognizerStateChanged == sender.state){
        // 取出手指当前的位置
        CGPoint location = [sender locationInView:self.view];
        // 将挡板的位置设置为手指的水平位置
        [_paddleImage setCenter:CGPointMake(location.x, _paddleImage.center.y)];
        
        //记录挡板水平移动速度
        _paddleValocityX = [sender velocityInView:self.view].x;
    } else {
        _paddleValocityX = 0;
    }
}

// 点击屏幕开始游戏
- (IBAction)tapScreen:(UITapGestureRecognizer *)sender {
//    NSLog(@"tapScreen!!");
    
    _tipLabel.hidden = YES;
    
    // 初始化小球、挡板以及砖块的位置
    _ballImageView.center = _originBallCenter;
    _paddleImage.center = _originPaddleCenter;
    for (UIImageView *block in _blockImages) {
        [block setHidden:NO];
    }
    
    // 赋予小球改变的距离
    _ballValocity = CGPointMake(0, -5);
    
    // 定义游戏时钟
    _gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
    [_gameTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode: NSDefaultRunLoopMode];
    
    // 游戏开始，禁用手势
    [_tapGesture setEnabled:NO];
}

// 计时器
- (void)step{
    
    [self intersectWithScreen];
    [self intersectWithBlocks];
    [self intersectWithPaddle];
    
    [_ballImageView setCenter:CGPointMake(_ballImageView.center.x + _ballValocity.x, _ballImageView.center.y + _ballValocity.y)];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _originBallCenter = self.ballImageView.center;
    _originPaddleCenter = self.paddleImage.center;
}

@end
