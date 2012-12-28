//
//  RingFillShapeLayer.m
//  Start
//
//  Created by Nick Place on 12/26/12.
//
//

#import "RingFillShapeLayer.h"

@implementation RingFillShapeLayer

@dynamic innerRadius, outerRadius, startAngle, endAngle;
@synthesize ringFillColor, ringStrokeColor, handleColor;
@synthesize ringLayer, fillLayer;


+ (BOOL)needsDisplayForKey:(NSString*)key {
    NSArray *keysThatNeedDisplay = [NSArray arrayWithObjects:@"innerRadius", @"outerRadius",
                                    @"startAngle", @"endAngle", nil];
    
    if ([keysThatNeedDisplay containsObject:key]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

-(id<CAAction>)actionForKey:(NSString *)event {
	if ([RingFillShapeLayer needsDisplayForKey:event]) {
		return [self makeAnimationForKey:event];
	}
	
	return [super actionForKey:event];
}

-(CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = 2;
    
	return anim;
}

- (id)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[RingFillShapeLayer class]]) {
            RingFillShapeLayer *other = (RingFillShapeLayer *)layer;
            self.startAngle = other.startAngle;
            self.endAngle = other.endAngle;
            self.outerRadius = other.outerRadius;
            self.innerRadius = other.innerRadius;
            self.ringFillColor = other.ringFillColor;
            self.handleColor = other.handleColor;
            self.ringStrokeColor = other.ringStrokeColor;
        }
    }
    
    return self;
}

+ (NSSet *)keyPathsForValuesAffectingContent {
    
    static NSSet *keys = nil;
    
    if (!keys)
        
        keys = [[NSSet alloc] initWithObjects:@"innerRadius", @"outerRadius",
                @"startAngle", @"endAngle", nil];
    
    return keys;
    
}



- (id) init {
    if (self = [super init]) {
        fillLayer = [[CAShapeLayer alloc] init];
        _handleLayer = [[CAShapeLayer alloc] init];
        ringLayer = [[CAShapeLayer alloc] init];
        
        ringLayer.lineWidth = 1;
        ringLayer.fillColor = [[UIColor clearColor] CGColor];
        
        [self addSublayer:fillLayer];
        [self addSublayer:_handleLayer];
        [self addSublayer:ringLayer];
        
        self.drawsAsynchronously = YES;
    }
    return  self;
}


- (void) display {
    float beginAngle = DEGREES_TO_RADIANS(-90);
    
    // MAKE THE PATHS
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter:CGPointZero radius:self.innerRadius startAngle:self.startAngle+beginAngle endAngle:self.endAngle+beginAngle clockwise:YES];
    [circlePath addArcWithCenter:CGPointZero radius:self.outerRadius startAngle:self.endAngle+beginAngle endAngle:self.startAngle+beginAngle clockwise:NO];
    
    UIBezierPath *handlePath = [UIBezierPath bezierPath];
    [handlePath moveToPoint:[self vectorFromAngle:self.endAngle distance:self.innerRadius origin:CGPointZero]];
    [handlePath addLineToPoint:[self vectorFromAngle:self.endAngle distance:self.outerRadius origin:CGPointZero]];
    
    UIBezierPath *ringPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:self.outerRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];

    
    // DRAW THE LAYERS
    fillLayer.path = circlePath.CGPath;
    fillLayer.fillColor = [ringFillColor CGColor];
    
    _handleLayer.path = handlePath.CGPath;
    _handleLayer.lineWidth = 2.0;
    _handleLayer.strokeColor = [handleColor CGColor];
    
    ringLayer.path = ringPath.CGPath;
    ringLayer.strokeColor = [ringStrokeColor CGColor];
}


- (void) drawInContext:(CGContextRef)ctx {
    [self display];
}

#pragma mark - utilities

- (CGPoint) vectorFromAngle:(float)angle distance:(float)distance origin:(CGPoint)origin {
    CGPoint vector;
    angle = angle + DEGREES_TO_RADIANS(-90);
    vector.y = roundf( distance * sinf( angle ) );
    vector.x = roundf( distance * cosf( angle ) );
    return CGPointAddPoint(vector, origin);
}

CGPoint CGPointAddPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x+p2.x, p1.y+p2.y);
}



@end
