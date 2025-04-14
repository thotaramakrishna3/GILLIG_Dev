import { LightningElement, api, track } from 'lwc';

import {permissions}  from 'c/userPermissionsComponent';
import getPermissions from "@salesforce/apex/userAuthentication.getPermissions";

export default class StatusOperationsComponent extends LightningElement {

   @api ecardid;  
   @api buildstationid;
   @api islistview;
   @api isoperation;
   @api type; // Possible values [operations, shortage, discrepancy]
   @api discrepancytype; // Possible Values [Department, Buildstation] 
   @api permissionset; // Permissions to handle operations
   
  
   get setwidthverifybtnclass(){
    if(this.islistview){
        return 'slds-button_stretch btnwidth100 verifybutton';
    }
    else{
        return 'verifybutton';
    }
    }

   get setwidthclass(){
       if(this.islistview){
           return 'slds-button_stretch btnwidth100';
       }
       else{
           return '';
       }
   }

   get buttongroupwidth(){
       if(this.islistview){
           return 'slds-p-around_xxx-small slds-button_full-width';
       }
       else{
        return 'slds-p-around_xxx-small';
       }
   }
    
    @track statuswithin;
    @track buildstationdatalocal;
    @track hasdiscrepancyorshortage;
    showcomponent = false;
    @track setmarkasdonepermissions = false;

    connectedCallback(){
        this.statuswithin = this.status;
    }
    
    @api
    get buildstationdata() {
        return this.buildstationdatalocal;
    }
    set buildstationdata(value){
        this.buildstationdatalocal = value;

        if(this.buildstationdatalocal.has_discrepancy_logged || this.buildstationdatalocal.has_shortage_logged){
            this.hasdiscrepancyorshortage = true; //Checks whether issues or shortage exist
        }else if(this.buildstationdatalocal.has_discrepancy_logged == false || this.buildstationdatalocal.has_shortage_logged == false){
            this.hasdiscrepancyorshortage = false;
        }
    }
    
    @api
    get status() {
        return this.statuswithin;
    }
    set status(value){
        this.statuswithin = value;
    }

    get disablemarkasdone(){
        var ispicturevalidationrequired = false;
        var isopcheckrequired=false;
     
        if(this.isoperation){
            ispicturevalidationrequired = false;
        if(this.buildstationdatalocal.picture_validation_target_image_id != undefined){
            if(this.buildstationdatalocal.picture_validation_id == undefined){
                ispicturevalidationrequired = true;
            }
            else{
                ispicturevalidationrequired = false;
            } 
        }
        if(this.buildstationdatalocal.has_opcheck_pending){
            isopcheckrequired=true;
        }else{
            isopcheckrequired=false;
        }
        }
        else{
            ispicturevalidationrequired = false;
        }

        return ispicturevalidationrequired || isopcheckrequired; 
        
    }

    get isDiscOpen(){
        return (this.statuswithin == 'open' && this.type!='operations');  
    }

    get isOpen(){
        return (this.statuswithin == 'open' && this.type=='operations');  
    }

    get isresolved(){
        if (this.type=='operations'){
            return this.statuswithin == 'open';  
        }else{
            return this.statuswithin == 'resolve';  
        }
    } 

    get isverified(){
        return this.statuswithin == 'approve';
    }

    get isrejected(){
        return this.statuswithin == 'reject';
    }


    get markasdonepermissions(){
        if(this.type == 'operations'){
            if(this.permissionset.operation_open.write){
                var ispicturevalidationrequired = false;
                var isopcheckrequired=false;
                if(this.isoperation){
                   ispicturevalidationrequired = false;
                if(this.buildstationdatalocal.picture_validation_target_image_id != undefined){
                    if(this.buildstationdatalocal.picture_validation_id == undefined){
                        ispicturevalidationrequired = true;
                    }
                    else{
                        ispicturevalidationrequired = false;
                    } 
                }
                if(this.buildstationdatalocal.has_opcheck_pending){
                    isopcheckrequired=true;
                }else{
                    isopcheckrequired=false;
                }
                }
                else{
                    ispicturevalidationrequired = false;
                }
                return ispicturevalidationrequired || isopcheckrequired || this.hasdiscrepancyorshortage;
            } 
            else{
                return !this.permissionset.operation_open.write;
            }
        }
        else if(this.type == 'shortage'){
            if(this.permissionset.shortage_open.write){
                    return false;
            }
            else{
                return !this.permissionset.shortage_open.write;
            }
            
        }
        else if(this.type == 'discrepancy'){
            if(this.discrepancytype == 'Department'){
                if(this.permissionset.dept_discrepancy_open.write){
                        return false;
                }
                else{
                    return !this.permissionset.dept_discrepancy_open.write;
                }
            }
            else{
                if(this.permissionset.discrepancy_open.write){
                        return false;
                }
                else{
                    return !this.permissionset.discrepancy_open.write;
                }

            }
        }
        else{
            return true;
        }
       
    }

    get resolvepermissions(){
		if(!this.markasdonepermissions && this.type == 'operations'){
			return !this.permissionset.operation_resolved.write;
		}
		else if(this.type == 'shortage'){
			return !this.permissionset.shortage_resolved.write;
		}
		else if(this.type == 'discrepancy' && this.discrepancytype == 'Department'){
			return !this.permissionset.dept_discrepancy_resolved.write;
		}
		else if(this.type == 'discrepancy' && this.discrepancytype != 'Department'){// && this.discrepancytype != 'Customer Inspector'
			return !this.permissionset.discrepancy_resolved.write;
		}
        // else if(this.type == 'discrepancy' && this.discrepancytype != 'Department' && this.discrepancytype == 'Customer Inspector'){
		// 	return this.permissionset.discrepancy_resolved.write;
		// }
		else{
			return true;
		}
	}

    handlestatuschange(event){
        let buttonclicked = event.target.title;
        var status;
        if('Mark as done' == buttonclicked){
            status = 'resolve';
        }
        if('Verify' == buttonclicked){
            status = 'approve';      
      }
        if('Reject' == buttonclicked){
            status = 'reject';            
        }
        if('Cancel' == buttonclicked){
            status = 'resolve';
            this.statuswithin = 'resolve';
        }
        if('Cancel Verified' == buttonclicked){
            if(this.type!='operations'){
                status = 'resolve';
                this.statuswithin = 'resolve';
            }else{
                status = 'open';
                this.statuswithin = 'open';
            }
            
            
        }
        if('Cancel Rejected' == buttonclicked){
            if(this.type!='operations'){
                status = 'resolve';
                this.statuswithin = 'resolve';
            }else{
                status = 'open';
                this.statuswithin = 'open';
            }
            
        }
        const submitchange = new CustomEvent(
            "submitchange",
            {
                detail : {action:buttonclicked, status: status, ecardid: this.ecardid, buildstationid: this.buildstationid} 
                
            }
        );
        this.dispatchEvent(submitchange);
    }

    @api
    reloadComponent(){
        this.connectedCallback();
    }
   

}