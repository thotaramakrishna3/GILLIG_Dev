import { LightningElement, track, api } from 'lwc';
import sampleimage from "@salesforce/resourceUrl/PictureValidationSample";
import noDatadessert from "@salesforce/resourceUrl/nodatadessert";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import pubsub from 'c/pubsub' ;
import {getmoddeddate}  from 'c/userPermissionsComponent';
import uploadTargetPicture from "@salesforce/apex/ecardOperationsController.uploadTargetPicture";
import uploadSourcePicture from "@salesforce/apex/ecardOperationsController.uploadSourcePicture";
import deleteTargetPicture from "@salesforce/apex/ecardOperationsController.deleteTargetPicture";
import getTargetImage from "@salesforce/apex/ecardOperationsController.getTargetImage";
import getTargetandActualImage from "@salesforce/apex/ecardOperationsController.getTargetandActualImage";
import getbuildstationopcheckDetails  from "@salesforce/apex/ecardOperationsController.getbuildstationopcheckDetails";
import getbuildstationPartDetails from "@salesforce/apex/ecardOperationsController.getbuildstationPartDetails";
import getbuildstationbm35Details from "@salesforce/apex/ecardOperationsController.getbuildstationbm35Details";
import getbuildstationpcoDetails  from "@salesforce/apex/ecardOperationsController.getbuildstationpcoDetails";
import updateopchecks from "@salesforce/apex/ecardOperationsController.updateopchecks";

export default class ShowValidationiconsComponent extends LightningElement {
    opckdetails=[];
    nodatadessert = noDatadessert;     // No Data Image(Static Resource).
    apppermissions;
    clicks=0;
    @track has_op_check;	
    @track has_operation_check;
    @track registerevent=false;

    @api ecardid;
    @api busname;
    @api buschasisnumber;
    @api departmentid;
    @api departmentIdMap;
    @api department;
    @api selecteddepartmentid;

    @api permissionset;
    @api
    get validations() {
        return this.validationslocal;
    }
    set validations(value){
        var validations = JSON.parse(JSON.stringify(value));
        this.validationslocal = validations;
        this.has8410 = this.validationslocal.has8410;
        this.has_bm35 = this.validationslocal.has_bm35;
        this.has_pco = this.validationslocal.has_pco;
        this.has_op_check = this.validationslocal.has_op_check;	
        this.has_operation_check = this.validationslocal.has_operation_check;
        this.hasdiscrepancy = this.validationslocal.hasdiscrepancy;
        this.haspicvalidation = this.validationslocal.validation_pic_required;
        
    }

    @api
    get buildstationdetails() {
        return this.buildstationdetailslocal;
    }
    set buildstationdetails(value){
        var buildstation = JSON.parse(JSON.stringify(value));
        this.buildstationdetailslocal = buildstation;
        this.buildstationdata = this.buildstationdetailslocal;
        this.buildstationcode = this.buildstationdetailslocal.buildstation_code;
        this.buildstationstatus=this.buildstationdetailslocal.status;

    }

    //to show icons respective to list
    @track validationslocal;
    @track buildstationdetailslocal;
    @track buildstationstatus;
    @track has8410;
    @track has_pco;
    @track has_bm35;
    @track hasdiscrepancy;
    @track haspicvalidation;
    @track variabletodebug1;
    @track variabletodebug2;
    @track selectedoperation;

    // For Picture validation
    @track showpicvalmodal;
    
    @track encodedimage;

    @track buildstationid;

    // For BuildStation Validation
    @track showBuildStationmodal;
    @track buildstationcode;

    // For PCO Validation
    @track showPCOmodal;

    // For BM35 Validation
    @track showBM35modal;

    // For OP-CK Validation
    @track showopckmodal

    // For Discrepancy Validation
    @track showdiscrepancymodal;

    @track targetimage = undefined;
    @track currentstep;
    @track uploadedimage;
    @track buildstationdata;
    @track istargetimagepresent = false;
    @track isactualimagepresent = false;
    @track actualimagepresentinserver =false;
    @track loggedinuserqc = true;

    @track showSpinner=false;
    @track applytarget = false;

    @track buildstationpartslist = [];
    @track buildstationbm35details=[];
    @track buildstationpcodetails=[];
    @track currentvalidation;

