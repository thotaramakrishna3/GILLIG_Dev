import { LightningElement,api,track,wire} from 'lwc';
import getReworkData from '@salesforce/apex/GetRejectList.getReworkDataEcard';
import getallUsers from "@salesforce/apex/UserListingController.getallUsers";
import getRecordDetails from '@salesforce/apex/GetRejectList.getUpdateReworkRecord';
import updateRework from '@salesforce/apex/GetRejectList.updateRework';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import {getmoddeddate,permissions}  from 'c/userPermissionsComponent';
import getReworkImageFiles from "@salesforce/apex/ecardOperationsController.getReworkImageFiles";
import getPermissions from "@salesforce/apex/userAuthentication.getPermissions";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OBJECT_NAME from '@salesforce/schema/Rework__c';
import PICKLIST_FIELD from '@salesforce/schema/Rework__c.Status__c';
import REASON_OBJECT_NAME from '@salesforce/schema/Reason_Code__c';
import getSupplyChaincode from "@salesforce/apex/ecardOperationsController.getReasoncode";
export default class ReworkListComponent extends LightningElement {
@api ecardid;
@track rejectItems =[];
@track error;
@api busname;
@api buschasisnumber;

@track userdata = new Map();
@api operation; 
@track filterlocal;
@track filterlabelfordisplay;
@track filterapplied = false;
@track showSpinner = true;
@track selecteddepartmentIdlocal;
@api departmentIdMap;

@track departmentlocal;
@api isload;
@api
get filter(){

  return this.filterlocal;
}
set filter(value){
  this.filterlocal = value;

  if(this.filterlocal != undefined){
      this.filterapplied = false;
      if(this.isload == true){
      this.loadReworkList();
      } 
  }
  
  
}
@api
get selecteddepartmentId() {
return this.selecteddepartmentIdlocal;
}
set selecteddepartmentId(value) {
this.selecteddepartmentIdlocal = value;

}
@api
get department() {
  return this.departmentlocal;
}
set department(value) {
  this.departmentlocal = value;
  if(this.isload==true){


  this.loadReworkList();
  }
}

async getuserdata(){
    this.showSpinner = true;
     await getallUsers()
    .then(data => {
        var dataa = JSON.parse(data.responsebody).data.user
        dataa.forEach(user => {
            this.userdata.set(user.employee_number,user.first_name+' '+user.last_name);
        });
        this.loadReworkList();
    })
    .catch(error => {
        console.error('Error retrieving user data: ', error);
    });
}
connectedCallback() {
    this.getPermissionsfromserver();
    this.getCode();
    if(this.isload == true){
        this.getuserdata();
    }
    }
    loadReworkList() {
        getReworkData({ecardId: this.ecardid, dept:this.department})
            .then(data => {      
                    if (data) {
                        this.rejectItems = data.map(item => {
                            let userId = item.Rejected_By_Employee_Id;
                            let userName = this.userdata.get(userId) || 'Unknown'; 
                
                            return { ...item, UserName: userName };
                        });
                
                       this.showSpinner = false;
                    } else if (results.error) {
                        console.error('Error loading data:', results.error);
                    }
            })
            .catch(error => {
                this.error = error;
                this.rejectItems = undefined;
        
               this.showSpinner = false;
            });
          }
          @track isImageLoading;
@track IsupdateDisable = true;
  @track attachmentsize=0;
  @track isrejectpresent;
  @track rejectedby = USER_ID;
  @track employeeId;
  @track ShowReworkModal = false;
    @track refreshRejectData;
    @track showtable = false;
    userId = USER_ID;
    @track fullName;

