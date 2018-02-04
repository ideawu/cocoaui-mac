//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#ifndef s_h
#define s_h

class Point{
public:
	float x, y;
	
	Point(){
		x = y = 0;
	}
	
	Point(float x, float y){
		this->x = x;
		this->y = y;
	}
};

class Edge{
public:
	float top, bottom, left, right;
	
	Edge(){
		top = bottom = left = right = 0;
	}
};

class Rect{
public:
	float x, y, width, height;
	
	Rect(){
		x = y = width = height = 0;
	}
	
	Rect(float x, float y, float width, float height){
		this->x = x;
		this->y = y;
		this->width = width;
		this->height = height;
	}
	
	float x2() const{
		return x + width;
	}
	
	float y2() const{
		return y + height;
	}
	
	Rect addEdge(const Edge &edge) const{
		Rect box = *this;
		box.x -= edge.left;
		box.y -= edge.top;
		box.width += edge.left + edge.right;
		box.height += edge.top + edge.bottom;
		return box;
	}
	
	Rect subEdge(const Edge &edge) const{
		Rect box = *this;
		box.x += edge.left;
		box.y += edge.top;
		box.width -= edge.left + edge.right;
		box.height -= edge.top + edge.bottom;
		return box;
	}
};

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
	DisplayAuto = 0,
	DisplayNone = 1,
}DisplayType;

typedef enum{
	ClearNone  = 0,
	ClearLeft  = 1<<0,
	ClearRight = 1<<1,
	ClearBoth  = ClearLeft | ClearRight
}ClearType;

typedef enum{
	FloatLeft   = 1<<0,
	FloatRight  = 1<<1,
	FloatCenter = FloatLeft | FloatRight
}FloatType;

typedef enum{
	ValignTop    = 0,
	ValignBottom = 1<<0,
	ValignMiddle = 1<<1,
}ValignType;

typedef enum{
	ResizeNone   = 0,
	ResizeWidth  = 1<<0,
	ResizeHeight = 1<<1,
	ResizeBoth   = ResizeWidth | ResizeHeight
}ResizeType;

typedef enum{
	OverflowHidden   = 0,
	OverflowVisible  = 1<<0
}OverflowType;

typedef enum{
	BorderDrawNone     = 0,
	BorderDrawSeparate = 1<<0,
	BorderDrawAll      = 1<<1
}BorderDraw;

typedef enum{
	TextAlignNone     = -1,
	TextAlignLeft     = 0,
	TextAlignCenter   = 1,
	TextAlignRight    = 2,
	TextAlignJustify  = 3
}TextAlign;

typedef enum{
	BorderSolid,
	BorderDashed,
}BorderType;

#endif /* s_h */
