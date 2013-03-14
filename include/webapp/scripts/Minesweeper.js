function Minesweeper(){
    //    console.clear();
    // Constants
    this.rcJoiner = 'a';
    // cell value for  mine
    this.CELLVAL_MINE = -1;
    // PROPERTIES
    this.isGameValid = true;
    this.numCellInRow = parseInt( sessionStorage.getItem('boardHeight') );
    this.numCellInCol = parseInt( sessionStorage.getItem('boardWidth') );
    
    if( !this.numCellInCol || !this.numCellInRow ){
        window.location = 'index.html';
    }
    
    // initiate cells array
    this.cells = new Array(this.numCellInRow);
    this.isFlagged = new Array(this.numCellInRow);
    this.isCellVisited = new Array(this.numCellInRow);
    // Others
    this.numCell = this.numCellInRow * this.numCellInCol;
    this.numMines = Math.ceil(this.numCell * (2.5/16));
    this.flagCounter = 0;
    this.requiredClicks = this.numCell - this.numMines;
    document.title = 'Minesweeper ' + this.numCellInRow + 'X' + this.numCellInCol;
//    console.log('Required clicks: ' + this.requiredClicks);
}

/**
 * Init
 */

Minesweeper.prototype._init = function(){
    // init some vars
    
    // Create 2D arrays
    for(var i=0; i<this.numCellInRow; i++){
        this.cells[i] = new Array(this.numCellInCol);
        this.isFlagged[i] = new Array(this.numCellInCol);
        this.isCellVisited[i] = new Array(this.numCellInCol);
    }
    // generate mines
    var gotMines = 0;
    while(gotMines < this.numMines){
        var randCellId = Math.floor( Math.random() * (this.numCell - 1 ) );
        var rcOb = this._resoluteRowCol(randCellId);
        if( typeof this.cells[ rcOb.row ][ rcOb.col ] === 'undefined' ){
            this.cells[ rcOb.row ][ rcOb.col ] = this.CELLVAL_MINE;
            gotMines++;
        }else{
            continue;
        }
        
    }
    // Initiate 2D arrays with default values
    for(i=0; i < this.numCellInRow; i++){
        for(var j=0; j < this.numCellInCol; j++){
            // Update Cell
            if( typeof this.cells[i][j] === 'undefined' ) {
                this.cells[i][j] = 0;
            }
            // Update Flags
            this.isFlagged[i][j] = false;
            // traverse for empty values
            this.isCellVisited[i][j] = false;
        }
    }
    // count mines
    this._countMines();
    
    // Update some UI 
    $('#flagAvailable').html( this.numMines );
    
// Preload some images
//    var imgArr = ['flag.jpg', 'empty.jpg', 'bomb.jpg'];
//    var imgBase = 'style/img/';
//    var imgObArr = new Array();
//    for(i=0; i<imgArr.length; i++ ){
//        imgObArr[i] = new Image();
//        imgObArr[i].src = imgBase + imgArr[i];
//    }
}

/**
 * Increment Mine count in given index
 */

Minesweeper.prototype._placeSingleMine = function(r, c){
    if( this.cells[r][c] != this.CELLVAL_MINE ){
        this.cells[r][c]++;
    }
}

/**
 * Count Mines
 */

Minesweeper.prototype._countMines = function(){
    // Calculate Mines
    for(var i=0; i < this.numCellInRow; i++){
        for(var j=0; j < this.numCellInCol; j++){
            if( this.cells[i][j] == this.CELLVAL_MINE ) {
                // Mine Found! Update neighbors...
                //                console.log("Mine found in " + i + j);
                
                if( ( (i-1) >= 0) && ( (j-1) >= 0) ){ // Left-top
                    this._placeSingleMine(i-1, j-1);
                }
                if( (i-1) >= 0){ // tops
                    this._placeSingleMine(i-1, j);
                }
                if( ((i-1) >= 0) && ((j+1) < this.numCellInCol ) ){ // top-right
                    this._placeSingleMine(i-1, j+1);
                }
                if( (j-1) >= 0){
                    this._placeSingleMine(i, j-1);
                }
                if( (j+1) < this.numCellInCol ){
                    this._placeSingleMine(i, j+1);
                }
                if( ((i+1) < this.numCellInRow) && ((j-1) >= 0) ){
                    this._placeSingleMine(i+1, j-1);
                }
                if( (i+1) < this.numCellInRow ){
                    this._placeSingleMine(i+1, j);
                }
                if( ((i+1) < this.numCellInRow) && ((j+1) < this.numCellInCol) ){
                    this._placeSingleMine(i+1, j+1);
                }
            }
        }
    }
}

