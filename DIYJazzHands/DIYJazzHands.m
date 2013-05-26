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
        _p1         = CGPointMake(0, 0);
        _p2         = CGPointMake(0, 0);
        _targets    = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withTargetSize:(int)targetSize
{
    self.p1 = startPoint;
    self.p2 = endPoint;
        
    // Precalculate distances
    int xDist = endPoint.x - startPoint.x;
    int yDist = endPoint.y - startPoint.y;
    float distance = sqrtf(pow(xDist, 2) + pow(yDist, 2));
    
    // Precalculate # targets and deltas
    int numTargets = distance / (float) targetSize;
    int dX = xDist / (float)numTargets;
    int dY = yDist / (float)numTargets;
    
    for (int i = 0; i < numTargets; i++) {
        JazzTarget *newTarget = [[JazzTarget alloc] init];
        newTarget.targetRect = CGRectMake(startPoint.x + i*dX, startPoint.y + i*dY, targetSize, targetSize);
        newTarget.triggered = NO;
        [self.targets addObject:newTarget];
    }
}

- (void)dealloc
{
    _targets = nil;
}

@end

#pragma mark - DIYJazzHands

@interface DIYJazzHands ()
@property SEL action;
@property (strong) id target;
@property (strong) NSMutableArray *lines;
@property (strong) NSTimer *checkTimer;
@end

static CGFloat const targetRadius = 20.0f;
static CGFloat const interval = 0.1f;
static CGFloat const lineWidth = 5.0f;

@implementation DIYJazzHands

@synthesize targetSize = _targetSize;
@synthesize action = _action;
@synthesize target = _target;
@synthesize lines = _lines;
@synthesize checkTimer = _checkTimer;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame withTarget:(id)aTarget withAction:(SEL)anAction
{
    self = [super initWithFrame:frame];
    if (self) {
        _targetSize     = targetRadius;
        _action         = anAction;
        _target         = aTarget;
        _lines          = [[NSMutableArray alloc] init];
        _checkTimer     = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(checkFinished) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)initContextWithImage:(UIImage *)image
{
    int width       = self.frame.size.width;
    int height      = self.frame.size.height;
    self.opaque     = NO;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    
    CFMutableDataRef pixels = CFDataCreateMutable( NULL , width * height );
    alphaPixels = CGBitmapContextCreate( CFDataGetMutableBytePtr( pixels ) , width , height , 8 , width , colorspace , kCGImageAlphaNone );
    provider = CGDataProviderCreateWithCFData(pixels);
    CFRelease(pixels);
    
    // Create scratchable CGImageRef
    scratchable = [image CGImage];
    
    // Set up CGContext for real
    CGContextSetFillColorWithColor(alphaPixels, [UIColor blackColor].CGColor);
    CGContextFillRect(alphaPixels, self.frame);
    
    CGContextSetStrokeColorWithColor(alphaPixels, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(alphaPixels, lineWidth);
    CGContextSetLineCap(alphaPixels, kCGLineCapRound);
      
    CGImageRef mask = CGImageMaskCreate(width, height, 8, 8, width, provider, nil, NO);
    scratched = CGImageCreateWithMask(scratchable, mask);
    
    CGImageRelease(mask);
    CGColorSpaceRelease(colorspace);
}

#pragma mark - Interaction and drawing

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

- (void)drawToCacheFromPoint:(CGPoint)lastPoint toPoint:(CGPoint)newPoint {
	CGContextMoveToPoint(alphaPixels, lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(alphaPixels, newPoint.x, newPoint.y);
	CGContextStrokePath(alphaPixels);
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextDrawImage(UIGraphicsGetCurrentContext() , [self bounds] , scratched);
}

#pragma mark - Setup

- (void)addLineAtPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    JazzLine *newLine = [[JazzLine alloc] init];
    [newLine addLineFromPoint:startPoint toPoint:endPoint withTargetSize:self.targetSize];
    [self.lines addObject:newLine];
    
    targetCount += [newLine.targets count];
}

- (void)reset
{
    CGContextFlush(alphaPixels);
    targetCount = 0;
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
    if (targetsTouched > 0.8 * targetCount && !isTriggered) {
        isTriggered = YES;
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action];
        #pragma clang diagnostic pop
    }
}

#pragma mark - Memory

- (void)dealloc
{
    // CG stuff
    CGContextFlush(alphaPixels);
    CGContextRelease(alphaPixels);
    
    // Nil
    _lines = nil;
    [_checkTimer invalidate];
    _checkTimer = nil;
}

@end
