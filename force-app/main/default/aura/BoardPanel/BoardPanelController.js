({
    startGame: function(component, event, helper) {
        //access combobox values
        let gameModeComboBox = component.find("gameMode");
        //access the value of the combobox
        let selectedValue = gameModeComboBox.get("v.value");
        alert(`     START GAME! 
            Mode ==> ${selectedValue}`);
        //set the value of game mode
        component.set("v.selectedGameMode", selectedValue)
    },

    reshuffleBoard: function(component, onclick, helper){
        let reshuffleBtn = component.find("reshuffleId");
        
    }
})