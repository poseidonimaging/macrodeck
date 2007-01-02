var ImageWidget = Class.create();

ImageWidget.prototype = {
	initialize:function(instanceId) {
		this._instanceId = instanceId;
		this.version = "0.2.20061220";
		this.author = "Keith Gable <ziggy@ignition-project.com>";
		this.name = "ImageWidget";
	},
	display:function(displayMode) {
		this._surface = Widgets.getPaintingSurface(this._instanceId);
		i = Widgets.createContainer(this._instanceId, "img", false);
		
		// Demo
		if (displayMode == "demo") {
			i_img = new ImageComponent('/images/logo/logo-glass.png');
		} else {
			ok_btn.click = this.okClick;
			cancel_btn.click = this.cancelClick;
		}
		
		ok_btn.display(ok);
		cancel_btn.display(cancel);
		this._surface.appendChild(ok);
		this._surface.appendChild(cancel);
	}
}

Object.extend(ImageWidget.prototype, BaseWidget.prototype);