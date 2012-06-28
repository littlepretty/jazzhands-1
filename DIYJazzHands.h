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

#define TARGETRADIUS 20

//

/*
typedef struct {
    CGRect targetRect;
    BOOL triggered;
} FingerTarget;
*/

/*
typedef struct {
    CGPoint p1;
    CGPoint p2;
    FingerTarget targets[MAXTARGETS];
    int targetCount;
} JazzLine;
*/

@interface JazzTarget : NSObject

@property (nonatomic, assign) CGRect targetRect;
@property (nonatomic, assign) BOOL triggered;

@end

@interface JazzLine : NSObject

@property (nonatomic, assign) CGPoint p1;
@property (nonatomic, assign) CGPoint p2;
@property (nonatomic, retain) NSMutableArray *targets;

@end


//

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
@property (nonatomic, retain) NSMutableArray *lines;

@property (nonatomic, retain) NSTimer *checkTimer;

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