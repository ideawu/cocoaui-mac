//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#ifndef types_h
#define types_h

// 定义C语言类型，让OC(非OC++)也能使用

typedef struct{
	CGFloat x, y, w, h;
}IRect;

typedef struct{
	CGFloat top, bottom, left, right;
}IEdge;

typedef enum{
	IViewStateNone     = 0,
	IViewStateHover    = 1<<0,
	IViewStateDown     = 1<<1,
	IViewStateActive   = 1<<2,
}IViewState;

typedef enum{
	IEventUnhighlight  = 1<<0,
	IEventHighlight    = 1<<1,
	IEventClick        = 1<<2,
	IEventHover        = 1<<5,
	IEventUnhover      = 1<<6,
}IEventType;

typedef enum{
	IStyleDisplayAuto = 0,
	IStyleDisplayNone = 1,
}IStyleDisplayType;

typedef enum{
	IStyleClearNone  = 0,
	IStyleClearLeft  = 1<<0,
	IStyleClearRight = 1<<1,
	IStyleClearBoth  = IStyleClearLeft | IStyleClearRight
}IStyleClearType;

typedef enum{
	IStyleFloatLeft   = 1<<0,
	IStyleFloatRight  = 1<<1,
	IStyleFloatCenter = IStyleFloatLeft | IStyleFloatRight
}IStyleFloatType;

typedef enum{
	IStyleValignTop    = 0,
	IStyleValignBottom = 1<<0,
	IStyleValignMiddle = 1<<1,
}IStyleValignType;

typedef enum{
	IStyleResizeNone   = 0,
	IStyleResizeWidth  = 1<<0,
	IStyleResizeHeight = 1<<1,
	IStyleResizeBoth   = IStyleResizeWidth | IStyleResizeHeight
}IStyleResizeType;

typedef enum{
	IStyleOverflowHidden   = 0,
	IStyleOverflowVisible  = 1<<0
}IStyleOverflowType;

typedef enum{
	IStyleBorderDrawNone     = 0,
	IStyleBorderDrawSeparate = 1<<0,
	IStyleBorderDrawAll      = 1<<1
}IStyleBorderDrawType;

typedef enum{
	IStyleTextAlignNone     = -1,
	IStyleTextAlignLeft     = 0,
	IStyleTextAlignCenter   = 1,
	IStyleTextAlignRight    = 2,
	IStyleTextAlignJustify  = 3
}IStyleTextAlign;

typedef enum{
	IStyleBorderSolid,
	IStyleBorderDashed,
}IStyleBorderType;

#endif /* types_h */
