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
@synthesize targetSize = _targetSize;


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
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    self.opaque = NO;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    
    CFMutableDataRef pixels = CFDataCreateMutable( NULL , width * height );
    alphaPixels = CGBitmapContextCreate( CFDataGetMutableBytePtr( pixels ) , width , height , 8 , width , colorspace , kCGImageAlphaNone );
    provider = CGDataProviderCreateWithCFData(pixels);
    
    
    // Create scratchable CGImageRef
    scratchable = [UIImage imageNamed:@"gra_scratch_off_field@2x.png"].CGImage;
//    CGContextSetFillColorWithColor(alphaPixels, self.bgColor.CGColor);  
    
    // Set up CGContext for real
    CGContextSetFillColorWithColor(alphaPixels, [UIColor blackColor].CGColor);
    CGContextFillRect(alphaPixels, self.frame);
    
    CGContextSetStrokeColorWithColor(alphaPixels, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(alphaPixels, 5.0);
    CGContextSetLineCap(alphaPixels, kCGLineCapRound);
    
      
    CGImageRef mask = CGImageMaskCreate(width, height, 8, 8, width, provider, nil, NO);
    scratched = CGImageCreateWithMask(scratchable, mask);
    
    CGImageRelease(mask);
    CGColorSpaceRelease(colorspace);
    return YES;
}

#pragma mark - Meat - interaction and drawing
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint lastPoint = [touch previousLocationInView:self];
    CGPoint newPoint = [touch locationInView:self];
    
    // Check whether touch is on a target
    
    for (int i = 0; i < lineCount; i++) {
        for (int j = 0; j < lines[i].targetCount; j++) {
            
        }
    }

    // Draw new touches
    [self drawToCacheFromPoint:lastPoint toPoint:newPoint];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Fix dirtyrect stuff
- (void) drawToCacheFromPoint:(CGPoint)lastPoint toPoint:(CGPoint)newPoint {
	CGContextMoveToPoint(alphaPixels, lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(alphaPixels, newPoint.x, newPoint.y);
	CGContextStrokePath(alphaPixels);
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextDrawImage(UIGraphicsGetCurrentContext() , [self bounds] , scratched);
    
    // also draw overlay
//    [self.mask drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

#pragma mark - Setup

- (void)addLineAtPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    if (lineCount < MAXLINES) {
        JazzLine newLine;
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
    CGContextFlush(alphaPixels);
    
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
    CGContextFlush(alphaPixels);
    CGContextRelease(alphaPixels);
    [super dealloc];
}

@end
