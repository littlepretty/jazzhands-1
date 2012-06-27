//
//  DIYJazzHands.m
//  Field Recorder
//
//  Created by Jonathan Beilin on 5/15/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "DIYJazzHands.h"

@implementation DIYJazzHands

@synthesize target = _target;
@synthesize action = _action;

@synthesize bgColor = _bgColor;
@synthesize touchColor = _touchColor;
@synthesize mask = _mask;

@synthesize touchSize= _touchSize;



#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withTarget:(id)aTarget withAction:(SEL)anAction
{
    self = [super initWithFrame:frame];
    if (self) {
        _target = aTarget;
        _action = anAction;
        lineCount = 0;
        targetCount = 0;
    }
    return self;
}

- (BOOL)initContext
{
    int bytesPerPixel = 4;
    int bytesPerRow = self.frame.size.width * bytesPerPixel;
    int byteCount = bytesPerRow * self.frame.size.height;
    
    cacheBitmap = malloc(byteCount);
    if (cacheBitmap == NULL) {
        return NO;
    }
    
    cacheContext = CGBitmapContextCreate(cacheBitmap, self.frame.size.width, self.frame.size.height, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaLast);
    
    // check
    CGContextSetFillColorWithColor(cacheContext, [self.bgColor CGColor]);
    CGContextFillRect(cacheContext, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    // init UIImage
    //self.mask = [UIImage imageNamed:@"sample_mask.png"];
    
    return YES;
}

#pragma mark - Meat - interaction and drawing

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint lastPoint = [touch previousLocationInView:self];
    CGPoint newPoint = [touch locationInView:self];
    
    /*
    // check whether touch is on a target
    bool touchedTarget = false;
    
    for (int i = 0; i < lineCount; i++) {
        for (int j = 0; j < lines[i].touchCount; j++) {
            
        }
    }
    */
    // 

    [self drawToCacheFromPoint:lastPoint toPoint:newPoint];
    [self setNeedsDisplay];
}

#pragma mark - Fix dirtyrect stuff
- (void) drawToCacheFromPoint:(CGPoint)lastPoint toPoint:(CGPoint)newPoint {
    CGContextSetStrokeColorWithColor(cacheContext, [self.touchColor CGColor]);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, self.touchSize);
    
//    CGPoint lastPoint = [touch previousLocationInView:self];
//    CGPoint newPoint = [touch locationInView:self];
    
    CGContextMoveToPoint(cacheContext, lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(cacheContext, newPoint.x, newPoint.y);
    CGContextStrokePath(cacheContext);
    
    CGRect dirtyPoint1 = CGRectMake(lastPoint.x-10, lastPoint.y-10, 20, 20);
    CGRect dirtyPoint2 = CGRectMake(newPoint.x-10, newPoint.y-10, 20, 20);
    [self setNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
    
    // also draw overlay
    [self.mask drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

#pragma mark - Setup

- (void)addLineAtPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    if (lineCount < MAXLINES) {
        JiveLine newLine;
        newLine.p1 = startPoint;
        newLine.p2 = endPoint;
        lines[lineCount] = newLine;
        lineCount++;
        
        // make targets along line
    }
}

- (void)makeCheckWithFrame:(CGRect)frame
{
    [self addLineAtPoint:CGPointMake(108, 217) toPoint:CGPointMake(213, 319)];
    [self addLineAtPoint:CGPointMake(213, 319) toPoint:CGPointMake(402, 86)];
}

- (void)makeXWithFrame:(CGRect)frame
{
    
}

- (void)reset
{
    // clear context
    CGContextFlush(cacheContext);
    
    // reset targets
    targetCount = 0;
    
    // clear lines?
    lineCount = 0;
}

#pragma mark - Utility methods

- (BOOL)isComplete
{
    return NO;
}

- (BOOL)isTouchInTargets:(UITouch *)touch
{
    return YES;
}

#pragma mark - Dealloc

- (void)dealloc
{
    CGContextFlush(cacheContext);
    CGContextRelease(cacheContext);
    [super dealloc];
}

@end
