//
//  ControlBar.m
//  Tovi
//
//  Created by ideawu on 01/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "ControlBar.h"
#import "File.h"
#import <QuartzCore/QuartzCore.h>

@interface ControlBar(){
	void (^_handler)(ControlBarEvent event, IView *view);
}
@property float animateDuration;
@property float autoHideDelay;
@property NSTimer *autoHideTimer;
@property IImage *playIcon;
@end


@implementation ControlBar

- (id)init{
	self = [super init];
	self.frame = CGRectMake(0, 0, 1, 30);
	
	_animateDuration = 0.4;
	_autoHideDelay = 2.5;
	
	_contentView = [IView namedView:@"ControlBar"];
	_textLabel = (ILabel *)[_contentView getViewById:@"current_index"];
	_playIcon = (IImage *)[_contentView getViewById:@"play"];
	[self addSubview:_contentView];
	
	IView *icons = [_contentView getViewById:@"icons"];
	for(NSView *view in icons.subviews){
		if(view.class == [IImage class]){
			IImage *img = (IImage *)view;
			[img bindEvent:IEventClick handler:^(IEventType event, IView *view) {
				[self onClick:(IImage *)view];
			}];
		}
	}

	self.wantsLayer = YES;
	_autoHideTimer = [NSTimer scheduledTimerWithTimeInterval:_autoHideDelay
													  target:self
													selector:@selector(autoHideCallback)
													userInfo:nil
													 repeats:YES];

	return self;
}

- (void)autoHideCallback{
	if(_contentView.state == IViewStateNone){
		[self hide];
	}
}

- (void)show{
	if(_autoHideTimer){
		[_autoHideTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_autoHideTimer.timeInterval]];
	}
	if(self.layer.opacity == 0){
		// NSAnimationContext 有 bug
		self.layer.opacity = 1;
		CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
		flash.fromValue = [NSNumber numberWithFloat:0];
		flash.toValue = [NSNumber numberWithFloat:1];
		flash.duration = _animateDuration;
		[self.layer addAnimation:flash forKey:@""];
		
		{
			NSPoint startOrigin = NSMakePoint(0, -self.frame.size.height);
			NSPoint endOrigin = NSMakePoint(0, 0);
			CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"position"];
			flash.fromValue = [NSValue valueWithPoint:startOrigin];
			flash.toValue = [NSValue valueWithPoint:endOrigin];
			flash.duration = _animateDuration;
			[self.layer addAnimation:flash forKey:@""];
		}
	}
}

- (void)hide{
	if(self.layer.opacity != 0){
		self.layer.opacity = 0;
		CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
		flash.fromValue = [NSNumber numberWithFloat:1];
		flash.toValue = [NSNumber numberWithFloat:0];
		flash.duration = _animateDuration;
		[self.layer addAnimation:flash forKey:@""];
		
		{
			NSPoint startOrigin = NSMakePoint(0, 0);
			NSPoint endOrigin = NSMakePoint(0, -self.frame.size.height);
			CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"position"];
			flash.fromValue = [NSValue valueWithPoint:startOrigin];
			flash.toValue = [NSValue valueWithPoint:endOrigin];
			flash.duration = _animateDuration;
			[self.layer addAnimation:flash forKey:@""];
		}
	}
}

- (void)onClick:(IImage *)img{
	NSString *file = [[File basename:img.src] stringByDeletingPathExtension];
	NSDictionary *events = @{
							 @"flip_h": @(ControlBarEventFlipH),
							 @"flip_v": @(ControlBarEventFlipV),
							 @"rotate_left": @(ControlBarEventRotateLeft),
							 @"rotate_right": @(ControlBarEventRotateRight),
							 @"play": @(ControlBarEventPlay),
							 @"pause": @(ControlBarEventPause),
							 @"prev": @(ControlBarEventPrev),
							 @"next": @(ControlBarEventNext),
							 @"minus": @(ControlBarEventZoomOut),
							 @"plus": @(ControlBarEventZoomIn),
							 @"bestsize": @(ControlBarEventBestSize),
							 @"actualsize": @(ControlBarEventActualSize),
							 @"fillsize": @(ControlBarEventFillSize),
							 };
	NSNumber *num = [events objectForKey:file];
	if(num && _handler){
		ControlBarEvent event = (ControlBarEvent)num.intValue;
		if(event == ControlBarEventPlay){
			[self setPlaying:YES];
		}else if(event == ControlBarEventPause){
			[self setPlaying:NO];
		}
		_handler(event, img);
	}
}

- (void)setPlaying:(BOOL)isPlaying{
	if(isPlaying){
		_playIcon.src = @"images/toolbar-18/play.png";
	}else{
		_playIcon.src = @"images/toolbar-18/pause.png";
	}
}

- (void)bindHandler:(void (^)(ControlBarEvent event, IView *view))handler{
	_handler = handler;
}

@end
