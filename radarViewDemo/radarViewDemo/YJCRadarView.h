//
//  YJCRadarView.h
//  radarViewDemo
//
//  Created by MeetYou on 2024/5/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJCRadarView : UIView

@property (nonatomic, strong) NSArray               *values;
@property (nonatomic, strong) NSArray               *oldvalues;
@property (nonatomic, strong) UIColor               *lineColor;
@property (nonatomic, strong) UIColor               *valueLineColor;
@property (nonatomic, assign) CGFloat               radius;//半径
@property (nonatomic, assign) NSInteger             valueRankNum;
@property (nonatomic, assign) NSTimeInterval        animationDuration;

- (instancetype)initWithSuperViewBound:(CGSize)bound;

/// 显示数据得分图
- (void)showWithAnimation:(BOOL)isAnimation;
@end

NS_ASSUME_NONNULL_END
