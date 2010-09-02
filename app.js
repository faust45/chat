$(document).ready(function() {
  console.log("Hi man");

  
  $('#send').click(function() {
    var socket = new WebSocket("ws://localhost:8000/socket/server/startDaemon.php");
  });
});
