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

@interface TestWindow ()<NSWindowDelegate>

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
	
//	IView *container = [[IView alloc] init];
//	[container.style set:@"border: 10px solid #f33;"];
//	[self.window.contentView addSubview:container];

//	{
//		IView *view = [[IView alloc] init];
//		[view.style set:@"width: 100; height: 100; margin: 10; border: 1px solid #000; background: #666 url(alex.png);"];
//		[view bindEvent:IEventClick handler:^(IEventType event, IView *view) {
//			log_debug(@"");
//		}];
//		[container addSubview:view];
//	}
//	
//	{
//		IView *view = [[IView alloc] init];
//		[view.style set:@"width: 100; height: 100; margin: 0; border: 1px solid #000; background: #666 url(alex.png);"];
//		[container addSubview:view];
//	}
//
//	{
//		ILabel *view = [ILabel labelWithText:@"ABC"];
//		[view.style set:@"border: 11px solid #00f; text-align: center;"];
//		[container addSubview:view];
//	}

}

@end
