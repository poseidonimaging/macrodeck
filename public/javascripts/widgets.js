// MacroDeck Widget API
// (C) 2006 Keith Gable <ziggy@ignition-project.com>

var BaseWidget = Class.create();

BaseWidget.prototype = {
	getVersion:		function() {
						return this.version;
					},
	getAuthor:		function() {
						return this.author;
					},
	getName:		function() {
						return this.name;
					}
}

// Widget Helper API

var Widgets = {
	createContainer:	function(instanceId, id, blockLevel) {
							// if blockLevel is true, a div will be created.
							// otherwise, a span will be created.
							if (blockLevel == true) {
								_div = document.createElement('div');
								_div.id = instanceId + "-" + id;
								return _div;
							} else if (blockLevel == false) {
								_span = document.createElement('span');
								_span.id = instanceId + "-" + id;
								return _span;
							} else {
								return false;
							}
						},
	getPaintingSurface:	function(instanceId) {
							// gets the object to paint into for the given instanceId.
							return $(instanceId);
						}
}

// Example Widget.

var OkayCancelWidget = Class.create();

OkayCancelWidget.prototype = {
	initialize:			function(instanceId) {
							this._instanceId = instanceId;
							this.version = "0.1.20060816";
							this.author = "Keith Gable <ziggy@ignition-project.com>";
							this.name = "OK/Cancel Button Widget";
						},
	display:			function(displayMode) {
							this._surface = Widgets.getPaintingSurface(this._instanceId);
							ok = Widgets.createContainer(this._instanceId, "ok", false);
							cancel = Widgets.createContainer(this._instanceId, "cancel", false);
							ok_btn = new InputButtonComponent('OK');
							cancel_btn = new InputButtonComponent('Cancel');
							ok_btn.click = function() { }
							cancel_btn.click = function() { }
							ok_btn.display(ok);
							cancel_btn.display(cancel);
							this._surface.appendChild(ok);
							this._surface.appendChild(cancel);
						}
}