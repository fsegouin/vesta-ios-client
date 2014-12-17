//
//  SJCheckButton.m
//  vesta
//
//  Created by Florent Segouin on 15/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "SJCheckButton.h"
#import "HexColor.h"

@implementation SJCheckButton

- (void)setSelected:(BOOL)selected
{
    self.emphasized = selected;
    [super setSelected:selected];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    //// Oval Drawing - Background
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1, 1, 30, 30)];
    UIColor *ovalFillColor = [UIColor whiteColor];
    
    if (self.emphasized)
        ovalFillColor = [UIColor colorWithHexString:@"#2ecc71"];
    
    [ovalFillColor setFill];
    [ovalPath fill];
    [ovalFillColor setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    
    
    //// Bezier Drawing - Check sign
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(9, 17)];
    [bezier2Path addLineToPoint: CGPointMake(14, 22)];
    [bezier2Path addLineToPoint: CGPointMake(23, 10)];
    bezier2Path.lineCapStyle = kCGLineCapRound;
    
    UIColor *bezierStrokeColor = [UIColor colorWithHexString:@"#2ecc71"];
    
    if (self.emphasized)
        bezierStrokeColor = [UIColor whiteColor];
    
    [bezierStrokeColor setStroke];
    bezier2Path.lineWidth = 2;
    [bezier2Path stroke];

}

@end
