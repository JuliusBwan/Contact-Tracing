({
    onclickBlockHandler : function(component, event, helper) {
        let open = component.get("v.open");
        if (!open){
            component.set("v.open", true);
        }
    }
})