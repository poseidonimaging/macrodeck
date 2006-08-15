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
					},
	display:		function (where) {
						// get the object to paint
						paintobj = $(where);
						// create the button object
						button = document.createElement("input");
						button.type = "button";
						button.value = this.caption;
						// add the button.
						paintobj.appendChild(button);
						// hook click.
						Event.observe(button, 'click', this.click, false);
					}
}

Object.extend(InputButtonComponent.prototype, BaseComponent.prototype);