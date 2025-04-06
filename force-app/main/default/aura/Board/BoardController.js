({
    doInit : function(component, event, helper) {
        //return list of 6 random words from arr
        const words = helper.getWords(6);
        //return winning word
        const winWord = helper.getWinWord(words);
        alert("Winning word: " + winWord);

        //set these values to the cmp attributes
        component.set("v.words", words); //set the words list attr
        component.set("v.winWord", winWord); //set the win word attr

    }
})