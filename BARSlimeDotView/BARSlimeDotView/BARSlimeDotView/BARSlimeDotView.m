//
//  BARSlimeDotView.m
//  BARSlimeDotView
//
//  Created by Barray on 2017/12/28.
//  Copyright © 2017年 Barray. All rights reserved.
//

#import "BARSlimeDotView.h"
#define SIN(a,b)           a/b
#define BARThemeColor      [UIColor redColor]
#define MOVEDOT_W          30.0f
#define FIXEDOT_SCALE_MIN  0.25  //允许的最小尺寸占 TRAILDOT_W_MAX 的比例
#define MAXDISTANCE        180
//#define <#macro#>

@interface BARSlimeDotView()

@property (nonatomic, strong) CALayer *moveDot;
@property (nonatomic, strong) CALayer *fixedDot;
@property (nonatomic, strong) CAShapeLayer *shapLayer;


@end

@implementation BARSlimeDotView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.shapLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        self.moveDot.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.fixedDot.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self.layer addSublayer:self.shapLayer];
        [self.layer addSublayer:self.moveDot];
        [self.layer addSublayer:self.fixedDot];
        UIPanGestureRecognizer *panGestrue = [[UIPanGestureRecognizer alloc] initWithTarget: self
                                                                                     action: @selector(panMoveDot:)];
        [self addGestureRecognizer:panGestrue];
    }
    return self;
}

#pragma mark - 绘制贝塞尔图形
- (void)reloadBeziePath{
    //半径
    CGFloat r1 = self.fixedDot.frame.size.width / 2.0f;
    CGFloat r2 = self.moveDot.frame.size.width / 2.0f;
    
    //中心
    CGFloat x1 = self.fixedDot.position.x;
    CGFloat y1 = self.fixedDot.position.y;
    CGFloat x2 = self.moveDot.position.x;
    CGFloat y2 = self.moveDot.position.y;
    
    //中心点距离
    CGFloat distance = sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2));
    
    //正弦，余弦值
    CGFloat sinDegree = (x2 - x1) / distance;
    CGFloat cosDegree = (y2 - y1) / distance;
    
    //贝塞尔图形点
    CGPoint pointA = CGPointMake(x1 - r1 * cosDegree, y1 + r1 * sinDegree);
    CGPoint pointB = CGPointMake(x1 + r1 * cosDegree, y1 - r1 * sinDegree);
    CGPoint pointC = CGPointMake(x2 + r2 * cosDegree, y2 - r2 * sinDegree);
    CGPoint pointD = CGPointMake(x2 - r2 * cosDegree, y2 + r2 * sinDegree);
    CGPoint pointN = CGPointMake(pointB.x + (distance / 2) * sinDegree, pointB.y + (distance / 2) * cosDegree);
    CGPoint pointM = CGPointMake(pointA.x + (distance / 2) * sinDegree, pointA.y + (distance / 2) * cosDegree);
    
    //绘制BezierPath
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointN];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointM];
    self.shapLayer.path = path.CGPath;
    self.shapLayer.hidden = NO;
}

#pragma mark - 计算圆心距
- (CGFloat) getDistanceBetweenDots {
    CGFloat x1 = self.fixedDot.position.x;
    CGFloat y1 = self.fixedDot.position.y;
    CGFloat x2 = self.moveDot.position.x;
    CGFloat y2 = self.moveDot.position.y;
    
    CGFloat distance = sqrt(pow((x1 - x2), 2) + pow((y1 - y2), 2));
    
    return distance;
}

#pragma mark - 拖动手势
- (void) panMoveDot: (UIPanGestureRecognizer *) panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateChanged: {
            // 记录手势位置
            CGPoint location = [panGesture locationInView: self];
            // moveDot跟随手指
            //需关闭CALayer默认的隐式动画效果
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.moveDot.position = location;
            [CATransaction commit];
            
            // 计算圆心距
            CGFloat distance = [self getDistanceBetweenDots];
            
            if (distance < MAXDISTANCE) {
                // 模拟当headDot移走后，trailDot按照圆心距变小
                // 当距离太远时，就不再发生改变
                //需关闭CALayer默认的隐式动画效果
                CGFloat scale = (1 - distance / MAXDISTANCE);
                scale = MAX(FIXEDOT_SCALE_MIN, scale);
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                self.fixedDot.hidden = NO;
                [self.fixedDot setAffineTransform:CGAffineTransformMakeScale(scale, scale)];
                [CATransaction commit];
                
                [self reloadBeziePath];
            } else {
                [self layerBroke];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            CGFloat distance = [self getDistanceBetweenDots];
            if (distance >= MAXDISTANCE) {
                [self removeFromSuperview];
            } else{
                [self placeMoveDot];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - 贝塞尔图像破裂动画
- (void) layerBroke {
    self.shapLayer.path = nil;
    [UIView animateWithDuration: 0.7f
                          delay: 0
         usingSpringWithDamping: 0.2
          initialSpringVelocity: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         [CATransaction begin];
                         [CATransaction setDisableActions:YES];
                         [self.fixedDot setAffineTransform:CGAffineTransformMakeScale(1, 1)];
                         [CATransaction commit];
                     }
                     completion:^(BOOL finished) {
                         self.fixedDot.hidden = YES;
                     }];
}

#pragma mark - 还原到原位置
- (void)placeMoveDot {
    [UIView animateWithDuration: 0.25f
                          delay: 0
         usingSpringWithDamping: 0.5
          initialSpringVelocity: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         [CATransaction begin];
                         [CATransaction setDisableActions:YES];
                         self.moveDot.position = CGPointMake((self.frame.size.width/2-self.moveDot.position.x)*0.25+self.frame.size.width/2, (self.frame.size.height/2-self.moveDot.position.y)*0.25+self.frame.size.height/2);
                         self.shapLayer.hidden = YES;
                         self.fixedDot.hidden = YES;
                         self.moveDot.backgroundColor = BARThemeColor.CGColor;
                         [CATransaction commit];
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration:0.1f delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                             self.moveDot.position = CGPointMake(self.frame.size.width/2, self.frame.size.width/2);
                         } completion:^(BOOL finished) {
                             self.fixedDot.hidden = NO;
                         }];
                         
                     }];
}

- (CALayer *)moveDot{
    if (!_moveDot) {
        _moveDot = [[CALayer alloc] init];
        _moveDot.frame = CGRectMake(0, 0, MOVEDOT_W, MOVEDOT_W);
        _moveDot.cornerRadius = MOVEDOT_W/2;
        _moveDot.backgroundColor = BARThemeColor.CGColor;
    }
    return _moveDot;
}

- (CALayer *)fixedDot{
    if (!_fixedDot) {
        _fixedDot = [[CALayer alloc] init];
        _fixedDot.frame = CGRectMake(0, 0, MOVEDOT_W, MOVEDOT_W);
        _fixedDot.cornerRadius = MOVEDOT_W/2;
        _fixedDot.backgroundColor = BARThemeColor.CGColor;
    }
    return _fixedDot;
}

- (CAShapeLayer *) shapLayer {
    if (!_shapLayer) {
        _shapLayer = [CAShapeLayer layer];
        _shapLayer.fillColor = BARThemeColor.CGColor;
        _shapLayer.position = CGPointMake(0, 0);
    }
    return _shapLayer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