/**
 * Resolute Row & Column from Index
 */

Minesweeper.prototype._resoluteRowCol = function(index){
    var ret = new Object();
    ret.row = Math.floor(index/this.numCellInCol);
    ret.col = index - (this.numCellInCol * ret.row );
    return ret;
}



/**
 * Generate HTML
 */

Minesweeper.prototype._generateHTML = function(){
    var htmlStr = "";
    //    // place Horizontal Aisle
    //    for(j=0; j < this.numCellInRow; j++){
    //        htmlStr += "<div class='aisle horAisle'>&nbsp;</div>";
    //    }
    //    // Fill up extra space
    //    htmlStr += "<div class='aisle horAisleFiller'>&nbsp;</div>";
    //    htmlStr += "<div class='rowbreak'></div>";
    // Create Mine Cells
    for(var i=0; i < this.numCellInRow; i++){
        //        htmlStr += "<div class='aisle verAisle'>&nbsp;</div>";
        for(var j=0; j < this.numCellInCol; j++){
            htmlStr += "<div class = 'cell cellYellow' id = '" + i + this.rcJoiner + j + "'>&nbsp;</div>";
        //            htmlStr += "<div class='aisle verAisle'>&nbsp;</div>";
        }
        htmlStr += "<div class='rowbreak'></div>";
    //        // place Horizontal Aisle
    //        for(j=0; j < this.numCellInRow; j++){
    //            htmlStr += "<div class='aisle horAisle'>&nbsp;</div>";
    //        }
    //        // Fill up extra space
    //        htmlStr += "<div class='aisle horAisleFiller'>&nbsp;</div>";
    //        htmlStr += "<div class='rowbreak'></div>";
    }
    // inject HTML
    $("#map").html(htmlStr);
    this.updateStatus("Map generated");
}

/**
 * Create Map
 */

Minesweeper.prototype._createMap = function(){
    // init
    this._init();
    
    // print
    this._generateHTML();
}

/**
 * Update Status
 */
Minesweeper.prototype.updateStatus = function(status){
    $("#status").html(status);
}



/**
 * Start a game
 */

Minesweeper.prototype.start = function(){
    
    // Create HTML
    this._createMap();

    // Adjust CSS width & heights
    var dashboardH = Math.floor( 30 / 480 * $(window).height() );
    var winW = $(window).width();
    var winH = $(window).height() - dashboardH;
    
    var cellW = Math.floor( winW/this.numCellInCol ) - 4;
    var cellH = Math.floor( winH/this.numCellInRow ) - 4;
    
    // Adjust cell font size
    var cellFontSize = Math.floor( 20/21 * cellH );

    $('.cell').css({
        width: cellW,
        height: cellH
    });
    
    $('.cell').css('font-size', cellFontSize + 'px');

    $('#dashboard').css({
        height: dashboardH
    });
    
    var dashboardChildMarginTop = Math.floor( 9/480 * $(window).height() );
    $('#clock').css('margin-top', dashboardChildMarginTop + 'px');
    // Update Flag Status
    $('#flagUsed').html(this.flagCounter);
}

/**
 *
 */

