// Text Box Component
// (C) Keith Gable <ziggy@ignition-project.com>
// --------------------------------------------
//
// Released under the licensing terms of MacroDeck Services.

// Using This Component:
// --------------------------------------------
//
// Initialize it.
// 
//   tb = new TextboxComponent();
//
// And now you can do stuff. Look at the source, it's
// easy to figure out .

var TextBoxComponent = Class.create();

TextBoxComponent.prototype = {
	initialize:function () {
		this._value = "";
		this.version = "0.1.20061229";
		this.author = "Keith Gable <ziggy@ignition-project.com>";
		
		// internal variables.
		this._width = '';
		this._height = '';
		this._size = '';
	},
	display:function (where) {
		// get the object to paint
		paintobj = $(where);
		// create the text box object
		textbox = document.createElement("input");
		textbox.type = "text";
		textbox.style.width = this._width;
		textbox.style.height = this._height;
		textbox.size = this._size;
		// add the button.
		paintobj.appendChild(textbox);
		this._textBoxObj = textbox;
	},
	setWidth:function (newWidth) {
		if (this._textBoxObj) {
			this._textBoxObj.style.width = newWidth;
			this._width = newWidth;
			return true;
		} else {
			this._width = newWidth;
			return true;
		}
	},
	getWidth:function() {
		if (this._textBoxObj) {
			// return the box's actual width.
			return this._textBoxObj.style.width;
		} else {
			// return what the width will be
			return this._width;
		}
	},
	setHeight:function (newHeight) {
		if (this._textBoxObj) {
			this._textBoxObj.style.height = newHeight;
			this._height = newHeight;
			return true;
		} else {
			this._height = newHeight;
			return true;
		}
	},
	getHeight:function () {
		if (this._textBoxObj) {
			return this._textBoxObj.style.height;
		} else {
			return this._height;
		}
	},
	setValue:function (newValue) {
		if (this._textBoxObj) {
			// button exists, we set the caption on the button.
			this._textBoxObj.value = newValue;
			this._value = newValue;
		} else {
			// button has not been painted yet.
			this._value = newValue;
		}
	},
	getValue:function () {
		if (this._textBoxObj) {
			return this._textBoxObj.value;
		} else {
			return this._value;
		}
	},
	setSize:function (newSize) {
		if (this._textBoxObj) {
			this._textBoxObj.size = newSize;
			this._size = newSize;
		} else {
			this._size = newSize;
		}
	},
	getSize:function () {
		if (this._textBoxObj) {
			return this._textBoxObj.size;
		} else {
			return this._size;
		}
	}
}

Object.extend(TextBoxComponent.prototype, BaseComponent.prototype);