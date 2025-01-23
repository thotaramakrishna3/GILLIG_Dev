import { LightningElement, track, api } from 'lwc';

export default class BuildstationListiconComponent extends LightningElement {

    //@api buildstationlist;

    @track displaylist;
    @track hasbuildstation;
    @track listcountgreater;
    @track bslist;
    @track showlist;
    @track additionalbs;

    @api
    get buildstationlist(){
        return this.displaylist;
    }
    set buildstationlist(value){
        this.displaylist = value;
        if(this.displaylist != undefined && this.displaylist != null){
            if(this.displaylist.length > 0){
                this.hasbuildstation = true;
                this.singlebs = this.displaylist[0];
                if(this.displaylist.length == 1){                   
                    this.listcountgreater = false;
                }
                else{
                    this.listcountgreater = true;
                    this.count = this.displaylist.length - 1; 
                    this.additionalbs = `+ ${this.count}`;
                }
            }
            else{
                this.hasbuildstation = false;
            }
        }
        else{
            this.hasbuildstation = false;
        }
    }
    showbslist(){
        this.bslist = [];
        for(var item in this.displaylist){
            this.bslist.push(this.displaylist[item]);
        }
        this.showlist = true;
    }
    hidebslist(){
        this.showlist = false;
    }

}