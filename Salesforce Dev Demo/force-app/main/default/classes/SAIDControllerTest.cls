/*
* Purpose : Test class for SAIDController 
*			Test class for JSON2ApexHoliday
*
* @author         Pravin Waykar
* @modifiedBy     Pravin Waykar
* @version        1.0
* @created        2023-07-15
* @modified       2023-07-15
*/
@isTest
public class SAIDControllerTest {
    static testMethod void testSAIDSearch(){
        Test.startTest();
        SAID_Number_Search_Info__c  newRecord = new SAID_Number_Search_Info__c();
 		newRecord.Birth_Date__c = date.today().addYears(-30);
        newRecord.Citizenship__c = 'SA Citizen';
        newRecord.Gender__c = 'Male';
        newRecord.SA_ID_Number__c = '2810285800082';
        SAIDController.updateSAIdSearchInfo(newRecord);
        // check if the record is saved
        list<SAID_Number_Search_Info__c> lstSearchRecords = new list<SAID_Number_Search_Info__c>([SELECT id,SA_ID_Number__c,Searches__c FROM SAID_Number_Search_Info__c]);
        system.assertEquals(lstSearchRecords.size(), 1, 'Record is not saved to database');
        
        // test if the #searches are correct
        map<string,Object> mapResults = new map<string,Object>();
        mapResults = SAIDController.updateSAIdSearchInfo(newRecord);
        lstSearchRecords = new list<SAID_Number_Search_Info__c>([SELECT id,SA_ID_Number__c,Searches__c FROM SAID_Number_Search_Info__c]);
        system.assertEquals(lstSearchRecords[0].Searches__c, 2, 'Search Record Information is not updating correctly');
		
        // test that the holidays are returned
        system.assertNotEquals(mapResults.get('lstHolidayWrapper'),null);
        
        // check if the SA ID is different unique search record is created
        newRecord = new SAID_Number_Search_Info__c();
 		newRecord.Birth_Date__c = date.today().addYears(-30);
        newRecord.Citizenship__c = 'SA Citizen';
        newRecord.Gender__c = 'Male';
        newRecord.SA_ID_Number__c = '2810265800086 ';
        SAIDController.updateSAIdSearchInfo(newRecord);
        // check if the record is saved
        lstSearchRecords = new list<SAID_Number_Search_Info__c>([SELECT id,SA_ID_Number__c,Searches__c FROM SAID_Number_Search_Info__c]);
        system.assertEquals(lstSearchRecords.size(), 2, 'Record is not saved to database');
        Test.stopTest();
    }
}