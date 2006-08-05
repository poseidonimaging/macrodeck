// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Effect.ExpandContractTree = function(element, expander) {
  element = $(element);
  expander = $(expander);
  if(Element.visible(element)) {
	expander.className = "expand";
	new Effect.SlideUp(element);
  } else {
    expander.className = "expanded";
    new Effect.SlideDown(element);
  }
}