    @track disableactualimagebutton;
    @track targetimageupdatedby;
    @track actualtimageupdatedby;
    @track targetimageupdatedtime;
    @track actualtimageupdatedtime;

    get disableactualimageuploadbutton(){
        return this.buildstationdata.picture_validation_target_image_id == null;
    }

    get isbuildstationpartlistempty(){
        return this.buildstationpartslist.length == 0 ;
    }

    get isbuildstationbm35listempty(){
        return this.buildstationbm35details.length == 0 ;
    }

    get isbuildstationpcolistempty(){
        return this.buildstationpcodetails.length == 0 ;
    }

    get acceptedFormats() {
        return ['.png','.jpg','.jpeg'];
    }

    get stepone(){
        return this.currentstep == 'one';
    }

    get steptwo(){
        return this.currentstep == 'two';
    }

    get picvalidationoptional(){
        if(this.buildstationstatus=='approve' && this.buildstationdata.picture_validation_id == undefined){
            return true;
        }
        if(this.buildstationdata.picture_validation_target_image_id == undefined){
           // if(this.buildstationdata.picture_validation_id == undefined){  
            if(this.buildstationdata.picture_validation_id == undefined 
                || (this.buildstationdata.picture_validation_id != undefined && this.buildstationdata.source_image_uri == undefined)){  
                return true;
            }
        }
        return false;
    }
    get disableuserinput(){
        return !this.permissionset.operation_check.write;
      }

    get picvalidationrequired(){
        if(this.buildstationstatus=='approve'){
            return false;
        }
        if(this.buildstationdata.picture_validation_target_image_id != undefined){
            if(this.buildstationdata.picture_validation_id == undefined || this.buildstationdata.source_image_uri == undefined){
                return true;
            }
            else{
                return false;
            } 
        }
        return false;
    }

    get imageuploaded(){
        if(this.buildstationdata.picture_validation_id != undefined && this.buildstationdata.source_image_uri != undefined){
                return true;
        }
        else{
            return false;
        } 
    }

    get enableuploadbutton(){
        if(this.targetchanged || this.actualchanged){
            return false;
        }
        else{
            return true;
        }
    }

    get enabledeletebutton(){
        if(this.isactualimagepresent && this.buildstationdata.status == 'approve'){
            return false;
        }
        else{
            if(this.isactualimagepresent){
                return true;
            }
            else{
                return this.currentstep == 'two';
            }
        }
        
    }
    get istargetdelete(){
        return this.istargetimagepresent && this.permissionset.target_image_delete.write;
    }

    get disablerequired() {
        return !this.permissionset.operation_check.write;
    }
    
    // Handle Picture Validation.
    handlevalidation(event){
        let clickedAction = event.target.title;
        this.currentvalidation=event.target.title;
       
        if(clickedAction == 'Picture Validation'){
            this.currentstep = 'one';
            if(this.buildstationdata.ecard_operation_log_id != undefined){
                if(this.buildstationdata.picture_validation_target_image_id != undefined){
                    this.istargetimagepresent = true;
                    this.getactualimagefromserver();
                }
                else{
                    if(this.buildstationdata.picture_validation_id !=undefined){
                        this.istargetimagepresent = false;
                        this.getactualimagefromserver();
                    }
                    else{
                        this.istargetimagepresent = false;
                        this.showpicvalmodal = true;
                    }
                    
                }
            }
            else{
                if(this.buildstationdata.picture_validation_target_image_id != undefined){
                    this.istargetimagepresent = true;
                     this.gettargetimagefromServer();
                }
                else{
                    this.istargetimagepresent = false; 
                    this.showpicvalmodal = true;
                }
                
            }                          
        }
        if(clickedAction == 'BuildStation'){
            this.getbuildstationdetails();
        }
        if(clickedAction == 'PCO'){
            this.getpcodetails();
        }
        if(clickedAction == 'BM35'){
            this.getbm35details();
        }
        if(clickedAction == 'Discrepancy'){
            this.showdiscrepancymodal = true;
        }
        if(clickedAction == 'JOBS'){
            this.getopcheckdeatils();
        }

    }

