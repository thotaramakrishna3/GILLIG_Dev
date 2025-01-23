import { LightningElement,track,wire,api } from 'lwc';
import getRework from '@salesforce/apex/GetRejectList.getReworkData';
import getRecordDetails from '@salesforce/apex/GetRejectList.getUpdateReworkRecord';
import updateRework from '@salesforce/apex/GetRejectList.updateRework';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import {refreshApex} from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import {getmoddeddate,permissions}  from 'c/userPermissionsComponent';
import getReworkImageFiles from "@salesforce/apex/ecardOperationsController.getReworkImageFiles";
import getallUsers from "@salesforce/apex/UserListingController.getallUsers";
import getPermissions from "@salesforce/apex/userAuthentication.getPermissions";
import getDepartmentdata from "@salesforce/apex/masterDataController.getDepartmentdata";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OBJECT_NAME from '@salesforce/schema/Rework__c';
import PICKLIST_FIELD from '@salesforce/schema/Rework__c.Status__c';
import REASON_OBJECT_NAME from '@salesforce/schema/Reason_Code__c';
import getSupplyChaincode from "@salesforce/apex/ecardOperationsController.getReasoncode";
const FIELDS = [
    'User.FirstName',
    'User.LastName',
    'User.EmployeeNumber'
];
export default class ReworkDbComponent extends LightningElement {
    @track filteredreworks=[];
    @track attachmentsize=0;
    @track isrejectpresent;
    @track rejectimagelist = [];
    @track rejectedby = USER_ID;
    @track nosearchdata=[];
    @track employeeId;
    @track customernamechasislist = [];
    @track rowNumberOffset = 1;
    @track refreshKey = 0;
    @track ShowReworkModal = false;
    @track refreshReworkData;
    @track isImageLoading;
    @track showtable = false;
    @track IsupdateDisable = true;
    userId = USER_ID;
    @track fullName;
    @track showSpinner;
    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    user({ error, data }) {
        if (error) {
            console.error('Error retrieving user data: ', error);
        } else if (data) {
            this.fullName = `${data.fields.FirstName.value} ${data.fields.LastName.value}`;
            this.employeeId = data.fields.EmployeeNumber.value;
        }
    }
    @track isupdated = false;
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
    @track userdata = new Map();
connectedCallback(){
    this.getPermissionsfromserver();
    this.getuserdata();
    this.setdepartmentidmap();
    this.getCode();
}
    async getuserdata(){
        this.showSpinner = true;
         await getallUsers()
        .then(data => {
            var dataa = JSON.parse(data.responsebody).data.user
            dataa.forEach(user => {
                this.userdata.set(user.employee_number,user.first_name+' '+user.last_name);
            });
        })
        .catch(error => {
            console.error('Error retrieving user data: ', error);
        });
    }
    @wire(getRework)
    loaddata(results){
        setTimeout(() => {       
            this.refreshReworkData = results;
            if (results.data) {
                // Create a copy of the data with added UserName property
                this.filteredreworks = results.data.map(item => {
                    let userId = item.Rejected_By_Employee_Id;
                    let userName = this.userdata.get(userId) || 'Unknown'; // Provide a fallback value if userName is not found
        
                    // Create a new object with all properties of item and add UserName
                    return { ...item, UserName: userName };
                });
        
                // Copy filteredreworks to nosearchdata
                this.nosearchdata = [...this.filteredreworks];
                this.showSpinner = false;
                this.showtable = true;
            } else if (results.error) {
                // Proper error handling
                console.error('Error loading data:', results.error);
            }
        }, 3000);
    }
    handlePaginatorChange(event) {        
        this.filteredreworks = event.detail;
        if (this.filteredreworks[0] != undefined && !isNaN(this.filteredreworks[0])) {    
            this.rowNumberOffset = this.filteredreworks[0].rowNumber - 1;           
        }
    }
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
    @track viewdetails = false;
    showreworkdetail(event){
        this.viewdetails = true;
        this.handleUpdate(event);
    }
    @track searchValue;
    handleSearchChange(event) {
      this.searchValue = event.detail;
  }
    @track updateRecord;
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
        this.isupdated = this.permissionset.reject_update.write;
        if(this.viewdetails){
            this.isupdated = false;
        }
        this.ShowReworkModal = true;
        }).catch(error => {
            this.error = error;
            this.showmessage('Data fetch failed.', 'Something unexpected occured. Please contact your Administrator.', 'error');
        })
    }
    @track departmentIdMap = [];
    setdepartmentidmap() {
        getDepartmentdata({ authdata: '' })
          .then(result => {
            for (var dept in result.departmentPickList) {
              var deprtmentopt = result.departmentPickList[dept];
              if (deprtmentopt.value != 'None') {
                this.departmentIdMap.push(deprtmentopt);
              }
            }
          })
          .catch(error => {
            const alertmessage = new ShowToastEvent({
              title: 'Department data fetch failed.',
              message: 'Something unexpected occured. Please contact your Administrator',
              variant: 'error'
            });
            this.dispatchEvent(alertmessage);
          });
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
            this.showSpinner = true;
          return refreshApex(this.refreshReworkData);
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
                this.rejectimagelist = attachmentlist;
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
    loaddatatable(){
        return refreshApex(this.refreshReworkData);
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