$(document).ready(function(){
	$.ajax({
		url: "/experiments/5/analyze",
		success: function(result){
			$("#result").html(result);
		},
		error: function(xhr, error){
			$("#result").html(xhr.responseText);
		}
	});
});