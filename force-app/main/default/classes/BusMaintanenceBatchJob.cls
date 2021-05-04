public class BusMaintanenceBatchJob implements Database.Batchable<SObject>, Schedulable {
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator([
            SELECT Id, Last_Ping_Location__c, Next_Service_Odometer_Reading__c, Odometer_Reading__c, License_Plate__c, Company__c
            FROM Bus__c
            WHERE Maximum_Capacity__c = '60'
            AND ServiceRequired__c = true
        ]);    
    }
    
    public void execute(Database.BatchableContext context, List<Bus__c> buses){
        Map<String, List<Id>> garageLocationMap = new Map<String, List<Id>>();
        Map<String, List<String>> mainLocationMap = new Map<String, List<String>>();
        Map<Id, Maintenance__c> maintenanceReqsMap = new  Map<Id, Maintenance__c>();
        
        for(Garage__c garageRecord : [SELECT Id, Location__c, Company__c
                                      FROM Garage__c
                                     ]){
                                         Location garageLocation = garageRecord.Location__c;
                                         garageLocationMap.put(String.ValueOf(garageLocation.latitude) + '-'+String.ValueOf(garageLocation.longitude), new List<Id>{garageRecord.Id, garageRecord.Company__c});
                                     }
        
        for(Bus__c busRecord : buses){
            if(busRecord.Last_Ping_Location__c != null){
                Location busLocation = busRecord.Last_Ping_Location__c;
                busRecord.Next_Service_Odometer_Reading__c += 5000;
                for(String garageLocation : garageLocationMap.keySet()){
                    if(busRecord.Company__c ==  garageLocationMap.get(garageLocation)[1]){
                        List<String> garageLocationList = garageLocation.split('-');
                        Double distance = Location.getDistance(busLocation, Location.newInstance(Double.valueOf(garageLocationList[0]), Double.valueOf(garageLocationList[1])),  'mi');
                        if(!mainLocationMap.containsKey(busRecord.Id)){
                            mainLocationMap.put(busRecord.Id, new List<String>{String.valueOf(distance), garageLocationMap.get(garageLocation)[0]});
                            maintenanceReqsMap.put(busRecord.Id, new Maintenance__c(
                                Bus__c = busRecord.Id,
                                Schedule_Date_Time__c = System.now(),
                                Schedule_Reason__c = 'Scheduled Maintenance Visit for Every 5000 miles',
                                Garage__c = garageLocationMap.get(garageLocation)[0],
                                Recorded_Odometer__c = busRecord.Odometer_Reading__c
                            ));
                        } else if(distance < Double.valueOf(mainLocationMap.get(busRecord.Id)[0])){
                            mainLocationMap.put(busRecord.Id, new List<String>{String.valueOf(distance), garageLocationMap.get(garageLocation)[0]});
                            maintenanceReqsMap.get(busRecord.Id).Garage__c = garageLocationMap.get(garageLocation)[0];
                        }
                    }
                }                 
            }
        }
        if(!maintenanceReqsMap.isEmpty()){
            insert maintenanceReqsMap.values();
            update buses;
        }
    }
    
    public void finish(Database.BatchableContext context){
    }
}