Minesweeper.prototype.handleNormalClick = function(r, c){
    // Taking care when user clicks same cell twice
    if( this.isCellVisited[r][c] ){
        if( this.cells[r][c] != 0 ){    // Non-empty cells
            this.handleRepeatedClick(r, c);
        }
        return;
    }
    
    // Save the user by ignoring if clicks on a flagged cell
    
    if( this.isFlagged[r][c] ){
        return;
    }
    
    // Determine type of cell clicked by user
    if( this.cells[r][c] == this.CELLVAL_MINE ){
        // user clicked on a MINE CELL!
        this.updateStatus("Game Over! :-(");
        // Mine clicked! Finish Game
        this.stopGame(false);
    }else if( this.cells[r][c] == 0 ){
        // Empty field clicked
        this.emptyCellClicked(r, c);
    }else{
        // Regular cell, just reveal itself.     
        // Make this cell visited to avoid user cheating clicking on the same cell
        if( ! this.isCellVisited[r][c] ){
            this.isCellVisited[r][c] = true;
            this.requiredClicks--;
        }
        
        // Update HTML - show number of bombs around this cell
        $('#' + r + this.rcJoiner + c).html( this.cells[r][c] );
    }
    
    // Check if won?
    if( this.requiredClicks == 0 ){
        this.stopGame(true);
    }else{
    //        console.log('Clicks to go: ', this.requiredClicks);
    }
}

/**
 * Traverses empty cells recursively
 */

Minesweeper.prototype.emptyCellClicked = function(r, c){
    if( (this.cells[r][c] == 0) && (! this.isCellVisited[r][c]) ){
        // This is empty cell. Update the cell style
        $('#' + r + this.rcJoiner + c).attr('class', 'cell cellGray');
        // Make this cell visited
        this.isCellVisited[r][c] = true;
        
        this.requiredClicks--;
        //        console.log('RC ', this.requiredClicks, ' at ' , r,c );
        // traverse valid neighbors
        if( ( (r-1) >= 0) && ( (c-1) >= 0) ){ // Left-top
            this.emptyCellClicked(r-1, c-1);
        }
        if( (r-1) >= 0){ // tops
            this.emptyCellClicked(r-1, c);
        }
        if( ((r-1) >= 0) && ((c+1) < this.numCellInCol ) ){ // top-right
            this.emptyCellClicked(r-1, c+1);
        }
        if( (c-1) >= 0){
            this.emptyCellClicked(r, c-1);
        }
        if( (c+1) < this.numCellInCol ){
            this.emptyCellClicked(r, c+1);
        }
        if( ((r+1) < this.numCellInRow) && ((c-1) >= 0) ){
            this.emptyCellClicked(r+1, c-1);
        }
        if( (r+1) < this.numCellInRow ){
            this.emptyCellClicked(r+1, c);
        }
        if( ((r+1) < this.numCellInRow) && ((c+1) < this.numCellInCol) ){
            this.emptyCellClicked(r+1, c+1);
        }
        
    }else if( this.cells[r][c] != 0 && ( !this.isFlagged[r][c] ) ){
        // Normal cell, just reveal itself if not flagged...
        //        console.log("Normal found on " + r + c);
        // Reveal cell if not visited already
        if(! this.isCellVisited[r][c] ){
            this.isCellVisited[r][c] = true;
            this.requiredClicks--;
            //            console.log('RC ', this.requiredClicks, ' at ' , r,c );
            $('#' + r + this.rcJoiner + c).html( this.cells[r][c] );
        }
        
    }
}

/**
 * Handle special click e.g. Right-button click
 */

Minesweeper.prototype.handleSpecialClick = function(r, c){
    // ignore flagging already visited cells
    if( this.isCellVisited[r][c] ){
        return;
    }
    if( this.isFlagged[r][c] ){
        // Unflag...
        this.isFlagged[r][c] = false;
        this.flagCounter--;
        $('#' + r + this.rcJoiner + c).attr('class', 'cell cellYellow');
    }else{
        //  Flag.
        if( this.flagCounter == this.numMines ){
            // Outrun?
            this.showPopup('Already used maximum number of flags! Unflag some and try again');
            return;
        }
        this.isFlagged[r][c] = true;
        this.flagCounter++;
        $('#' + r + this.rcJoiner + c).attr('class', 'cell cellBlue');
    }
    // Update Flag Status
    $('#flagUsed').html(this.flagCounter);
}

/**
 * Called from handleFlaggedClick
 */

Minesweeper.prototype.handleNeigborCell = function(r, c){
    if( this.isFlagged[r][c] ){
        this.flagsPlacedAround++;
    }else{
        if( !this.isCellVisited[r][c] ){
            var obToPush = {
                r: r, 
                c: c
            };
            //            console.log(obToPush);
            this.cellsToVisit.push( obToPush );
        }
    }
}

/**
 * When user clicks on a cell that's already revealed
 */

