var OkayCancelWidget = Class.create();

OkayCancelWidget.prototype = {
	initialize:function(instanceId) {
		this._instanceId = instanceId;
		this.version = "0.2.20061220";
		this.author = "Keith Gable <ziggy@ignition-project.com>";
		this.name = "OK/Cancel Button Widget";
	},
	display:function(displayMode) {
		this._surface = Widgets.getPaintingSurface(this._instanceId);
		ok = Widgets.createContainer(this._instanceId, "ok", false);
		cancel = Widgets.createContainer(this._instanceId,
			"cancel", false);
		ok_btn = new InputButtonComponent('OK');
		cancel_btn = new InputButtonComponent('Cancel');
		
		// Demo
		if (displayMode == "demo") {
			ok_btn.click = function() {
				alert("You pressed OK!");
			}
			cancel_btn.click = function() {
				alert("You pressed Cancel.");
			}
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

Object.extend(OkayCancelWidget.prototype, BaseWidget.prototype);