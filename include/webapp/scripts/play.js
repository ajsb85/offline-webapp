
function createNewGame(){
    // Create Game Object
    var gameOb = new Minesweeper();
    gameOb.start();

    
    // BIND EVENTS /////////////////////////////////
    var longTapped = false;
    
    $('.cell').tap(function(event){
        if( longTapped ){
            return;
        }
        
        // HANDLE REGULAR CLICK
        // Return if game over
        if( !gameOb.isGameValid ){
            return;
        }

        var cellID = $(this).attr('id');
        cellID = cellID.split( gameOb.rcJoiner );
        var row = parseInt( cellID[0] );
        var col = parseInt( cellID[1] );
        gameOb.handleNormalClick(row, col);
    });
    
    $('.cell').taphold(function(event){
        longTapped = true;
        setTimeout(function(){
            longTapped = false;
        }, 500);
        
        // HANDLE SPECIAL CLICK
        
        // Return if game over
        if( !gameOb.isGameValid ){
            return;
        }

        var cellID = $(this).attr('id');
        cellID = cellID.split( gameOb.rcJoiner );
        var row = parseInt( cellID[0] );
        var col = parseInt( cellID[1] );
        gameOb.handleSpecialClick(row, col);
    });

    // RIGHT-CLICK FOR MOUSE
    $('.cell').mouseup(function (event){
        
        // Return if game over
        if( !gameOb.isGameValid ){
            return;
        }

        var cellID = $(this).attr('id');
        cellID = cellID.split( gameOb.rcJoiner );
        var row = parseInt( cellID[0] );
        var col = parseInt( cellID[1] );
        
        // detect which click/hold event?
        
        switch( event.which ){
            case 3:
                // Double-click
                gameOb.handleSpecialClick(row, col);
                break;
        }
        
        event.preventDefault();
        event.stopPropagation();
    });
    
    

    // Disable browser context menu appearing
    $('.cell').bind("contextmenu", function(e) {
        return false;
    });
    
    // Prevent default behavior on Android
        
    function absorbEvent_(event) {
        var e = event || window.event;
        e.preventDefault && e.preventDefault();
        e.stopPropagation && e.stopPropagation();
        e.cancelBubble = true;
        e.returnValue = false;
        return false;
    }
    
    function preventLongPressMenu(elem) {
        elem.ontouchstart = absorbEvent_;
        elem.ontouchmove = absorbEvent_;
        elem.ontouchend = absorbEvent_;
        elem.ontouchcancel = absorbEvent_;
    }
    
    $('.cell').bind('ontouchstart', absorbEvent_);
    $('.cell').bind('ontouchmove', absorbEvent_);
    $('.cell').bind('ontouchend', absorbEvent_);
    $('.cell').bind('ontouchcancel', absorbEvent_);
    
    // do with the stopwatch
    $('#clock').stopwatch();
}




// Bind new Game

$('#newGameBtn').click(function(){
    createNewGame();
});

$('#menuBtn').click(function(){
    window.location = 'index.html';
});


// Auto-start a new game
createNewGame();
