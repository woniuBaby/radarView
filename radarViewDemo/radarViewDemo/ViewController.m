//
//  ViewController.m
//  radarViewDemo
//
//  Created by MeetYou on 2024/5/8.
//

#import "ViewController.h"
#import "YJCRadarView.h"
@interface ViewController ()
@property (nonatomic, strong) YJCRadarView *polygonView;
@property (nonatomic,strong)UIView *bgView;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.bgView.center = self.view.center;
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bgView];
    
    //    PulseRipple *v = [[PulseRipple alloc] initWithFrame:CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height)];
    //    [self.bgView addSubview:v];
    //    [self testview];
    [self curView];
    
//    NSMutableArray *array = [@[@1, @1, @2, @2, @3, @3] mutableCopy];
//    NSNumber *valueToRemove = @2;
//
//    // 找到指定值的所有索引
//    NSIndexSet *indexes = [array indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        return [obj isEqual:valueToRemove];
//    }];
//
//    // 如果找到了指定值
//    if ([indexes count] > 0) {
//        // 删除第一个索引对应的元素
//        [array removeObjectAtIndex:[indexes firstIndex]];
//    }
//
//    NSLog(@"%@", array);
    
}

-(void)testview{
    // 中心点
       CGPoint center = self.view.center;
       CGFloat sideLength = 100.0; // 六边形边长
       
       // 创建六个顶点
       NSMutableArray *vertices = [NSMutableArray array];
       for (NSInteger i = 0; i < 6; i++) {
           CGFloat angle = (M_PI * 2 / 6) * i;
           CGFloat x = center.x + sideLength * cos(angle);
           CGFloat y = center.y + sideLength * sin(angle);
           [vertices addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
       }
       
       // 创建六边形路径
       UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
       [hexagonPath moveToPoint:[[vertices firstObject] CGPointValue]];
       for (NSInteger i = 1; i < vertices.count; i++) {
           [hexagonPath addLineToPoint:[[vertices objectAtIndex:i] CGPointValue]];
       }
       [hexagonPath closePath];
       
       // 创建六边形图层
       CAShapeLayer *hexagonLayer = [CAShapeLayer layer];
       hexagonLayer.strokeColor = [UIColor blackColor].CGColor;
       hexagonLayer.fillColor = [UIColor clearColor].CGColor;
       hexagonLayer.lineWidth = 2.0;
       hexagonLayer.path = hexagonPath.CGPath;
       
       // 添加六边形图层到视图层次结构中
       [self.view.layer addSublayer:hexagonLayer];
       
       // 设置初始状态
       hexagonLayer.transform = CATransform3DMakeScale(0.01, 0.01, 1.0);
       
       // 创建动画
       CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
       animation.fromValue = @(0.01); // 初始值为0.01
       animation.toValue = @(1.0); // 最终值为1.0
       animation.duration = 1.0; // 动画时间1秒
       animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
       
       // 应用动画
       [hexagonLayer addAnimation:animation forKey:nil];
}


- (void)curView {
//    [super viewDidLoad];
    
    UIButton *a =[UIButton new];
    a.frame = CGRectMake(self.view.center.x - 25, self.view.center.y+300, 50, 30);
    [a setTitle:@"重置" forState:UIControlStateNormal];
    a.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:a];
    
    
    [a addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    
  

    _polygonView = [[YJCRadarView alloc] initWithSuperViewBound:self.bgView.frame.size];
    [self.bgView addSubview:_polygonView];
    
    _polygonView.values = @[@(75),@(90),@(50),@(50),@(50),@(75)];
//    _polygonView.values = @[@(10),@(10),@(10),@(10),@(10),@(10)];
    [_polygonView showWithAnimation:YES];
}
static int a = 0;
static int b = 0;
static int c = 0;
-(void)click:(UIButton *)btn{
    
    
    if (_polygonView) {
        [_polygonView removeFromSuperview];
        
        _polygonView = [[YJCRadarView alloc] initWithSuperViewBound:self.bgView.frame.size];
        [self.bgView addSubview:_polygonView];
        //        _polygonView.values = @[@(100),@(100),@(100),@(100),@(100),@(100)];
                
        //        _polygonView.values = @[@(0),@(0),@(0),@(0),@(0),@(0)];
//                _polygonView.values = @[@(0),@(0),@(0),@(0),@(0),@(0)];
        //        _polygonView.values = @[@(75),@(75),@(75),@(75),@(75),@(75)];
        _polygonView.values = @[@(1),@(20),@(50),@(50),@(90),@(100)];
        [_polygonView showWithAnimation:YES];
        

        
    }
    
    a++;
   
    b++;
    
    c++;
    
//  NSArray *new =  @[@(a),@(20),@(b),@(15),@(c),@(75)];
//    [_polygonView changeFramewithNewDate:new];
}

@end
