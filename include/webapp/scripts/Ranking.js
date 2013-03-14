function Ranking(){
    this.gameData = null;
    // Constants!
    this.storageKey = 'mines';
    this.maxData = 5;
}

Ranking.prototype.insertNew = function(gameData){
    this.gameData = gameData;
    // get existing
    var dataQueue = this.getAll();
    
    // Calculate current game's score
    var secondsTaken = this.gameData.timeTaken.hour * 3600 + this.gameData.timeTaken.min * 60 + this.gameData.timeTaken.sec;
    this.gameData.penalty = secondsTaken/this.gameData.numMines;
    // decide whether we should insert this?
    
    if( !dataQueue ){
        dataQueue = new Array();
    }
    
    dataQueue.push(this.gameData);
    // sort
    dataQueue.sort(function(ob1, ob2){
        var retVal = ob2.numMines - ob1.numMines;
        if(retVal == 0){
            retVal = ob1.penalty - ob2.penalty;
        }
        return retVal;
    });
    // remove extra objects 
    if(dataQueue.length > this.maxData){
        dataQueue.pop();
    }
    // Save data
    this.saveAll(dataQueue);
    console.log('New Data: ', dataQueue);
}

/**
 * Retrive all data from localStorage
 */
Ranking.prototype.getAll = function(){
    var dataQueue = localStorage.getItem(this.storageKey);
    if(dataQueue){
        dataQueue = JSON.parse(dataQueue);
    }
    console.log('Getting data: ', dataQueue);
    return dataQueue;
}

Ranking.prototype.saveAll = function(dataQueue){
    dataQueue = JSON.stringify(dataQueue);
    localStorage.setItem(this.storageKey, dataQueue);
}