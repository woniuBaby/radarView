//
//  YJCRadarView.m
//  radarViewDemo
//
//  Created by MeetYou on 2024/5/8.
//

#import "YJCRadarView.h"

#define ANGLE_COS(Angle) cos(M_PI / 180 * (Angle))
#define ANGLE_SIN(Angle) sin(M_PI / 180 * (Angle))


@interface YJCRadarView ()<CAAnimationDelegate>
{
    CGFloat _centerX;
    CGFloat _centerY;
    BOOL    _toDraw;
}
@property (nonatomic, assign) NSInteger                                     sideNum; //几边形
@property (nonatomic, strong) NSArray<NSArray<NSValue *> *>                 *cornerPointArrs; //线圈交点

@property (nonatomic, strong) NSArray<NSValue *>                            *valuePoints;// 阴影交点数组
@property (nonatomic, strong) CAShapeLayer                                  *valueLayer;
@property (nonatomic, strong) UIBezierPath                                  *valuePath;
@property (nonatomic, strong) UIBezierPath                                  *oldvaluePath;
@property (nonatomic, strong) CAGradientLayer                               *gradientLayer;//渐变

@property (nonatomic,strong)CAAnimationGroup *newanimationGroup;

@property (assign, nonatomic) CGRect radarBound;


@property (nonatomic,strong)NSMutableArray *animaArray;

@property (nonatomic,assign)double animationtime;
@property (nonatomic,assign)double lastanimationtime;
@end
@implementation YJCRadarView

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (instancetype)initWithSuperViewBound:(CGSize)bound {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.valueRankNum = 4; //4个外圈
        self.lineColor = [UIColor colorWithRed:255.0/255.0 green:237.0/255.0 blue:243.0/255.0 alpha:1.0];
        self.sideNum = 6; //六边形
        if (!self.animationDuration) {
            self.animationDuration = 0.8;
        }
        _centerX = bound.width/2;
        _centerY = bound.height/2;
        self.radius = bound.width/2;
        
        [self drawSide]; //外圈
        [self drawLineFromCenter];//散线
        self.radarBound = CGRectMake(0, 0, bound.width, bound.height);
        self.animationtime = 0.0;
        self.lastanimationtime = 0.0;
    }
    return self;
}

#pragma mark - Overwrite
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

//中心线数据
- (void)makeCenterLinePoints {
    NSMutableArray *tempCornerPointArrs = [NSMutableArray new];
    
    // Side corners
    CGFloat rankValue = self.radius/self.valueRankNum;
    for (int j = 0; j < self.valueRankNum; j++) {
        NSMutableArray *tempCornerPoints = [NSMutableArray new];
        for (int i = 0; i < self.sideNum; i++) {
            NSInteger rank = j+1;
            CGPoint cornerPoint = CGPointMake(_centerX - ANGLE_COS(90.0 - 360.0 /self.sideNum * i) * rankValue * rank,
                                              _centerY - ANGLE_SIN(90.0 - 360.0 /self.sideNum * i) * rankValue * rank);
            [tempCornerPoints addObject:[NSValue valueWithCGPoint:cornerPoint]];
        }
        [tempCornerPointArrs addObject:[tempCornerPoints copy]];
    }
    
    self.cornerPointArrs = [tempCornerPointArrs copy];
    
}

- (void)setValues:(NSArray *)values {
    if ( values) {
        _values = values;
        //阴影点坐标数组
        self.valuePoints  = [self makeValuePointWith:values];
        // 使用KVC的方式获取数组中的最大值
        NSNumber *maxValue = [self.values valueForKeyPath:@"@max.intValue"];
        double time = [maxValue floatValue]  * 800 /1000/100;
        self.animationDuration = time;
    }
    
}
#pragma mark - draw
//画4个外层边界
- (void)drawSide {
    for (int i=1; i <=  self.valueRankNum; i++) {
        CGFloat radius = self.radius * (i/ (float)self.valueRankNum) ;
        CGPoint center = CGPointMake(_centerX, _centerY);
        // 使用这些信息来绘制圆
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        // 添加到视图上
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = circlePath.CGPath;
        shapeLayer.strokeColor = self.lineColor.CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        
        if (i== self.valueRankNum) {
            shapeLayer.lineWidth = 3.0;
        }else {
            shapeLayer.lineWidth = 2.0;
            shapeLayer.lineDashPattern = @[@(3), @(3)]; // 实线长度为 3，空白部分长度为 3
        }
        //为了将虚线圆圈都放置最下层
        [self.layer insertSublayer:shapeLayer atIndex:0];
    }
}

