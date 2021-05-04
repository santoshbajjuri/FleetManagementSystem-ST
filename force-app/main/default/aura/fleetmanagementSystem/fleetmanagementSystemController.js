({
    doInit: function (component, event, helper) {
        var action=component.get('c.getAllBusRecords');
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                for(var i=0; i<response.getReturnValue().length; i++){
                    response.getReturnValue()[i].License_Plate__c = 'License Plate #' + response.getReturnValue()[i].License_Plate__c;
                    if(i == 0){
                        response.getReturnValue()[i].class = 'selected';
                    }
                    else{
                        response.getReturnValue()[i].class = 'notSelected';
                    }
                }
                helper.passData(component,event,helper,response.getReturnValue()[0].Id);
                component.set("v.busList",response.getReturnValue());
            }else if(state==="ERROR"){
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleData: function(component, event, helper){
        var busList = [];
        busList = component.get("v.busList");
        for(var i = 0; i < busList.length; i++){
            if(busList[i].Id == event.currentTarget.getAttribute("data-Id")){
               busList[i].class = 'selected'; 
            }
            else{
                busList[i].class = 'notSelected';
            }
        }
        component.set("v.busList", busList);
        helper.passData(component,event,helper,event.currentTarget.getAttribute("data-Id"));
    }
})