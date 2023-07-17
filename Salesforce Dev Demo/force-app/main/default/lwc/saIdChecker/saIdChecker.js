/**
 * @description       : This lightning component validate the SA ID and extract the Date of Birth, Gender and Cizenship of the 
 *                      user. This information is stored in salesforce against the number of times this ID Number is searched. 
 *                      It also fetch the holidays in the birth year of the user using API call. 
 * @author            : Pravin Waykar
 * @group             : 
 * @last modified on  : 2023-07-16
 * @last modified by  : Pravin Waykar
**/
import { LightningElement,api} from 'lwc';
import updateSAIdSearchInfo from '@salesforce/apex/SAIDController.updateSAIdSearchInfo';
import resource from '@salesforce/resourceUrl/BrandingResources';
export default class SaIdChecker extends LightningElement {
    header_img = resource + '/img/cloudsmithsLogo.png';
    @api isError = false;
    @api isDisabled = false;
    @api strErrorMsg = '';
    @api isLoading = false;
    @api showHeaderTitle = false;
    @api lstHolidays = [];
    @api saIdNumber;
    // initialise the variables
    connectedCallback(){
        this.isDisabled = true;
    }
    // This method is checking the validity of the SA ID. If invalid SA Id is added message is shown to user
    onSAIDChange(event){
        this.isError = true;
         this.saIdNumber = event.currentTarget.value;
        var re = /(([0-9]{2})(0|1)([0-9])([0-3])([0-9]))([ ]?)(([ 0-9]{4})([ ]?)([ 0-1][8]([ ]?)[ 0-9]))/;
        if(this.saIdNumber == ''){
            // clear the error message
            this.strErrorMsg = '';
        }else if( this.saIdNumber.length != 13 ){
            this.strErrorMsg = 'Id Number does not seems authentic. Please add valid Id number.';
        }else if (re.test(this.saIdNumber) == false){
            this.strErrorMsg = "Id Number does not seems authentic. Please add valid Id number.";
            }else{
                this.isError = false;
            }
            this.isDisabled = this.isError;
    }

    // this method sis called on the search action and it extract the important information as Date of Birth,
    // Gender and Citizenship from the SA ID. 
    searchSAId(){
        this.isError = true;
        this.strErrorMsg = '';
        this.isError = false; 
        // this is valid Id number. Lets parse the date part
        let tempDate = new Date(this.saIdNumber.substring(0, 2), this.saIdNumber.substring(2, 4) - 1, this.saIdNumber.substring(4, 6));
            let id_day = tempDate.getDate();
            let id_month = tempDate.getMonth() + 1; // adding 1 to get the correct month
            let id_year = tempDate.getFullYear();
            let birthDate = id_year+'-'+id_month+'-'+id_day;
            //console.log('Birth Date is '+birthDate);

            // get the gender information
            let genderCode = this.saIdNumber.substring(6, 10);
            let gender = parseInt(genderCode) < 5000 ? "Female" : "Male";

            // get country ID for citzenship
            let citzenship = parseInt(this.saIdNumber.substring(10, 11)) == 0 ? "SA Citizen" : "Permanent Resident";

            let saIDSearchrecord = {
                sobjectType: "SAID_Number_Search_Info__c",
                SA_ID_Number__c:this.saIdNumber,
                Gender__c:gender,
                Citizenship__c:citzenship,
                Birth_Date__c:new Date(birthDate)
              };
             
            // save the details to salesforce
            this.saveSAID(saIDSearchrecord);
    }

    // we save the SA ID searh information in the object
    // also we get the information of the holidays in the user's birth year from calendrific API. 
    // we dispaly this holiday information to the user. 
    saveSAID(record){
        this.isLoading = true;
        updateSAIdSearchInfo({newRecord: record})
        .then(result => {
            this.isLoading = false;
            this.lstHolidays = result['lstHolidayWrapper'];
            this.showHeaderTitle = true;
        })
        .catch(error => {
            console.log(error);
            alert('ERROR : '+error); // to be done replace alerts with the nicer error modal/screens
            this.isLoading = false;
            this.showHeaderTitle = false;
        });
    }
}