//画中心点线
- (void)drawLineFromCenter {
    //获取中心线点数组
    [self makeCenterLinePoints];
    
    
    CAShapeLayer *lineShapeLayer = [CAShapeLayer layer];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    NSArray *poins = [self.cornerPointArrs lastObject];
    for (int i = 0; i < poins.count; i++) {
        [linePath moveToPoint:CGPointMake(_centerX, _centerY)];
        CGPoint point = [poins[i] CGPointValue];
        [linePath addLineToPoint:point];
    }
    lineShapeLayer.strokeColor = self.lineColor.CGColor;
    lineShapeLayer.fillColor = UIColor.clearColor.CGColor;
    lineShapeLayer.path = linePath.CGPath;
    lineShapeLayer.lineWidth = 2.0;
    // 设置虚线样式
    lineShapeLayer.lineDashPattern = @[@(3), @(3)]; // 实线长度为 3，空白部分长度为 3
    [self.layer addSublayer:lineShapeLayer];
    //为了将虚线圆圈都放置最下层
    [self.layer insertSublayer:lineShapeLayer atIndex:1];
}

//阴影数据点坐标数组
- (NSArray<NSValue *>*)makeValuePointWith:(NSArray *)valueArray {
    NSMutableArray *tempValuePoints = [NSMutableArray new];//阴影点数组
    //Values  每个值的坐标
    for (int i = 0; i < self.sideNum; i++) {
        if (valueArray.count > i) {
            CGFloat valueRadius = ([valueArray[i] floatValue] / 100.0) * (self.radius * (self.valueRankNum-1)/self.valueRankNum) + self.radius/self.valueRankNum; // 数值长度 最小为小圆半径(实际长度为半径的3/4) (以num为4计算)
            CGPoint valuePoint =  CGPointMake(_centerX - ANGLE_COS(90.0 - 360.0 /self.sideNum * i) * valueRadius,
                                              _centerY - ANGLE_SIN(90.0 - 360.0 /self.sideNum * i) * valueRadius);
            [tempValuePoints addObject:[NSValue valueWithCGPoint:valuePoint]];
            
        }
    }
    
    
    return tempValuePoints;
}

//通过坐标数组 获取 UIBezierPath
-(UIBezierPath *)getPathWithValueArray:(NSArray *)pointsArray{
    
    UIBezierPath *bezi = [UIBezierPath bezierPath];
    
    if (pointsArray.count == 0) {
        return nil;
    }
    
    CGPoint first  = [[pointsArray firstObject] CGPointValue];
    [bezi moveToPoint:first];
    for (int i = 1; i < pointsArray.count; i++) {
        if (i==6) {
            [bezi closePath];
            break;
        }
        CGPoint point = [pointsArray[i] CGPointValue];
        
        [bezi addLineToPoint:point];
       
    }
    return bezi;
}

//画实际阴影部分
- (void)drawValueSideWithAnimation:(BOOL)isAnimation {
    
    if (self.valuePoints.count == 0) {
        return;
    }
    [self.layer addSublayer:self.valueLayer];


    self.valueLayer.strokeColor = UIColor.clearColor.CGColor;
    self.valueLayer.fillColor = [self.lineColor colorWithAlphaComponent:0.5].CGColor;
    self.valueLayer.path = self.valuePath.CGPath;
    
    // 创建渐变图层
    self.gradientLayer = [CAGradientLayer layer];
    self.valueLayer.frame = self.radarBound;
    self.gradientLayer.frame = self.radarBound;
    
    // 设置渐变色
    UIColor *topColor = [UIColor colorWithRed:255.0/255.0 green:148.0/255.0 blue:202.0/255.0 alpha:1.0]; // 顶部颜色为粉色
    UIColor *bottomColor = [UIColor colorWithRed:255.0/255.0 green:77.0/255.0 blue:136.0/255.0 alpha:1.0]; // 底部颜色为深粉色
    self.gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
    
    // 设置渐变的方向为从上到下
    self.gradientLayer.startPoint = CGPointMake(0.5, 0);
    self.gradientLayer.endPoint = CGPointMake(0.5, 1);
    
    //     将蒙版图层设置为渐变图层的蒙版
    self.gradientLayer.mask = self.valueLayer;
    [self.layer addSublayer:self.gradientLayer];
    if (isAnimation) {
        [self addColorStrokeEndAnimationToLayer:self.valueLayer];
    }
}
#pragma mark - Action
- (void)showWithAnimation:(BOOL)isAnimation {
    [self drawValueSideWithAnimation:isAnimation];//实际阴影部分
    [self setNeedsDisplay];
    
}
#pragma makr - Getter MEthod


- (CAShapeLayer *)valueLayer {
    if (!_valueLayer) {
        _valueLayer = [CAShapeLayer layer];
    }
    return _valueLayer;
}

- (UIBezierPath *)valuePath {
    if (!_valuePath) {
        _valuePath = [UIBezierPath bezierPath];
    }
    return _valuePath;
}