    // Hide Picture Validation modal.
    cancelpicturevalidation(event){
        if(this.actualchanged){
            this.isactualimagepresent=false;
            this.actualchanged=false;
        }
        if(this.targetchanged){
            this.targetchanged=false;
            this.istargetimagepresent=false;
        }
        this.showpicvalmodal = false;
    }

    // To get the target image from Server for Picture validation.
    gettargetimagefromServer(event){
        // to get target image from server
        var ecardbuildstationId = {
            ecard_id :  this.buildstationdata.ecard_id,
            buildstation_id : this.buildstationdata.buildstation_id
        };
        
        getTargetImage({ecardbuildstationId:JSON.stringify(ecardbuildstationId)})
              .then(data => {
                  if(data.isError){
                      const alertmessage = new ShowToastEvent({
                          title : 'Sorry we could not fetch the target image.',
                          message : 'Something unexpected occured. Please contact your Administrator',
                         variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                  }
                  else{
                    var targetimagedata = JSON.parse(data.responsebody).data;
                    this.targetimage =  targetimagedata.target_picture_validation.target_image_uri;
                    this.uploadedtargetimage =  targetimagedata.target_picture_validation.target_image_uri;
                    this.targetimageupdatedby = targetimagedata.target_picture_validation.createdby_id.first_name +' '+targetimagedata.target_picture_validation.createdby_id.last_name;
                    this.targetimageupdatedtime = getmoddeddate(targetimagedata.target_picture_validation.created_date);
                    console.log('target image url'+this.targetimage);
                    this.showSpinner = false;
                    this.showpicvalmodal = true;
                    
                  }
                    
              }).catch(error => {
              this.error = error;
               const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not complete the operation.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                   variant : 'error'
              });
              this.dispatchEvent(alertmessage);
              this.showSpinner = false;
              });
             
    }

    // To get the target/actual image from server for Picture validation.
    getactualimagefromserver(event){
        var operationlogid = this.buildstationdata.ecard_operation_log_id;
        getTargetandActualImage({operationlogid:operationlogid})
              .then(data => {
                  debugger
                  if(data.isError){
                      const alertmessage = new ShowToastEvent({
                          title : 'Sorry we could not fetch the target image.',
                          message : 'Something unexpected occured. Please contact your Administrator',
                         variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                  }
                  else{
                    var imagedata = JSON.parse(data.responsebody).data;
                    if(imagedata.target_picture_validation == null){ //&& imagedata == undefined
                        this.gettargetimagefromServer();
                    }
                    else{
                        if(imagedata.target_picture_validation.validation_image_uri == null){
                            this.istargetimagepresent = false;
                        }
                        else{
                            this.targetimage =  imagedata.target_picture_validation.validation_image_uri;
                            this.uploadedtargetimage=imagedata.target_picture_validation.validation_image_uri;
                            this.targetimageupdatedby = imagedata.target_picture_validation.validation_image_createdby_id.first_name +' '+imagedata.target_picture_validation.validation_image_createdby_id.last_name;
                            this.targetimageupdatedtime = getmoddeddate(imagedata.target_picture_validation.validation_image_createddate);
                            if(imagedata.target_picture_validation.source_image_uri!= null){
                            this.actualtimageupdatedby = imagedata.target_picture_validation.source_image_createdby_id.first_name +' '+imagedata.target_picture_validation.source_image_createdby_id.last_name;
                            this.actualtimageupdatedtime = getmoddeddate(imagedata.target_picture_validation.source_image_createddate);
                            }
                        }
                        if(imagedata.target_picture_validation.source_image_uri != undefined){
                            this.currentstep = 'two';
                            this.uploadedimage = imagedata.target_picture_validation.source_image_uri; 
                            console.log('actual image url'+this.uploadedimage);
                            this.isactualimagepresent = true;
                            this.actualimagepresentinserver=true;
                            this.showpicvalmodal = true;
                        }
                        else{
                            this.showpicvalmodal = true;
                        }
                        this.showSpinner = false;
                    }
                    
                  }
                    
              }).catch(error => {
              this.error = error;
               const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not complete the operation.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                   variant : 'error'
              });
              this.dispatchEvent(alertmessage);
              this.showSpinner = false;
              });
    }

    actualchanged=false;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    @track targetchanged=false; 
    targetfileName;
    targetfilesUploaded =[];
    targetfile;
    targetfileReader;
    targetfileContents;
    uploadedtargetimage;
    targetcontent;

