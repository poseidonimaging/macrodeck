// Input Button Component
// (C) Keith Gable <ziggy@ignition-project.com>
// --------------------------------------------
//
// Released under the licensing terms of MacroDeck Services.

var InputButtonComponent = Class.create();

InputButtonComponent.prototype = {
	initialize:		function (caption) {
						this.caption = caption;
						this.version = "0.1.20060814";
						this.author = "Keith Gable <ziggy@ignition-project.com>";
						
						// internal variables.
						this._width = '';
						this._height = '';
					},
	display:		function (where) {
						// get the object to paint
						paintobj = $(where);
						// create the button object
						button = document.createElement("input");
						button.type = "button";
						button.value = this.caption;
						button.style.width = this._width;
						button.style.height = this._height;
						
						// add the button.
						paintobj.appendChild(button);
						this._buttonObj = button;
						// hook click.
						Event.observe(button, 'click', this.click, false);
					},
	setWidth:		function (newWidth) {
						if (this._buttonObj) {
							this._buttonObj.style.width = newWidth;
							this._width = newWidth;
							return true;
						} else {
							this._width = newWidth;
							return true;
						}
					},
	setHeight:		function (newHeight) {
						if (this._buttonObj) {
							this._buttonObj.style.height = newHeight;
							this._height = newHeight;
							return true;
						} else {
							this._height = newHeight;
							return true;
						}
					}
}

Object.extend(InputButtonComponent.prototype, BaseComponent.prototype);