#pragma mark - Animation

- (void)addColorStrokeEndAnimationToLayer:(CAShapeLayer *)layer {
    self.animaArray = [NSMutableArray new];
    self.newanimationGroup = [CAAnimationGroup animation];
    
    // 创建颜色渐变动画
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    colorAnimation.fromValue = @(0.0); // 初始透明度0
    colorAnimation.toValue = @(1.0); // 初始透明度1
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; // 使用渐变函数使动画更平滑
        colorAnimation.duration = self.animationDuration;
    [self.animaArray addObject:colorAnimation];
    
    
    //圆心到最小菱形的动效
    self.valuePoints = [self makeValuePointWith:@[@(0),@(0),@(0),@(0),@(0),@(0)]];
    CGPoint first  = [[self.valuePoints firstObject] CGPointValue];
    [self.valuePath moveToPoint:first];
    for (int i = 1; i < self.valuePoints.count; i++) {
        CGPoint point = [self.valuePoints[i] CGPointValue];
        
        [self.valuePath addLineToPoint:point];
    }
    
    UIBezierPath * bezi = [self getPathWithValueArray:[self makeValuePointWith:@[@(0),@(0),@(0),@(0),@(0),@(0)]]];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];//path
    //最小动画占视图的1/4
    CGFloat minRadio = self.radius/self.valueRankNum;
    double firsttime = [@(minRadio) floatValue]  * 800 /1000/100;
    animation.beginTime = 0;
    animation.fromValue = (id)[UIBezierPath bezierPathWithRect:CGRectMake(_centerX, _centerY, 0, 0)].CGPath; // 目标路径为正方形 为0的点
    animation.duration = firsttime;
    self.lastanimationtime = firsttime;
    
    animation.toValue = (id)bezi.CGPath;
    self.oldvaluePath = bezi;
    self.valueLayer.path = bezi.CGPath;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]; // 使用渐变函数使动画更平滑
    animation.fillMode = kCAFillModeForwards; // 设置动画结束后保持最终状态
    animation.removedOnCompletion = NO; // 设置动画结束后不移除动画
    [self.animaArray addObject:animation];
    
    NSMutableArray *curArray = [@[@(0),@(0),@(0),@(0),@(0),@(0)] mutableCopy];
    NSMutableArray *keepArray = [NSMutableArray new];
    for (int j=0; j<self.values.count; j++) {
        if (j == 0){
            [keepArray addObjectsFromArray:self.values];
        
        }
        NSNumber *minValue = [keepArray valueForKeyPath:@"@min.intValue"];
        double time = [minValue floatValue]  * 800 /1000/100;
     
        for (int k=0; k<self.values.count; k++) {
            NSNumber *num = self.values[k];
            if ([num intValue] >= [minValue intValue]) {
                curArray[k] = minValue;
            }
        }
        [self changeFramewithNewDate:curArray withtime:time withNum:j];

        // 找到指定值的所有索引
        NSIndexSet *indexes = [keepArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqual:minValue];
        }];

        // 如果找到了指定值
        if ([indexes count] > 0) {
            // 删除第一个索引对应的元素
            [keepArray removeObjectAtIndex:[indexes firstIndex]];
        }
    }

    if (self.animaArray.count > 0) {
        self.newanimationGroup.animations = [self.animaArray copy];
        self.newanimationGroup.duration = self.lastanimationtime; // 动画持续时间为animationDuration秒
        [self.valueLayer addAnimation:self.newanimationGroup forKey:@"newanimationGroup"];
    }
}

-(void)changeFramewithNewDate:(NSArray *)newDate withtime :(double) time withNum :(int)num{
    if (num <6) {
        UIBezierPath * bezi = [self getPathWithValueArray:[self makeValuePointWith:newDate]];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];//path
        
        if (num == 0) {
            
            animation.beginTime = self.lastanimationtime;
            animation.fromValue = (id)self.oldvaluePath.CGPath; // 目标路径为正方形 为0的点
            animation.duration = time - self.lastanimationtime;
            self.lastanimationtime = time;
        } else {
            animation.beginTime = self.lastanimationtime ;
            animation.fromValue = (id)self.oldvaluePath.CGPath;
            animation.duration = time - self.lastanimationtime;
            self.lastanimationtime = time;
        }
        
        animation.toValue = (id)bezi.CGPath;
        self.oldvaluePath = bezi;
        self.valueLayer.path = bezi.CGPath;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]; // 使用渐变函数使动画更平滑
        animation.fillMode = kCAFillModeForwards; // 设置动画结束后保持最终状态
        animation.removedOnCompletion = NO; // 设置动画结束后不移除动画
        [self.animaArray addObject:animation];
    }
}

@end
