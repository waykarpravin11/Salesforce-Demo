/*
* Purpose : Apex Class to support SA ID validation funcitonality. This also fetch the SA holidays for the birth
*			year of the user.
*
* @author         Pravin Waykar
* @modifiedBy     Pravin Waykar
* @version        1.0
* @created        2023-07-15
* @modified       2023-07-15
*/
public without sharing class SAIDController {
    private static string CALENDRAFIC_API_ENDPOINT_URL = 'https://calendarific.com/api/v2'; // this can be stored in the custom settings   
    private static string CALENDRAFIC_API_KEY = 'db81fd4f3ce81736c2dd9d732e78c0288fd4c302'; // this can be stored in the custom settings  
    /*
     * @purpose : Method is called from the saIDChecker component to save the SA ID search info and get the
     * 			  list of SA holidays for the birth year  
     * @param : SAID_Number_Search_Info__c  newRecord
     * @return : map<string,Object> - Return the List of Holidays in HolidayWrapper format,
     * 			also returns the state so correct message can be shown in case of error 
     */   
    @AuraEnabled
    public static map<string,Object> updateSAIdSearchInfo(SAID_Number_Search_Info__c  newRecord){
        map<string,Object> mapResults = new map<string,Object>();
        list<SAID_Number_Search_Info__c> lstSAIDSearchInfo = new list<SAID_Number_Search_Info__c>();
        system.debug('newRecord for saving'+newRecord);
        try{
            // make call to the Canedar API to get the holidays for the birth year
            list<HolidayWrapper> lstHolidayWrapper = new list<HolidayWrapper>();
            string resposeString = SAIDController.getHolidayInformation(newRecord.Birth_Date__c.Year()); // pass the birth year to fetch holidays
            system.debug('resposeString '+resposeString);
            resposeString = resposeString.replace('"date":', '"date_x":'); // replace date as reserved keyword
            JSON2ApexHoliday parsedResponse = new JSON2ApexHoliday();
            parsedResponse = (JSON2ApexHoliday)JSON.deserialize(resposeString,JSON2ApexHoliday.class); // parse the response to apex types
            system.debug('parsedResponse.meta '+parsedResponse.meta);
            if( parsedResponse != null && parsedResponse.meta.code == 200 ){ // if code = 200 it is sucessfull else show error code
                integer iIndex = 1;
                for(JSON2ApexHoliday.cls_holidays holiday : parsedResponse.response.holidays){
                    system.debug(' holiday.date => '+holiday.date_x.iso +' '+'holiday.name => '+holiday.name+' '+'holiday.description'+holiday.description);
                    lstHolidayWrapper.add(new HolidayWrapper(Date.valueOf(holiday.date_x.iso),holiday.name,holiday.description,'custom:custom'+iIndex++));
                }
            }
            // get the existing record from the system
            lstSAIDSearchInfo = getLstSAIdNumberSearch(newRecord);
            if(!lstSAIDSearchInfo.isEmpty()){
                // if there is existing record increment the search count by one and save the record
                lstSAIDSearchInfo[0].Searches__c = (lstSAIDSearchInfo[0].Searches__c == null) ? 1 : (lstSAIDSearchInfo[0].Searches__c + 1);
                    update lstSAIDSearchInfo[0];
            }else{
                // this is the first time ID is being searched set # seach count to 1 and save the information
                newRecord.Searches__c = 1;
                insert newRecord;
            }
            
            mapResults.put('lstHolidayWrapper',lstHolidayWrapper);
            mapResults.put('state','success');
        }catch(Exception ex){
            system.debug('Exception in saving record : '+ex+' Cause '+ex.getCause()+' StackTrace '+ex.getStackTraceString());
            mapResults.put('state','error');
            mapResults.put('msg',ex.getMessage());
        }
        return mapResults;
    }
    
    /*
     * @purpose : Method returns the SA ID search record matching with SA ID
     * @param : SAID_Number_Search_Info__c newRecord
     * @return : list<SAID_Number_Search_Info__c>
     */
    private static list<SAID_Number_Search_Info__c> getLstSAIdNumberSearch(SAID_Number_Search_Info__c newRecord){
        string saIDNumber = String.escapeSingleQuotes(newRecord.SA_ID_Number__c);
        return [SELECT id, SA_ID_Number__c, Searches__c FROM SAID_Number_Search_Info__c WHERE SA_ID_Number__c = :saIDNumber LIMIT 1];
    }
    
    /*
     * @purpose : Method returns the SA Holidays for the particular year
     * @param : integer year
     * @return : string
     */
    public static String getHolidayInformation(integer year) {
        // Instantiate a new Http object
        string url = CALENDRAFIC_API_ENDPOINT_URL+'/holidays?api_key='+CALENDRAFIC_API_KEY+
            '&country=ZA&year='+String.valueOf(year);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(120000); 
        // Send the request, and return a response 
        HttpResponse res;
        string responseString;
        if(!Test.isRunningTest()){
	        res = h.send(req);
        	responseString = res.getBody();
        }    
        else{
            // fixed expected response from the API for test class
            responseString = '{\"meta\":{\"code\":200},\"response\":{\"holidays\":[{\"name\":\"NewYearsDay\",'+
                '\"description\":\"NewYear\\u2019 s Day is celebrated with a blend of both diversity and tradition'+
                ' in countries such as South Africa on January 1 each year.\",\"country\":{\"id\":\"za\",\"name\":\"SouthAfrica\"},\"date\":{\"iso\":\"1928-01-01\"}}]}}';
        }
        system.debug('res '+res);  
        return responseString;
    }
    
    // wrapper class to hold the information which we are showing to users.
    public class HolidayWrapper{
        @AuraEnabled public date holidayDate;
        @AuraEnabled public string holidayName;
        @AuraEnabled public string holidayDescription;
        @AuraEnabled public string iconName;
        HolidayWrapper(date holidaydate,string holidayName,string holidayDescription,string iconName){
            this.holidaydate = holidaydate;
            this.holidayName = holidayName;
            this.holidayDescription = holidayDescription;
            this.iconName = iconName;
        }
    }  
}