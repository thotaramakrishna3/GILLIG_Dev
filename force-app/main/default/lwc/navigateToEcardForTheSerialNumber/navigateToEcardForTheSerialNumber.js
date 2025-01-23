import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import gettingPageRecordId from "@salesforce/apex/OpCkMasterDataController.gePageRecordId";
import gettingBusDetails from "@salesforce/apex/OpCkMasterDataController.getBusDetails";

export default class NavigateToEcardForTheSerialNumber extends NavigationMixin(LightningElement) {

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
        var size = 6-data.Name.length;
        if(size > 0){
            for(let i=0;i<size;i++){
                let a = '0';
                var b = '';
                b = b+a;
            }
            this.busName = 'B'+b+''+ data.Name;           
        }else{
            this.busName = 'B' + data.Name;
        } 
        
        this.error = undefined;
        }
        else if (error) { 
            this.error = error;
            this.busDetails = undefined;
        } 
    }

    // Navigate to the Ecard for the part
    navigateToEcard() {
        console.log(this.busName);
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