@isTest
public class BusTriggerTest {

    public static String BUS_CURRENT_STATUS = 'Ready for Use';
    
    @testSetup
    static void setup(){
        Company__c testCompany = new Company__c(
        	Name = 'Test Company'
        );
        insert testCompany;
        
    	Bus__c testBus = new Bus__c(
        	Name = 'Test Bus',
            Maximum_Capacity__c = '24',
            Odometer_Reading__c = 90000,
            Year__c = '2010',
            Company__c = testCompany.Id
        );
        insert testBus;
    }
    
    @isTest
    static void testInsertBusResaleValue(){
    	Bus__c testBusRecord =  getBusRecord('Test Bus');
        testBusRecord.Current_Status__c = BUS_CURRENT_STATUS;
        testBusRecord.Odometer_Reading__c = 120000;
        update testBusRecord;
        
        Bus__c updatedBusRecord = getBusRecord(testBusRecord.Name);
        System.assertEquals(updatedBusRecord.Resale_Value__c, 118000);
    }
    
    @isTest
    static void testUpdateBusResaleValue(){
    	Bus__c testBusRecord = getBusRecord('Test Bus');
        testBusRecord.Current_Status__c = BUS_CURRENT_STATUS;
        testBusRecord.Year__c = '1970';
        testBusRecord.Has_AC__c = true;
        update testBusRecord;   
        
        Bus__c updatedBusRecord = getBusRecord(testBusRecord.Name);
        System.assertEquals(updatedBusRecord.Resale_Value__c, 165624);
    }
    
    private static Bus__c getBusRecord(String busName){
        return [
            SELECT Id, Resale_Value__c, Name
            FROM Bus__c
            WHERE Name =: busName 
        ];
    }
}