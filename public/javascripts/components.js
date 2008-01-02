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
					},
	getAuthor:		function() {
						return this.author;
					},
	setUserInfo:	function(userInfo) {
						var uinfo = $H(userInfo);
						this.userInfo = uinfo;
					}					
}