// Image Component
// (C) Keith Gable <ziggy@ignition-project.com>
// --------------------------------------------
//
// Released under the licensing terms of MacroDeck Services.

// Using This Component:
// --------------------------------------------
//
// Initialize it.
// 
//   image = new ImageComponent('http://www.you.com/image.png');
//
// And now you can do stuff. Look at the source, it's
// easy to figure out.

var ImageComponent = Class.create();

ImageComponent.prototype = {
	initialize:function (url) {
		this._image = url;
		this.version = "0.1.20061230";
		this.author = "Keith Gable <ziggy@ignition-project.com>";
		
		// internal variables.
		this._width = '';
		this._height = '';
	},
	display:function (where) {
		// get the object to paint
		paintobj = $(where);
		// create the text box object
		img = document.createElement("img");
		img.style.width = this._width;
		img.style.height = this._height;
		// add it to the canvas
		paintobj.appendChild(img);
		this._imgObj = img;
	},
	setWidth:function (newWidth) {
		if (this._imgObj) {
			this._imgObj.style.width = newWidth;
			this._width = newWidth;
			return true;
		} else {
			this._width = newWidth;
			return true;
		}
	},
	getWidth:function() {
		if (this._imgObj) {
			// return the box's actual width.
			return this._imgObj.style.width;
		} else {
			// return what the width will be
			return this._width;
		}
	},
	setHeight:function (newHeight) {
		if (this._imgObj) {
			this._imgObj.style.height = newHeight;
			this._height = newHeight;
			return true;
		} else {
			this._height = newHeight;
			return true;
		}
	},
	getHeight:function () {
		if (this._imgObj) {
			return this._imgObj.style.height;
		} else {
			return this._height;
		}
	},
	setImage:function (newImage) {
		if (this._imgObj) {
			// button exists, we set the caption on the button.
			this._imgObj.src = newValue;
			this._image = newImage;
		} else {
			// button has not been painted yet.
			this._image = newImage;
		}
	},
	getImage:function () {
		if (this._imgObj) {
			return this._imgObj.src;
		} else {
			return this._image;
		}
	}
}

Object.extend(ImageComponent.prototype, BaseComponent.prototype);