Minesweeper.prototype.handleRepeatedClick = function(r, c){
    //    console.log('Flagged Click handling in', r, c);
    // Create new member vars for passing data between functions:
    this.flagsPlacedAround = 0;  // number of flags placed around this cell
    this.cellsToVisit = new Array();
   
    
    // traverse valid neighbors and look for number of flags put around
    if( ( (r-1) >= 0) && ( (c-1) >= 0) ){ // Left-top
        this.handleNeigborCell(r-1, c-1);
    }
    if( (r-1) >= 0){ // tops
        this.handleNeigborCell(r-1, c);
    }
    if( ((r-1) >= 0) && ((c+1) < this.numCellInCol ) ){ // top-right
        this.handleNeigborCell(r-1, c+1);
    }
    if( (c-1) >= 0){
        this.handleNeigborCell(r, c-1);
    }
    if( (c+1) < this.numCellInCol ){
        this.handleNeigborCell(r, c+1);
    }
    if( ((r+1) < this.numCellInRow) && ((c-1) >= 0) ){
        this.handleNeigborCell(r+1, c-1);
    }
    if( (r+1) < this.numCellInRow ){
        this.handleNeigborCell(r+1, c);
    }
    if( ((r+1) < this.numCellInRow) && ((c+1) < this.numCellInCol) ){
        this.handleNeigborCell(r+1, c+1);
    }
    
    // Decide what to do
    
    if( this.flagsPlacedAround == this.cells[r][c] ){
        for(var x=0; x<this.cellsToVisit.length; x++){
            this.handleNormalClick( this.cellsToVisit[x].r, this.cellsToVisit[x].c );
        }
    }
}


/**
 * Take actions to stop the game
 */
Minesweeper.prototype.stopGame = function(isWinner){
    isWinner = (typeof isWinner === 'undefined')?(true):(isWinner);
    // Stop the timer
    $('#clock').find('.stop').click();
    this.isGameValid = false;
    if(isWinner){
        var h = $('#clock').find('.hr').text();
        var m = $('#clock').find('.min').text();
        var s = $('#clock').find('.sec').text();
        this.showPopup('You won! Time required: ' + h + ":" + m + ":" + s);
        // save Data! Construct objects to save
        h = ( h.substring(0, 1) == 0 )?(h.substring(1)):(h);
        m = ( m.substring(0, 1) == 0 )?(m.substring(1)):(m);
        s = ( s.substring(0, 1) == 0 )?(s.substring(1)):(s);
        var timeTaken = {
            hour        :   parseInt(h),
            min         :   parseInt(m),
            sec         :   parseInt(s)
        };
        console.log('Time taken ob ', timeTaken);
        // retrive last player name from localStorage
        var playerName = localStorage.getItem('lastPlayerName');
        playerName = prompt('Your name, please!', playerName);
        localStorage.setItem('lastPlayerName', playerName);
        var gameData = {
            numMines    :   this.numMines,
            playerName  :   playerName,
            timeTaken   :   timeTaken,
            boardWidth  :   this.numCellInCol,
            boardHeight :   this.numCellInRow,
            currentTime :   new Date()
        };
        var ranker = new Ranking();
        ranker.insertNew(gameData);
    }else{
        this.printAll();
    }
}

/**
 * Reveal all cells
 */

Minesweeper.prototype.printAll = function(){
    for(var i=0; i < this.numCellInRow; i++){
        for(var j=0; j < this.numCellInCol; j++){
            if( this.cells[i][j] == this.CELLVAL_MINE ){
                $('#' + i + this.rcJoiner + j).attr('class', 'cell cellRed');
            }else if( this.cells[i][j] == 0 ){
                $('#' + i + this.rcJoiner + j).attr('class', 'cell cellGray');
            }else{
                $('#' + i + this.rcJoiner + j).attr('class', 'cell cellYellow');
                $('#' + i + this.rcJoiner + j).html( this.cells[i][j] );
            }
            
        }
    }
    this.updateStatus("Minefield printed");
}

Minesweeper.prototype.showPopup = function(msg){
    var popupSelector = '#myPopup';
    $(popupSelector).html('<p>' + msg + '</p>');
    $(popupSelector).popup('open');
}