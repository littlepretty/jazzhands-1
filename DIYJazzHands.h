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

//

#define MAXLINES 5
#define MAXTARGETS 10
#define TARGETRADIUS 30

//

typedef struct {
    CGPoint center;
    int radius;
    BOOL triggered;
} FingerTarget;

typedef struct {
    CGPoint p1;
    CGPoint p2;
    FingerTarget targets[MAXTARGETS];
    int targetCount;
} JazzLine;

//

@interface DIYJazzHands : UIView
{
	CGImageRef scratchable;
	CGImageRef scratched;
	CGContextRef alphaPixels;
	CGDataProviderRef provider;
    
    CGPoint	location;
	CGPoint	previousLocation;
    
    JazzLine lines[MAXLINES];
    int lineCount;
    int targetCount;
    
//    CGPoint lastPoint;
}

//
// Public Properties
//

// Visual
@property (nonatomic, retain) UIColor *bgColor;
@property (nonatomic, retain) UIColor *touchColor;
@property (nonatomic, retain) UIImage *mask;

// Interactive
@property (nonatomic, assign) int touchSize;
@property (nonatomic, assign) int targetSize;

//
// Private Properties
//

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;

//
// Init
//
- (id)initWithFrame:(CGRect)frame withTarget:(id)aTarget withAction:(SEL)anAction;

//
// Gesture definitions
//

// Custom shapes
- (void)addLineAtPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;

// Shortcut shapes
- (void)makeCheckWithFrame:(CGRect)frame;
- (void)makeXWithFrame:(CGRect)frame;

//
// Private
//
- (BOOL)isTouchInTargets:(UITouch *)touch;
- (BOOL)initContext;
- (void)reset;

@end