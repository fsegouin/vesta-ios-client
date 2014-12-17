//
//  SJMedalView.m
//  vesta
//
//  Created by Florent Segouin on 16/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "SJMedalView.h"
#import "UIColor+FlatUI.h"

@implementation SJMedalView

- (void)setModerator:(BOOL)moderator {
    _moderator = moderator;
    [self setNeedsDisplay];
}

- (void)setExpert:(BOOL)expert {
    _expert = expert;
    [self setNeedsDisplay];
}

- (void)setElder:(BOOL)elder {
    _elder = elder;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //// Color Declarations
    UIColor* color = [UIColor clearColor];
    
    if (self.expert)
        color = [UIColor colorFromHexCode:@"91b5e5"];
    else if (self.moderator)
        color = [UIColor colorFromHexCode:@"8dd7d6"];
    else if (self.elder)
        color = [UIColor colorFromHexCode:@"e0b57c"];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(9.66, 1)];
    [bezierPath addLineToPoint: CGPointMake(1, 5.26)];
    [bezierPath addLineToPoint: CGPointMake(1, 17.07)];
    [bezierPath addLineToPoint: CGPointMake(9.66, 21)];
    [bezierPath addLineToPoint: CGPointMake(18, 17.07)];
    [bezierPath addLineToPoint: CGPointMake(18, 5.26)];
    [bezierPath addLineToPoint: CGPointMake(9.66, 1)];
    [color setFill];
    [bezierPath fill];
}

@end
