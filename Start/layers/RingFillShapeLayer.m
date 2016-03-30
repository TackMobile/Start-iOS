//
//  RingFillShapeLayer.m
//  Start
//
//  Created by Nick Place on 12/26/12.
//
//

#import "RingFillShapeLayer.h"

@interface RingFillShapeLayer()

@property (atomic, strong) CAShapeLayer *ringLayer;
@property (atomic, strong) CAShapeLayer *handleLayer;
@property (atomic, strong) CAShapeLayer *fillLayer;

@end

@implementation RingFillShapeLayer

- (id) init {
    if (self = [super init]) {
        _fillLayer = [[CAShapeLayer alloc] init];
        _handleLayer = [[CAShapeLayer alloc] init];
        _ringLayer = [[CAShapeLayer alloc] init];
        
        _ringLayer.lineWidth = 1;
        _ringLayer.fillColor = [[UIColor clearColor] CGColor];
        
        _ringFillColor = _ringStrokeColor = _handleColor = [UIColor clearColor];
        
        _shouldAnimate = NO;
        
        self.drawsAsynchronously = YES;
    }
    return  self;
}

- (id)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[RingFillShapeLayer class]]) {
            RingFillShapeLayer *other = (RingFillShapeLayer *)layer;
            _startAngle = other.startAngle;
            _endAngle = other.endAngle;
            _outerRadius = other.outerRadius;
            _innerRadius = other.innerRadius;
            _ringFillColor = other.ringFillColor;
            _handleColor = other.handleColor;
            _ringStrokeColor = other.ringStrokeColor;
        }
    }
    return self;
}

#pragma mark - properties

- (void) setValue:(id)value forKey:(NSString *)key animated:(bool)animated {
    self.shouldAnimate = animated;
    
    [self setValue:value forKey:key];
}



+ (NSSet *)keyPathsForValuesAffectingContent {
    static NSSet *keys = nil;
    
    if (!keys)
        keys = [[NSSet alloc] initWithObjects:@"innerRadius", @"outerRadius",
                @"startAngle", @"endAngle", nil];
    
    return keys;
}

#pragma  mark - display

+ (BOOL)needsDisplayForKey:(NSString*)key {
    NSArray *keysThatNeedDisplay = @[@"innerRadius", @"outerRadius", @"startAngle", @"endAngle"];
    
    if ([keysThatNeedDisplay containsObject:key]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

-(id<CAAction>)actionForKey:(NSString *)event {
	if ([RingFillShapeLayer needsDisplayForKey:event] && self.shouldAnimate) {
		return [self makeAnimationForKey:event];
	}
	
	return [super actionForKey:event];
}

-(CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = .5;
    
    anim.delegate = self.animDelegate;
    
	return anim;
}

- (void) drawInContext:(CGContextRef)ctx {
    UIGraphicsPushContext(ctx);
    
    float beginAngle = DEGREES_TO_RADIANS(-90);
    CGPoint center = (CGPoint){self.frame.size.width/2, self.frame.size.height/2};
    
    // MAKE THE PATHS
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter:center radius:self.innerRadius startAngle:self.startAngle+beginAngle endAngle:self.endAngle+beginAngle clockwise:YES];
    [circlePath addArcWithCenter:center radius:self.outerRadius startAngle:self.endAngle+beginAngle endAngle:self.startAngle+beginAngle clockwise:NO];
    
    UIBezierPath *handlePath = [UIBezierPath bezierPath];
    [handlePath moveToPoint:[self vectorFromAngle:self.endAngle distance:self.innerRadius origin:center]];
    [handlePath addLineToPoint:[self vectorFromAngle:self.endAngle distance:self.outerRadius origin:center]];
    
    UIBezierPath *ringPath = [UIBezierPath bezierPathWithArcCenter:center radius:self.outerRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    // DRAW THE LAYERS
    [self.ringFillColor setFill];
    if (self.startAngle != self.endAngle && fabs(self.startAngle-self.endAngle) < 6.261)
        [circlePath fill];
    
    [self.handleColor setStroke];
    handlePath.lineWidth = 2.0;
    [handlePath stroke];
    
    [self.ringStrokeColor setStroke];
    [ringPath stroke];
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
