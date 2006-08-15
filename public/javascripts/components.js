// MacroDeck Component API
// Used by MacroDeck Widgets
// (C) 2006 MacroDeck
// -------------------------------------
//
// Released under the licensing terms of MacroDeck Services.

var BaseComponent = Class.create();

BaseComponent.prototype = {
	getVersion:		function() {
						return this.version;
					}
}