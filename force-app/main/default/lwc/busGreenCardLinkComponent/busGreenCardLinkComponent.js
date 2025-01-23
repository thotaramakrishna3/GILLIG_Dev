import { LightningElement, track, api, wire } from 'lwc';
import getGreenSheetLink from '@salesforce/apex/UploadBusPdf.getBusGreensheetLink';
import getBusData from '@salesforce/apex/UploadBusPdf.getBusData'

export default class BusGreenCardLinkComponent extends LightningElement {
    @track linkavailable = false;
    @track greencardurl;
    @track pdfdata;
    @track error;
    @track showdetails;
    @track busdata;

    @api recordId;

    @wire(getBusData, { recordBusId: '$recordId' })
    wiredRecordsMethod({ error, data }) {
        if (data) {
            this.busdata = data;
            this.error = false;
            this.getGreensheetLink();
        } else if (error) {
            this.busdata = undefined;
            this.error = true;
            this.showdetails = true;
        }
    }

    getGreensheetLink() {

        var chassis_no;

        if(this.busdata.Name.length == 5){
        chassis_no = 'B0' + this.busdata.Name;
        }  
        else{
            chassis_no = 'B' + this.busdata.Name;
        } 

        getGreenSheetLink({ chassis_no: chassis_no })
            .then((data) => {
                if (data.isError) {
                    this.error = true;
                } else {
                    if (data.statusCode == 404) {
                        this.error = false;
                    } else {
                        this.error = false;
                        this.linkavailable = true;
                        this.pdfdata = JSON.parse(data.responsebody).url;
                    }
                }
                this.showdetails = true;
            })
            .catch((error) => {
                this.error = true
                this.showdetails = true;
            });
    }

    downloadecard() {
        window.open(this.pdfdata, '_blank');
    }
}