({
    startGame: function(component, event, helper) {
        //access combobox values
        let gameModeComboBox = component.find("gameMode");        
        let selectedValue = gameModeComboBox.get("v.value");
        //access the value of the combobox
        component.set("v.selectedGameMode", selectedValue); //set the value of game mode    
    },

    reshuffleBoard: function(component, onclick, helper){
        let reshuffleBtn = component.find("reshuffleId");
        
    }
})