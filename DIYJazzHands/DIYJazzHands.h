//
//  DIYJazzHands.h
//  Field Recorder
//
//  Created by Jonathan Beilin on 5/15/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

// Thanks to Sean Christmann for his painting app example at
// http://blog.effectiveui.com/?p=8105

#import <UIKit/UIKit.h>

@interface JazzTarget : NSObject
@property CGRect targetRect;
@property BOOL triggered;
@end

@interface JazzLine : NSObject
@property CGPoint p1;
@property CGPoint p2;
@property (strong) NSMutableArray *targets;
@end

@interface DIYJazzHands : UIView
{
	CGImageRef scratchable;
	CGImageRef scratched;
	CGContextRef alphaPixels;
	CGDataProviderRef provider;
    
    CGPoint	location;
	CGPoint	previousLocation;
    
    int targetCount;
    int targetsTouched;
    
    BOOL isTriggered;
}

@property int targetSize;

- (id)initWithFrame:(CGRect)frame withTarget:(id)aTarget withAction:(SEL)anAction;
- (void)addLineAtPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
- (void)initContextWithImage:(UIImage *)image;

- (void)addPromptView:(UIView *)promptView;

@end