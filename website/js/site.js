$().ready(function() {
  $("#wrapper").dropShadow();
  $("h2").corner("tl bl 10px");

  $(".mit").click(function() {
    $("#licence-text").toggle();
    $("#wrapper").redrawShadow();
  });
});
