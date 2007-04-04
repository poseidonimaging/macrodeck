// Input Button Component
// (C) Keith Gable <ziggy@ignition-project.com>
// --------------------------------------------
//
// Released under the licensing terms of MacroDeck Services.

// Using This Component:
// --------------------------------------------
//
// Set the caption while creating with the constructor:
//
//    btn = new InputButtonComponent('OK');
//
// Assign a function to run when the button is pressed:
//
//    btn.click = function() { alert("Clicked OK!"); }
//
// It's a simple component, so figuring out the rest is
// relatively simple.

var InputButtonComponent = Class.create();

InputButtonComponent.prototype = {
	initialize:function (caption) {
		this._caption = caption;
		this.version = "0.1.20061228";
		this.author = "Keith Gable <ziggy@ignition-project.com>";
		
		// internal variables.
		this._width = '';
		this._height = '';
	},
	display:function (where) {
		// get the object to paint
		paintobj = $(where);
		// create the button object
		button = document.createElement("input");
		button.type = "button";
		button.value = this._caption;
		button.style.width = this._width;
		button.style.height = this._height;
		
		// add the button.
		paintobj.appendChild(button);
		this._buttonObj = button;
		// hook click.
		Event.observe(button, 'click', this.click, false);
	},
	setWidth:function (newWidth) {
		if (this._buttonObj) {
			this._buttonObj.style.width = newWidth;
			this._width = newWidth;
			return true;
		} else {
			this._width = newWidth;
			return true;
		}
	},
	getWidth:function() {
		if (this._buttonObj) {
			// return the button's actual width.
			return this._buttonObj.style.width;
		} else {
			// return what the width will be
			return this._width;
		}
	},
	setHeight:function (newHeight) {
		if (this._buttonObj) {
			this._buttonObj.style.height = newHeight;
			this._height = newHeight;
			return true;
		} else {
			this._height = newHeight;
			return true;
		}
	},
	getHeight:function () {
		if (this._buttonObj) {
			return this._buttonObj.style.height;
		} else {
			return this._height;
		}
	},
	setCaption:function (newCaption) {
		if (this._buttonObj) {
			// button exists, we set the caption on the button.
			this._buttonObj.value = newCaption;
			this._caption = newCaption;
		} else {
			// button has not been painted yet.
			this._caption = newCaption;
		}
	},
	getCaption:function () {
		if (this._buttonObj) {
			return this._buttonObj.value;
		} else {
			return this._caption;
		}
	}
}

Object.extend(InputButtonComponent.prototype, BaseComponent.prototype);