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
		Rect innerBox() const;
		void innerWidth(float width);
		void innerHeight(float height);
		Rect outerBox() const;
		void outerBox(const Rect &rect);

		float borderRadius() const;
		void borderRadius(float borderRadius);
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

	private:
		Rect _frame;
		Edge _padding;
		Edge _border;
		Edge _margin;
		float _borderRadius;
		FloatType _floatType;
		ValignType _valignType;
		ClearType _clearType;
		ResizeType _resizeType;
	};
}; // end namespace

#endif /* Layout_hpp */
