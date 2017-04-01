$(document).ready(function() {
   $.validator.addMethod("nopobox", function(value, element) {
	  return /^[0-9]+\s|-\w+\s\w+$/.test(value);
	}, "PO Boxes are not allowed.");

});
