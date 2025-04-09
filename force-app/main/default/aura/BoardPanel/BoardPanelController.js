({
    startGame: function(component, event, helper) {
        //access combobox values
        let gameModeComboBox = component.find("gameMode"); 
        //access the value of the combobox       
        let selectedValue = gameModeComboBox.get("v.value");
        //set the value of game mode   
        component.set("v.selectedGameMode", selectedValue); 
        
        const selectedMode = component.get("v.selectedGameMode");

        if (selectedMode){ //if its not null
            const boardComp = component.find("boardComp");
            boardComp.startGame();
        }

    },

    reshuffleBoard: function(component, onclick, helper){
        let reshuffleBtn = component.find("reshuffleId");
        
    }
})