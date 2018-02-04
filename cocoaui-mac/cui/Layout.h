//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#ifndef Layout_hpp
#define Layout_hpp

#include "types.h"

// innerBox: 包含 content
// frame: 包含 border, padding, content
// outerBox: 包含 margin, border, padding, content

namespace cui{
	class Layout
	{
	public:
		Layout();
		~Layout();
		
		Edge margin() const;
		Edge padding() const;
		Edge border() const;

		Rect frame() const;
		void frame(const Rect &frame);
		void width(float width);
		void height(float height);

		float ratioWidth() const;
		float ratioHeight() const;
		
		Rect innerBox() const;
		void innerWidth(float width);
		void innerHeight(float height);
		Rect outerBox() const;
		void outerBox(const Rect &rect);
		void outerWidth(float width);
		void outerHeight(float height);

		float borderRadius() const;
		void borderRadius(float borderRadius);
		
		DisplayType displayType() const;
		void displayType(DisplayType type);
		FloatType floatType() const;
		void floatType(FloatType type);
		ValignType valignType() const;
		void valignType(ValignType type);
		ClearType clearType() const;
		void clearType(ClearType type);
		ResizeType resizeType() const;
		void resizeType(ResizeType type);

		bool resizeWidth() const;
		bool resizeHeight() const;
		bool displayNone() const;
		
		bool clearLeft() const{return _clearType==ClearLeft;}
		bool clearRight() const{return _clearType==ClearRight;}
		bool clearBoth() const{return _clearType==ClearBoth;}
		bool floatLeft() const{return _floatType==FloatLeft;}
		bool floatRight() const{return _floatType==FloatRight;}
		bool floatCenter() const{return _floatType==FloatCenter;}

	private:
		Rect _frame;
		Edge _padding;
		Edge _border;
		Edge _margin;
		
		float _borderRadius;
		float _ratioWidth;
		float _ratioHeight;
		
		// 位运算报错，所以用int
		int _displayType;
		int _floatType;
		int _valignType;
		int _clearType;
		int _resizeType;
	};
}; // end namespace

#endif /* Layout_hpp */
