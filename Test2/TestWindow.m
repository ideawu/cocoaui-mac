//
//  TestWindow.m
//  Test
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "TestWindow.h"
#import "IView.h"
#import "ILabel.h"
#import <QuartzCore/QuartzCore.h>

@interface TestWindow ()<NSWindowDelegate>
@property NSView *controlBar;

@end

@implementation TestWindow

- (id)init{
	self = [super initWithWindowNibName:@"TestWindow"];
	self.window.delegate = self;
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];

	IView *view = [IView namedView:@"Test"];
	[self.window.contentView addSubview:view];
	
	_controlBar = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	_controlBar.wantsLayer = YES;
	_controlBar.layer = [[CALayer alloc] init];
	_controlBar.layer.backgroundColor = [NSColor redColor].CGColor;
}

- (void)keyDown:(NSEvent *)event{
	if(_controlBar.superview){
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:1.0];
		[_controlBar.animator removeFromSuperview];
		[NSAnimationContext endGrouping];
	}else{
		[self.window.contentView addSubview:_controlBar];
		[_controlBar setAlphaValue:0];
		
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:1.0];
		[_controlBar.animator setAlphaValue:1];
		[NSAnimationContext endGrouping];
		log_debug(@"%@", _controlBar.layer.animationKeys);

		CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
		flash.fromValue = [NSNumber numberWithFloat:0.0];
		flash.toValue = [NSNumber numberWithFloat:1.0];
		flash.duration = 1.0;
		
		[_controlBar.layer addAnimation:flash forKey:@"flashAnimation"];
		
		log_debug(@"%@", _controlBar.layer.animationKeys);
	}
}

@end