          closeModal(){
            this.ShowReworkModal = false;
            this.viewdetails = false;
        }
        showmessage(title, message, variant){
            const alertmessage = new ShowToastEvent({
                title : title,
                message : message,
                variant : variant
            });
            this.dispatchEvent(alertmessage);
        }
        @track updateRecord;
        @track isupdated = false;
        @track reworkimagelist;
        wiredPermissions;
        permissionset;
        getPermissionsfromserver(event) {
          getPermissions()
            .then((data) => {
              this.wiredPermissions = JSON.parse(data.responsebody);
              this.permissionset = permissions(this.wiredPermissions);
              this.error = undefined;
            })
            .catch((error) => {
              this.error = error;
              this.wiredPermissions = undefined;
            });
        }
        @track viewdetails = false;
        showreworkdetail(event){
            this.viewdetails = true;
            this.handleUpdate(event);
        }
        handleUpdate(event){ 
            this.IsupdateDisable = true;      
            var recid = event.target.dataset.id;
            getRecordDetails({ids:recid})
            .then(results => {
                for(let i=0;i<results.length;i++){
                this.updateRecord={
                    'Id':results[i].Id,
                    'Ecard_Id':results[i].Ecard_Id,
                    'Name' : results[i].Name,
                    'Department__c' : results[i].Department,
                    'Buildstation__c' : results[i].Buildstation,
                    'Bus_Part_Number__c' : results[i].Bus_Part_Number,
                    'Rework_Description__c' : results[i].Reject_Description,
                    'Quantity_Reworked__c' : results[i].Quantity_Rejected,
                    'Reason_Code__c': results[i].Reason_Code,
                    'createddate':getmoddeddate(results[i].CreatedDate),
                    'Reworked_by':this.userdata.get(results[i].Rejected_By_Employee_Id),
                    'Reworked_to_Part':results[i].Rework_Bus_Part_No,
                    'Remarks__c' : results[i].Remark,
                    'Status__c' : results[i].Status,
                    'Supply_Chain__c' : results[i].Supply_Chain
                }
            }
            this.getFilesfromserver(event);
            this.isupdated = this.permissionset.rework_update.write;
            if(this.viewdetails){
                this.isupdated = false;
            }
            this.ShowReworkModal = true;
            }).catch(error => {
                this.error = error;
                this.showmessage('Data fetch failed.', 'Something unexpected occured. Please contact your Administrator.', 'error');
            })
        }
        updatenewrework(event){
            this.IsupdateDisable = false;
            var targetvalue = event.target.value;
            var targetname = event.target.name;
            if(targetname == 'quantity_reworked'){
                this.updateRecord.Quantity_Reworked__c = targetvalue;
            }else if(targetname == 'rework_part'){
                this.updateRecord.Reworked_to_Part = targetvalue;
            }else if(targetname == 'remarks'){
                this.updateRecord.Remarks__c = targetvalue;
            }
            else if(targetname == 'status' ){
                this.updateRecord.Status__c = targetvalue;
            }else if(targetname == 'supply_chain' ){
                this.updateRecord.Supply_Chain__c = targetvalue;
            }
        }
        updatereworktoserver(){
            this.updateRecord.LastModifiedEmployeeId = this.employeeId;
            const allValid = [...this.template.querySelectorAll('.partshortagevalidationrework')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid && this.updateRecord.Quantity_Reworked__c != undefined) {
            updateRework({remark:this.updateRecord.Remarks__c,reworkpart:this.updateRecord.Reworked_to_Part,recid:this.updateRecord.Id,quantity:this.updateRecord.Quantity_Reworked__c,empId:this.employeeId,status:this.updateRecord.Status__c,supplychain:this.updateRecord.Supply_Chain__c})
            .then(data=>{
                this.showmessage('Updated Sucessfully.','Rework Record updated successfully.','success');
                this.closeModal();
                this.loadReworkList();
            }).catch(error => {
                this.error = error;
                this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
            });
        }else{
            this.showmessage('Please fill all required fields.','Please fill required and update all blank form entries.','warning');
        }
        }
       async getFilesfromserver(event){
        this.isImageLoading = true;
                    var requestbody={
                         "id" : null,
                         "sfid":this.updateRecord.Id,
                    }
               await getReworkImageFiles({req:requestbody})
                .then(data => {
                    if(data.isError){
                        const alertmessage = new ShowToastEvent({
                        title : 'Failed to fetch the Attachments.',
                        message : 'Something unexpected occured. Please contact your Administrator',
                        variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    this.isImageLoading = false;
                    this.isrejectpresent = false;
                 }
                else{
                    var attachments = JSON.parse(data.responsebody).data.ReworkAttachment;
                    this.attachmentsize = attachments.length;
                    var attachmentlist = [];
                    for(var i in attachments){
                        var updateBy = attachments[i].updatedby_id.first_name +' '+ attachments[i].updatedby_id.last_name;
                    var datetime = attachments[i].created_date;
                        var attachmentmodded = {
                            "Id" : attachments[i].ecard_reject_log_attachment_id,
                            "url" : attachments[i].s3_image_uri,
                            "name" : '',
                             "Updatedbyandtimestamp":updateBy +', '+ getmoddeddate(datetime)
                        };
                        attachmentlist.push(attachmentmodded);
                    }
                    this.reworkimagelist = attachmentlist;
                    this.isImageLoading = false;
                    this.isrejectpresent = true;
                }
        
                }).catch(error => {
                this.error = error;
                const alertmessage = new ShowToastEvent({
                    title : 'Failed to fetch the Attachments.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                    variant : 'error'
                });
                this.dispatchEvent(alertmessage);
                this.isImageLoading = false;
                this.isrejectpresent = false;
            });
        }
    @track picklistOptions = [];
    
    @wire(getObjectInfo, { objectApiName: OBJECT_NAME })
    objectInfo;
 
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: PICKLIST_FIELD })
    picklistValues({ error, data }) {
        if (data) {
            this.picklistOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if(error){
            console.log('data is>>>'+error);
        }
    }
    @track supplyChainPicklistOptions = [];
      @track reworkRecordTypeId;
      @wire(getObjectInfo, { objectApiName: REASON_OBJECT_NAME })
      reworkObjectInfo({ data, error }) {
        if (data) {
            // Find the RecordTypeId for the "Reject" record type
            const recordTypes = data.recordTypeInfos;
            this.reworkRecordTypeId = Object.keys(recordTypes).find(
                (recordTypeId) => recordTypes[recordTypeId].name === 'Rework'
            );
        } else if (error) {
            console.error('Error fetching reject object info:', error);
        }
    }
    getCode(){
        getSupplyChaincode()
        .then((result) => {
            this.reasoncode = result;
            for(let i=0;i<=result.length;i++){
               if(result[i].RecordType.Name == 'Rework'){
                    this.supplyChainPicklistOptions.push({
                        "label":result[i].Reason_Code__c,
                        "value":result[i].Reason_Code__c
                    });           
                }
           }
        })
        .catch((error) => {
        });
        
    }
}