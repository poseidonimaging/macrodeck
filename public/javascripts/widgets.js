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
					},
	setUserInfo:	function(userInfo) {
						this.userInfo = userInfo;
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
