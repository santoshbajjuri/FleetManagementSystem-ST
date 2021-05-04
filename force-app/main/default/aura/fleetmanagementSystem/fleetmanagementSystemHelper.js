({
	passData : function(component, event, helper, recordId) {
		var appEvent = $A.get("e.c:FleetManagementSystemEvent"); 
        appEvent.setParams({
            "busRecordId" : recordId,
        });
        appEvent.fire(); 	
	}
})