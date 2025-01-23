import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import gettingPageRecordId from "@salesforce/apex/OpCkMasterDataController.gePageRecordId";
import gettingBusDetails from "@salesforce/apex/OpCkMasterDataController.getBusDetails";


export default class TestSerialNumber extends NavigationMixin(LightningElement) {
    @api recordId;
    @track busDetails; 
    @track error;
    @track busName;
    @track busdetail;

    @track hasEcardid = true; // newly added
    @wire(gettingPageRecordId, { recordId: '$recordId' }) 
    wirePageId({ error, data }) {
        if (data) { 
        this.busDetails = data; 
        this.busName = 'B' + data.Name;
        this.error = undefined;
        }
        else if (error) { 
            this.error = error;
            this.busDetails = undefined;
        } 
    }

    // Navigate to the Ecard for the part
    navigateToEcard() {
        gettingBusDetails({ chassis_no: this.busName })
            .then((result) => {
                if(result.isError == false){
                this.hasEcardid = true;
                this.busdetail = JSON.parse(result.responsebody);
                var ecardid = {
                    "ecardid": this.busdetail.data.ecard.ecard_id,
                    "ChasisNumber": this.busdetail.data.ecard.chassis_no,
                    "BusName": this.busdetail.data.ecard.customer_name,
                    "selecteddepartmentId": "1"     
                }
                localStorage.setItem('ecardid', JSON.stringify(ecardid));
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'E_Cards'
                    }
                });
            }
            else{
                this.hasEcardid = false;
            }
            })
            .catch((error) => {
                console.error('Error:', error); 
            });
    }
}