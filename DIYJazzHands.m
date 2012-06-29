//
//  DIYJazzHands.m
//  Field Recorder
//
//  Created by Jonathan Beilin on 5/15/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "DIYJazzHands.h"

#pragma mark - JazzTarget
@implementation JazzTarget

@synthesize targetRect = _targetRect;
@synthesize triggered = _triggered;

@end

#pragma mark - JazzLine
@implementation JazzLine

@synthesize p1 = _p1;
@synthesize p2 = _p2;
@synthesize targets = _targets;

- (id)init
{
    if (self = [super init]) {
        _targets = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withTargetSize:(int)targetSize
{
    self.p1 = startPoint;
    self.p2 = endPoint;
    
    //
    // Make targets along line
    //
    
    // Precalculate distances
    int xDist = endPoint.x - startPoint.x;
    int yDist = endPoint.y - startPoint.y;
    float distance = sqrtf(pow(xDist, 2) + pow(yDist, 2));
    
    // Precalculate # targets and deltas
    int numTargets = distance / (float) targetSize;
    int dX = xDist / (float)numTargets;
    int dY = yDist / (float)numTargets;
    
    for (int i = 0; i < numTargets; i++) {
        JazzTarget *newTarget = [[[JazzTarget alloc] init] autorelease];
        newTarget.targetRect = CGRectMake(startPoint.x + i*dX, startPoint.y + i*dY, targetSize, targetSize);
        newTarget.triggered = NO;
        [self.targets addObject:newTarget];
    }
}

- (void)dealloc
{
    [_targets release]; self.targets = nil;
    [super dealloc];
}

@end

#pragma mark - DIYJazzHands

@implementation DIYJazzHands

@synthesize target = _target;
@synthesize action = _action;

@synthesize bgColor = _bgColor;
@synthesize touchColor = _touchColor;
@synthesize mask = _mask;

@synthesize touchSize = _touchSize;
@synthesize targetSize = _targetSize;

@synthesize lines = _lines;

@synthesize checkTimer = _checkTimer;


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
        targetCount = 0;
        targetsTouched = 0;
        isTriggered = NO;
        _targetSize = TARGETRADIUS;
        _lines = [[NSMutableArray alloc] init];
        
       _checkTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkFinished) userInfo:nil repeats:YES];
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
    NSString *bundlePath    = [[NSBundle mainBundle] bundlePath];
    scratchable = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/gra_scratch_off_field_flip@2x.png", bundlePath]].CGImage;
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
    [self isTouchInTargets:touch];
    
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
    
    [self checkFinished];
}

#pragma mark - Drawing
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
    JazzLine *newLine = [[[JazzLine alloc] init] autorelease];
    [newLine addLineFromPoint:startPoint toPoint:endPoint withTargetSize:self.targetSize];
    [self.lines addObject:newLine];
    
    targetCount += [newLine.targets count];
}

- (void)makeCheckWithFrame:(CGRect)frame
{
//    [self addLineAtPoint:CGPointMake(108, 217) toPoint:CGPointMake(213, 319)];
//    [self addLineAtPoint:CGPointMake(213, 319) toPoint:CGPointMake(402, 86)];
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
}

#pragma mark - Utility methods

- (BOOL)isTouchInTargets:(UITouch *)touch
{
    for (JazzLine *line in self.lines) {
        for (JazzTarget *target in line.targets) {
            if (!target.triggered && CGRectContainsPoint(target.targetRect, [touch locationInView:self])) {
                target.triggered = YES;
                targetsTouched++;
            }
        }
    }
    
    return YES;
}

- (void)checkFinished
{    
//    NSLog(@"targetCount: %d", targetCount);
//    NSLog(@"targetsTouched: %d", targetsTouched);
    
    if (targetsTouched > 0.8 * targetCount && !isTriggered) {
        isTriggered = YES;
        [self.target performSelector:self.action];
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    // CG stuff
    CGContextFlush(alphaPixels);
    CGContextRelease(alphaPixels);
    
    // Other
    
    [_lines release]; self.lines = nil;
    [_bgColor release]; self.bgColor = nil;
    [_touchColor release]; self.touchColor = nil;
    [_mask release]; self.mask = nil;
    
    [_checkTimer invalidate]; [_checkTimer release]; self.checkTimer = nil;
    
    [super dealloc];
}

@end
