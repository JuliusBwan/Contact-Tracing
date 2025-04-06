({
    getWords: function(count) {
        if (count > 100) return; //if count is greater tahn 100, return nothing, else return words in this array

        let wordsArr = ["expansion", "grandfather", "nappy", "oranges", "beds", "quack", "achiever", "yell", "hospital",
            "winter", "understood", "squalid", "merciful", "reaction", "wipe", "fearless", "tiresome", "introduce", "planes",
            "drum", "muddle", "capable", "canvas", "route", "enchanted", "quirky", "switch", "apparatus", "loss", "agreement", 
            "substance", "back", "oafish", "expand", "aromatic", "quarrelsome", "free", "useful",
            "raspy", "drown", "ring", "lush", "numberless", "embarrass", "shrill", "rice", "ice", "crow", "pumped", "sparkle", "instruct",
            "girl", "glass", "frog", "murky", "impolite", "crabby", "pin", "grade","upbeat", "linen", "flaky", "side", "unknown", "cactus",
            "round", "busy", "grab", "crush", "faithful", "mother", "clean", "unhealthy", "event", "absent", "thoughtless", "icy",
            "prefer", "charge", "confuse", "clam", "dress", "snake", "evasive", "unit", "flow", "annoying", "gusty", "possessive",
            "rhetorical", "rule", "frantic", "farm", "poor", "possess", "men", "pleasant", "zoom", "sidewalk", "reply"
        ];
        //randomise the array 
        wordsArr = this.randomizeArray(wordsArr); //rewriting the wordsArr
        return wordsArr.slice(0, count);
    },
    //return a randomised version of the array to randomise the words returned
    randomizeArray: function(arr){
        const randomArr = arr; //renaming our array--not needed
        //randomise the array
        for (let i = randomArr.length - 1; i > 0; i--){
            const j = Math.floor(Math.random() * i);
            const temp = randomArr[i];
            randomArr[i] = randomArr[j];
            randomArr[j] = temp;
        }
        return randomArr;
    },
    //retrun the winning word
    getWinWord: function(arr){
        const randIndex = Math.floor(Math.random() * arr.length);
        return arr[randIndex];
    }
    
})