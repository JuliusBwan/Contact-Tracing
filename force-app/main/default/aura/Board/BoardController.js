({
    doInit : function(component, event, helper) {       
        //get number of words based on game mode
        const gameMode = component.get("v.mode");
        let column = 0;

        if (gameMode && gameMode === "hard"){
            column = 6;
        } 
        else if (gameMode === "medium"){
            column = 4;
        } 
        else {
            column = 3;
        }
        //get blockSize based on number of columns
        let blockSize = 12 / column; //(12 is the grid style used by salesforce UI)
        component.set("v.blockSize", blockSize);

        //get list of words
        const words = helper.getWords(column * column);
        component.set("v.words", words);

        //get winning word
        const winWord = helper.getWinWord(words);
        component.set("v.winWord", winWord); //set the win word attr
    }
})