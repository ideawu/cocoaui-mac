//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#include "Layout.h"

namespace cui{

	Layout::Layout(){
		_borderRadius = 0;
		_ratioWidth = 0;
		_ratioHeight = 0;
		
		_displayType = DisplayAuto;
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
	
	void Layout::frame(const Rect &frame){
		_frame = frame;
	}
	
	void Layout::width(float width){
		_frame.width = width;
	}
	
	void Layout::height(float height){
		_frame.height = height;
	}

	float Layout::ratioWidth() const{
		return _ratioWidth;
	}

	float Layout::ratioHeight() const{
		return _ratioHeight;
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
	
	void Layout::outerWidth(float width){
		_frame.width = width - _margin.left - _margin.right;
	}

	void Layout::outerHeight(float height){
		_frame.height = height - _margin.top - _margin.bottom;
	}


	float Layout::borderRadius() const{
		return _borderRadius;
	}

	void Layout::borderRadius(float borderRadius){
		_borderRadius = borderRadius;
	}

	
	DisplayType Layout::displayType() const{
		return (DisplayType)_displayType;
	}

	void Layout::displayType(DisplayType type){
		_displayType = type;
	}

	FloatType Layout::floatType() const{
		return (FloatType)_floatType;
	}

	void Layout::floatType(FloatType type){
		_floatType = type;
	}

	ValignType Layout::valignType() const{
		return (ValignType)_valignType;
	}
	
	void Layout::valignType(ValignType type){
		_valignType = type;
	}

	ClearType Layout::clearType() const{
		return (ClearType)_clearType;
	}

	void Layout::clearType(ClearType type){
		_clearType = type;
	}

	ResizeType Layout::resizeType() const{
		return (ResizeType)_resizeType;
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

	bool Layout::displayNone() const{
		return _displayType == DisplayNone;
	}


}; // end namespace