    // getting file from the local machine into the file loader. 
    handletargetchange(event){
        this.targetfilesUploaded = event.target.files;
        this.targetfileName = event.target.files[0].name;
        this.targetfile = this.targetfilesUploaded[0];
        this.targetfileReader= new FileReader();
        this.targetfileReader.onloadend = (() => {
            this.targetfileContents = this.targetfileReader.result;
            this.uploadedtargetimage = this.targetfileReader.result;
            let base64 = 'base64,';
            this.targetcontent = this.targetfileContents.indexOf(base64) + base64.length;
            this.targetfileContents = this.targetfileContents.substring(this.targetcontent);
            this.istargetimagepresent=true;
        });
        this.targetfileReader.readAsDataURL(this.targetfile);
        this.targetchanged = true;
        this.applytarget =true;
    }
    handleFilesChange(event) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.file = this.filesUploaded[0];
            // create a FileReader object 
            this.fileReader= new FileReader();
            // set onload function of FileReader object  
            this.fileReader.onloadend = (() => {
                this.fileContents = this.fileReader.result;
                this.uploadedimage = this.fileReader.result;
                let base64 = 'base64,';
                this.content = this.fileContents.indexOf(base64) + base64.length;
                this.fileContents = this.fileContents.substring(this.content);
                this.isactualimagepresent=true;
            }); 
            this.fileReader.readAsDataURL(this.file);
            this.actualchanged=true;
    }

    // To move back to step one which is the intial view where we upload actual image.
    goback(event){
        this.isactualimagepresent = false;
        this.actualchanged=false;
        if(this.actualimagepresentinserver){
            const alertmessage = new ShowToastEvent({
            title : 'Actual image can only be replaced.',
            message : 'Actual image can only be replaced, Please select a replacement image',
            variant : 'warning'
            });
            this.dispatchEvent(alertmessage);
        }
        this.currentstep = 'one';
    }

    // Upload image to server and apply to fleet.
    uploadImage(event){
        if(this.actualchanged){
                this.uploadactualpicturetoserver();
        }
        if(this.targetchanged){
            this.uploadtargetpicturetoserver();
        } 
    }
    @track processedDetails = [];

