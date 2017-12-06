$(document).ready(function() {
  // Delay before the modal comes up (milliseconds)
  var delay = 15 * 60000;
  // Delay after displaying modal before moving to different location
  var reactionDelay = 15 * 60000;

  var $modal = $('.modal-mask');
  var $modalBtn = $modal.find(".modal-btn");
  var lastActive = null;
  var modalShown = null;
  var getNow = performance && performance.now ? function(){ return performance.now() } : function(){ return Date.now();}
  var showAFKModal = function showAFKModal() {
    modalShown = getNow();
    $(document.body).append($modal);
    $modal.show();
    $('#main-page').toggleClass('modal-blur');
  };

  var checkTimeout = function checkTimeout() {
    var now = getNow();
    if(!modalShown){
      if(now - lastActive  > delay){
        showAFKModal();
      }
    }else{
      if (now - modalShown  > reactionDelay) {
        $.ajax({
           type: 'DELETE',
           url: '/users/sign_out'
        })
      }
    }
  };

  $modalBtn.on("click", function(e) {
    e.preventDefault();
    $modal.hide();
    $('#main-page').toggleClass('modal-blur');
    $modal.detach();
    modalShown = false;
  });

  lastActive = getNow();

  $(document).on("click keydown keyup focus mousemove",function(){
    lastActive = getNow();
  });

  $(window).on("click keydown keyup focus mousemove",function(){
    lastActive = getNow();
  })
  setInterval(checkTimeout,1000);

 });
