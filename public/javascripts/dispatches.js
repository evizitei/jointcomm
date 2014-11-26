var refresh = function(){
  window.location.reload();
};

var setupPolling = function(){
  setTimeout(refresh, 30000);
};

var clearButtonClicked = function(e){
  $.get("/calls/clear",{id: $(this).data("id")}, refresh);
};

var bindClearButtons = function(){
  $("button.clear-btn").click(clearButtonClicked);
};

$(document).ready(function(){
  setupPolling();
  bindClearButtons();
});