processInstructionsWithIcons() {
  // Ensure opckdetails is defined and an array
  if (!this.opckdetails || !Array.isArray(this.opckdetails)) {
    console.error('opckdetails is not defined or is not an array');
    this.processedDetails = []; // Reset to an empty array to avoid further issues
    return;
  }

  this.processedDetails = this.opckdetails.map(opck => {
    // Ensure workinstructions exists and is an array
    const processedInstructions = (opck.workinstructions || []).map(instruction => {
      if (instruction.work_instruction_url) {
        // Add icon based on the URL extension
        return {
          ...instruction,
          icon: this.getIconByExtension(instruction.work_instruction_url),
        };
      } else {
        return instruction;
      }
    });

    return {
      ...opck,
      workinstructions: processedInstructions,
    };
  });
}
    getIconByExtension(fileUrl) {
      if (!fileUrl) return 'doctype:unknown';
  
      const extension = fileUrl.split('.').pop().toLowerCase().split('?').shift(); // Extract file extension
  
      const extensionToIconMap = {
        pdf: 'doctype:pdf',
        doc: 'doctype:word',
        docx: 'doctype:word',
        txt: 'doctype:txt',
        xls: 'doctype:excel',
        xlsx: 'doctype:excel',
        ppt: 'doctype:ppt',
        pptx: 'doctype:ppt',
        jpg: 'doctype:image',
        jpeg: 'doctype:image',
        png: 'doctype:image',
        zip: 'doctype:zip',
        csv: 'doctype:csv',
        html: 'doctype:html',  
        json: 'doctype:json',  
        xml: 'doctype:xml',    
        mp3: 'doctype:audio',  
        mp4: 'doctype:video',  
        mov: 'doctype:video',  
        wav: 'doctype:audio',   
        rtf: 'doctype:txt',   
        psd: 'doctype:image',  
        ai: 'doctype:image',   
        ind: 'doctype:image',
      };
  
      return extensionToIconMap[extension] || 'doctype:link'; // Default to 'file' icon
    }
    
    // Upload actual image to server.
    uploadactualpicturetoserver(event){ 
        var actualpicturerequest = {
            "picture_validation_target_image_id" : this.buildstationdata.picture_validation_target_image_id,
            "department_id" : this.buildstationdata.department_id,
            "buildstation_id" : this.buildstationdata.buildstation_id,
            "ecard_id" : this.buildstationdata.ecard_id,
            "validation_image_encoded_string" : this.fileContents
        };
        this.showSpinner = true;
        uploadSourcePicture({requestbody:JSON.stringify(actualpicturerequest)})
              .then(data => {
                  if(data.isError){
                      const alertmessage = new ShowToastEvent({
                          title : 'Sorry we could not complete the operation.',
                          message : 'Something unexpected occured. Please contact your Administrator',
                         variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                  }
                  else{
                      const alertmessage = new ShowToastEvent({
                          title : 'Upload successful',
                          message : 'Image uploaded successfully.',
                         variant : 'success'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                    this.refreshtheoperationlist();
                    this.showpicvalmodal = false; 
                  }
                    
              }).catch(error => {
              this.error = error;
               const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not complete the operation.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                   variant : 'error'
              });
              this.dispatchEvent(alertmessage);
              this.showSpinner = false;
              });
              this.actualchanged = false; 
    }

    // Applying to fleet.
    uploadtargetpicturetoserver(event){
        var targetpicturerequest = {
            "buildstation_id" : this.buildstationdata.buildstation_id,
            "source_ecard_id" : this.buildstationdata.ecard_id,
            "validation_image_encoded_string" : this.targetfileContents
        };
        this.showSpinner = true;
        uploadTargetPicture({requestbody:JSON.stringify(targetpicturerequest)})
              .then(data => {
                  if(data.isError){
                      const alertmessage = new ShowToastEvent({
                          title : 'Sorry we could not complete the operation.',
                          message : 'Something unexpected occured. Please contact your Administrator',
                         variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                  }
                  else{
                      const alertmessage = new ShowToastEvent({
                          title : 'Upload successful',
                          message : 'Image applied to fleet successfully.',
                         variant : 'success'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                    this.refreshtheoperationlist();
                    this.showpicvalmodal = false; 
                  }
                    
              }).catch(error => {
              this.error = error;
               const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not complete the operation.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                   variant : 'error'
              });
              this.dispatchEvent(alertmessage);
              this.showSpinner = false;
              });
              this.targetchanged = false; 
    }

    // To check the option of apply to fleet applied or not.
    applytocompletefleet(event){
        this.applytarget = event.target.checked;
    }

    // To refresh the operation list of Parent component.
    refreshtheoperationlist(event){
        const modifyevent = new CustomEvent(
            "updateoperationlist",
            {
                detail : {value : 'Refresh the component'} 
                
            }
        );
        this.dispatchEvent(modifyevent);
    }

    @track showSpinnerforbuildstation = false;
    // To get the buildstation list of the selected operation.
    getbuildstationdetails(event){
         // to get part details from server
         this.showSpinnerforbuildstation = true;
         var ecardbuildstationId = {
            ecard_id :  this.buildstationdata.ecard_id,
            build_station_id : this.buildstationdata.buildstation_id
        };
        getbuildstationPartDetails({ecardbuildstationId:JSON.stringify(ecardbuildstationId)})
              .then(data => {
                  if(data.isError){
                      const alertmessage = new ShowToastEvent({
                          title : 'Sorry we could not fetch Parts details.',
                          message : 'Something unexpected occured. Please contact your Administrator',
                         variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    
                  }
                  else{
                    var buildstationpartsdata = JSON.parse(data.responsebody).data.bus_part_detail;
                    this.buildstationpartslist = this.getmodifiedlist(buildstationpartsdata);
                    this.showSpinnerforbuildstation = false;
                  }
                    
              }).catch(error => {
              this.error = error;
               const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not complete the operation.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                   variant : 'error'
              });
              this.dispatchEvent(alertmessage);
             
              });

        this.showBuildStationmodal = true;
    }
    // To get the buildstation BM35 detail list of the selected operation.
    getbm35details(event){
        // to get BM35 details from server
        this.showSpinner = true;
        var ecardbuildstationId = {
           ecard_id :  this.buildstationdata.ecard_id,
           build_station_id : this.buildstationdata.buildstation_id
       };
       getbuildstationbm35Details({ecardbuildstationId:JSON.stringify(ecardbuildstationId)})
             .then(data => {
                 if(data.isError){
                     const alertmessage = new ShowToastEvent({
                         title : 'Sorry we could not fetch BM35 details.',
                         message : 'Something unexpected occured. Please contact your Administrator',
                        variant : 'error'
                   });
                   this.dispatchEvent(alertmessage);
                   
                 }
                 else{
                   var bm35data = JSON.parse(data.responsebody).data.buildstations_mapping_adon;
                   this.buildstationbm35details = this.getmodifiedlist(bm35data);
                   this.showSpinner = false;
                 }
                   
             }).catch(error => {
             this.error = error;
              const alertmessage = new ShowToastEvent({
                   title : 'Sorry we could not fetch BM35 details.',
                   message : 'Something unexpected occured. Please contact your Administrator',
                  variant : 'error'
             });
             this.dispatchEvent(alertmessage);
            
             });
       this.showBM35modal = true;
   }

   // To get the buildstation PCO detail list of the selected operation.
   getpcodetails(event){
        // to get PCO details from server
        this.showSpinner = true;
        var ecardbuildstationId = {
        ecard_id :  this.buildstationdata.ecard_id,
        build_station_id : this.buildstationdata.buildstation_id
        };
        getbuildstationpcoDetails({ecardbuildstationId:JSON.stringify(ecardbuildstationId)})
                .then(data => {
                    if(data.isError){
                        const alertmessage = new ShowToastEvent({
                            title : 'Sorry we could not fetch PCO details.',
                            message : 'Something unexpected occured. Please contact your Administrator',
                            variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    
                    }
                    else{
                    var pcodata = JSON.parse(data.responsebody).data.buildstations_mapping_adon;
                    this.buildstationpcodetails = this.getmodifiedlist(pcodata);
                    this.showSpinner = false;
                    }
                    
                }).catch(error => {
                this.error = error;
                const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not fetch PCO details.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                    variant : 'error'
                });
                this.dispatchEvent(alertmessage);
                
                });
        this.showPCOmodal = true;
    }

    cancelbuildstationmodal(event){
        this.showBuildStationmodal = false;
    }

    cancelPCOmodal(event){
        this.showPCOmodal = false;
    }

    cancelBM35modal(event){
        this.showBM35modal = false;
    }

    cancelopckmodal(event){
        this.showopckmodal = false;
    }

    canceldiscrepancymodal(event){
        this.showdiscrepancymodal = false;
    }
    
    rotate(){
        this.clicks=this.clicks+1;
        switch(this.clicks%4){
            case 1:
                this.template.querySelector('.targetImage').classList.add('rotate90');
                this.template.querySelector('.targetImage').classList.remove('rotate180');  
                this.template.querySelector('.targetImage').classList.remove('rotate270'); 
                break;
            case 2:
                this.template.querySelector('.targetImage').classList.remove('rotate90');
                this.template.querySelector('.targetImage').classList.add('rotate180');  
                this.template.querySelector('.targetImage').classList.remove('rotate270'); 
                break;
            case 2:
                this.template.querySelector('.targetImage').classList.remove('rotate90');
                this.template.querySelector('.targetImage').classList.remove('rotate180');  
                this.template.querySelector('.targetImage').classList.add('rotate270'); 
                break;    
            default:
                this.template.querySelector('.targetImage').classList.remove('rotate90');
                this.template.querySelector('.targetImage').classList.remove('rotate180');  
                this.template.querySelector('.targetImage').classList.remove('rotate270'); 
                break;
        }
    }

    getopcheckdeatils(event){	
        // to get Operations Check details from server	
        this.showSpinner = true;	
        var ecardbuildstationId = {	
            ecard_id :  this.buildstationdata.ecard_id,	
            build_station_id : this.buildstationdata.buildstation_id	
        };	
        getbuildstationopcheckDetails({ecardbuildstationId:JSON.stringify(ecardbuildstationId)})	
                .then(data => {	
                    if(data.isError){	
                        const alertmessage = new ShowToastEvent({	
                            title : 'Sorry we could not fetch Operations Check details.',	
                            message : 'Something unexpected occured. Please contact your Administrator',	
                            variant : 'error'	
                    });	
                    this.dispatchEvent(alertmessage);	
                    	
                    }	
                    else {
                        debugger;
                        var opcheckdata = JSON.parse(data.responsebody).data.op_check;
                   
                        this.opckdetails=opcheckdata;
       
                for (let key in this.opckdetails) {
                    if (
                    this.opckdetails[key].verifiedby_id != null &&
                    this.opckdetails[key].verifiedby_id.first_name != null &&
                    this.opckdetails[key].verifiedby_id.last_name != null
                    ) {
                    const firstName = this.opckdetails[key].verifiedby_id.first_name;
                    const lastName = this.opckdetails[key].verifiedby_id.last_name;
                    const initials = `${firstName.charAt(0).toUpperCase()}${lastName.charAt(0).toUpperCase()}`;
                    this.opckdetails[key].initials = initials;
                    }
                }

                // newly addeddd
                for (let key in this.opckdetails) {
                    if (this.opckdetails[key].job_type != null && this.opckdetails[key].job_type == "Standard Job") {
                        const stanjob = true; 
                        this.opckdetails[key].stanjob = stanjob; 
                      }else if (this.opckdetails[key].job_type && this.opckdetails[key].job_type == "Customer Job") {
                        const custjob = true; 
                        this.opckdetails[key].custjob = custjob; 
                      }else if (this.opckdetails[key].job_type != null && this.opckdetails[key].job_type == "QA Check") {
                        const qacheckjob = true; 
                        this.opckdetails[key].qacheckjob = qacheckjob; 
                      }
                } 
                this.processInstructionsWithIcons();
                this.opckdetails = this.processedDetails;
                       this.showSpinner = false;
                    } 	
                    	
                }).catch(error => {	
                this.error = error;	
                const alertmessage = new ShowToastEvent({	
                    title : 'Sorry we could not fetch Operations Check details.',	
                    message : 'Something unexpected occured. Please contact your Administrator',	
                    variant : 'error'	
                });	
                this.dispatchEvent(alertmessage);	
                	
                });	
                this.showSpinner = false;	
                this.showopckmodal = true;	
        }	
    @track selectedopchek=[];
    @track selectedopcheckid;
    existingrowstatuschange(event){     
        this.selectedopcheckid = event.target.name == 'applicable' ? event.target.dataset.id : event.detail.uniqueid;
        for (var i in this.opckdetails) {
            if (this.opckdetails[i].operation_check_id == this.selectedopcheckid) {
                this.selectedopchek = this.opckdetails[i];
                if (event.target.type != "checkbox") {
                    this.selectedopchek.op_check_status = event.detail.status;
                    this.selectedopchek.is_required = event.detail.is_required;
                 }
            }
        }
        if(this.selectedopchek.value_required && 
           (this.selectedopchek.op_check_value==null || this.selectedopchek.op_check_value=="") &&
           this.selectedopchek.op_check_status){
            const alertmessage = new ShowToastEvent({
            title : 'Value Required.',
            message : 'Value required to update status, Please enter a value',
            variant : 'warning'
            });
            this.dispatchEvent(alertmessage);
            this.getopcheckdeatils();
    
        }else{
            this.uploadopchecktoserver(this.selectedopchek);
        }
    }

    uploadopchecktoserver(opck){
        var opcheckrecord = {
			"ecard_id":this.buildstationdata.ecard_id,
			"buildstation_id": this.buildstationdata.buildstation_id,
			"operation_check_id": opck.operation_check_id,
			"op_check_value": opck.op_check_value,
            "op_check_status": opck.op_check_status,
            "is_required": opck.is_required
        };
        this.showSpinner = true;
        updateopchecks({requestbody:JSON.stringify(opcheckrecord)})
              .then(data => {
                  if(data.isError){
                      const alertmessage = new ShowToastEvent({
                          title : 'Sorry we could not complete the operation.',
                          message : 'Something unexpected occured. Please contact your Administrator',
                         variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                  }
                  else{
                      const alertmessage = new ShowToastEvent({
                          title : 'Successfully updated',
                          message : 'JOB successfully updated.',
                         variant : 'success'
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                    this.refreshtheoperationlist();
                    this.getopcheckdeatils();
                    this.showpicvalmodal = false; 
                  }
                    
              }).catch(error => {
              this.error = error;
               const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not complete the operation.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                   variant : 'error'
              });
              this.dispatchEvent(alertmessage);
              this.showSpinner = false;
              });
    }
    updateopckitem(event){
        this.selectedopcheckid=event.target.title;
        for(var i in this.opckdetails){
            if(this.opckdetails[i].operation_check_id==this.selectedopcheckid){
                this.selectedopchek=this.opckdetails[i];
                this.selectedopchek.op_check_value=event.target.value;
                break;
            }
        }
        this.uploadopchecktoserver(this.selectedopchek);  
    }

    handlemodalaction(messageFromEvt){
        if(messageFromEvt != undefined){
            var message = JSON.parse(messageFromEvt);
            if(message.action=="close modal"){
                switch(this.currentvalidation){
                    case 'BuildStation' :
                        this.showBuildStationmodal=false;
                        break;
                    case 'BM35' :
                        this.showBM35modal=false;
                        break;    
                    case 'PCO' :
                        this.showPCOmodal=false;
                        break;
                }
            }else if(message.action=="show modal"){
                switch(this.currentvalidation){
                    case 'BuildStation' :
                        this.showBuildStationmodal=true;
                        this.showBM35modal=false;
                        this.showPCOmodal=false;
                        break;
                    case 'BM35' :
                        this.showBuildStationmodal=false;
                        this.showBM35modal=true;
                        this.showPCOmodal=false;
                        break;    
                    case 'PCO' :
                        this.showBuildStationmodal=false;
                        this.showBM35modal=false;
                        this.showPCOmodal=true;
                        break;
                }
            }
        }
    }
    
    getmodifiedlist(validationdata){
        var validationitemlist=validationdata;
        var modifiedList = validationitemlist.map(row => ({
            ...row,
            displyitemnumber: 'Test'
          }));
        var displyitemnumber;
        for(var li in modifiedList){
            var vd=modifiedList[li];
            if(vd.lvl==2){
                displyitemnumber=' ->'+ vd.buspart_no;
            }else if(vd.lvl==3){
                displyitemnumber=' -->'+ vd.buspart_no;
            }else{
                displyitemnumber    =vd.buspart_no;
            }
            vd.displyitemnumber=displyitemnumber;
        }
        return modifiedList;
    }
    deletetargetimage(event){
        var status=confirm("Deleting the picture validation target image will remove the actual image from all the upcoming buses within this fleet. Do you want to proceed?");
        if(status){ 
        this.showSpinner = true;
        var requestbody = {
            "picture_validation_target_image_id" : this.buildstationdata.picture_validation_target_image_id, 
            "fleet_id" : event.target.dataset.name,
            "buildstation_id" : event.target.dataset.id,
            "ecard_id" : this.buildstationdata.ecard_id 
        };
        deleteTargetPicture({requestbody:JSON.stringify(requestbody)})
              .then(data => {
                  if(data.isError){
                      const alertmessage = new ShowToastEvent({
                          title : 'Sorry we could not complete the operation. Please try to attach an image file only.',
                          message : 'Something unexpected occured. Please contact your Administrator',
                         variant : 'error'
                    });
                    this.dispatchEvent(alertmessage);
                    
                  }
                  else{
                      const alertmessage = new ShowToastEvent({
                          title : 'Delete successful',
                          message : 'Target Image deleted successfully from fleet.',
                          variant : 'success'
                    });
                    this.dispatchEvent(alertmessage);
                    this.refreshtheoperationlist();
                    this.istargetimagepresent=false;
                    this.targetimageupdatedby = null;
                    this.targetimageupdatedtime = null;
                    this.showSpinner = false;
                  }
                    
              }).catch(error => {
              this.error = error;
               const alertmessage = new ShowToastEvent({
                    title : 'Sorry we could not complete the operation. Please try to attach an image file only.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                   variant : 'error'
              });
              this.dispatchEvent(alertmessage);
              });
    }
    this.actualchanged = false; 
}

    handlePartDrawingButtonClick(event) {
        const url = event.target.dataset.url;
        if (url) {
            window.open(url, '_blank');
        }
    }
}