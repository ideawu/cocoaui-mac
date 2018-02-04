//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#include "Layout.h"

namespace cui{

	Layout::Layout(){
		_borderRadius = 0;
		_floatType = FloatLeft;
		_valignType = ValignTop;
		_clearType = ClearNone;
		_resizeType = ResizeBoth;
	}
	
	Layout::~Layout(){
	}


	Edge Layout::margin() const{
		return _margin;
	}

	Edge Layout::padding() const{
		return _padding;
	}

	Edge Layout::border() const{
		return _border;
	}

	Rect Layout::frame() const{
		return _frame;
	}

	Rect Layout::innerBox() const{
		return _frame.subEdge(_border).subEdge(_padding);
	}
	
	void Layout::innerWidth(float width){
		_frame.width = width + _padding.left + _padding.right + _border.left + _border.right;
	}

	void Layout::innerHeight(float height){
		_frame.height = height + _padding.top + _padding.bottom + _border.top + _border.bottom;
	}

	Rect Layout::outerBox() const{
		return _frame.addEdge(_margin);
	}

	void Layout::outerBox(const Rect &rect){
		_frame = rect.subEdge(_margin);
	}
	

	float Layout::borderRadius() const{
		return _borderRadius;
	}

	void Layout::borderRadius(float borderRadius){
		_borderRadius = borderRadius;
	}

	FloatType Layout::floatType() const{
		return _floatType;
	}

	void Layout::floatType(FloatType type){
		_floatType = type;
	}

	ValignType Layout::valignType() const{
		return _valignType;
	}
	
	void Layout::valignType(ValignType type){
		_valignType = type;
	}

	ClearType Layout::clearType() const{
		return _clearType;
	}

	void Layout::clearType(ClearType type){
		_clearType = type;
	}

	ResizeType Layout::resizeType() const{
		return _resizeType;
	}

	void Layout::resizeType(ResizeType type){
		_resizeType = type;
	}

	bool Layout::resizeWidth() const{
		return _resizeType & ResizeWidth;
	}

	bool Layout::resizeHeight() const{
		return _resizeType & ResizeHeight;
	}


}; // end namespace
