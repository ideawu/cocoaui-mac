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
#import "ControlBar.h"

@interface TestWindow ()<NSWindowDelegate>
@property ControlBar *controlBar;

@end

@implementation TestWindow

- (id)init{
	self = [super initWithWindowNibName:@"TestWindow"];
	self.window.delegate = self;
	return self;
}

- (void)windowDidResize:(NSNotification *)notification{
	log_debug(@"");
	{
		CGRect frame = _controlBar.frame;
		frame.size.width = ((NSView *)self.window.contentView).bounds.size.width;
//		frame = ((NSView *)self.window.contentView).bounds;
		_controlBar.frame = frame;
		log_debug(@"%@", NSStringFromCGRect(frame));
	}
}

- (void)windowDidLoad {
	[super windowDidLoad];
	[self.window.contentView setWantsLayer:YES];

//	IView *view = [IView namedView:@"TestWindow"];
//	[self.window.contentView addSubview:view];

	_controlBar = [[ControlBar alloc] init];
	[_controlBar bindHandler:^(ControlBarEvent event, IView *view) {
		log_debug(@"%d", event);
	}];
	[self.window.contentView addSubview:_controlBar];
	
	[self windowDidResize:nil];
}

- (void)keyDown:(NSEvent *)event{
	[_controlBar show];
}

@end
