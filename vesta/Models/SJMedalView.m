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

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //// Color Declarations
    
    //// If no mode is set, the whole badge will be blank (not visible)
    UIColor* color = [UIColor clearColor];
    
    if (self.expert)
        color = [UIColor colorFromHexCode:@"dc322f"];
    else if (self.moderator)
        color = [UIColor colorFromHexCode:@"268bd2"];
    else if (self.elder)
        color = [UIColor colorFromHexCode:@"b58900"];
    else
        color = [UIColor colorFromHexCode:@"859900"];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    
    [bezierPath moveToPoint:CGPointMake(self.bounds.size.width/2, 0)];
    [bezierPath addLineToPoint: CGPointMake(self.bounds.size.width, self.bounds.size.height/4)];
    [bezierPath addLineToPoint: CGPointMake(self.bounds.size.width, self.bounds.size.height-self.bounds.size.height/4)];
    [bezierPath addLineToPoint: CGPointMake(self.bounds.size.width/2, self.bounds.size.height)];
    [bezierPath addLineToPoint: CGPointMake(0, self.bounds.size.height-self.bounds.size.height/4)];
    [bezierPath addLineToPoint: CGPointMake(0, self.bounds.size.height/4)];
    [bezierPath addLineToPoint: CGPointMake(self.bounds.size.width/2, 0)];
    
    [color setFill];
    [bezierPath fill];
}

@end
