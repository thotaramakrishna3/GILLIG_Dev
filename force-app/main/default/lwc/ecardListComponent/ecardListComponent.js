import { LightningElement, track } from 'lwc';
import BusImage from "@salesforce/resourceUrl/DefaultEcardImage";
import getEcarddataWrapper from '@salesforce/apex/ecardListController.getEcarddataWrapper';
import getAllCustomerBuses from '@salesforce/apex/ecardOperationsController.getAllCustomerBuses';
import HideLightningHeader from '@salesforce/resourceUrl/HideLightningHeader';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getPicklistOptions from "@salesforce/apex/scheduleBoardController.getPicklistOptions";
import noDatadessert from "@salesforce/resourceUrl/nodatadessert";
import getecardpdf from '@salesforce/apex/ecardListController.getecardpdf';
import pubsub from 'c/pubsub' ; 

import docraptorkey from '@salesforce/label/c.EcardDocraptorkey';

import {permissions}  from 'c/userPermissionsComponent';
import getPermissions from "@salesforce/apex/userAuthentication.getPermissions";
import { NavigationMixin } from 'lightning/navigation';
import EcardLogin from "@salesforce/apex/userAuthentication.EcardLogin";

export default class EcardListComponent extends NavigationMixin(LightningElement) { //implemented navigation
  busImage = BusImage;
  nodatadessert = noDatadessert;
  @track error; // to track the error occuring 
  @track showSpinner; // to show loading spinner
  @track showTable = false; //Used to render table after we get the data from apex controller.
  @track filteredecards = []; // Used to store the filtered ECard list.
  @track completeecarddata; // To store the complete data from server of Ecard list.
  @track showops = false;  // To decide between displaying ecard detial and detail view.
  // For Filters
  @track selectedBusType = 'All Bus Type';
  @track selectedBusStatus = 'WIP';
  @track selectedBusPropulsion = 'All Propulsion Types';
  @track selectedCustomer;
  @track customer;
  @track itemstosearch = []; // list of customer and chasis number
  @track busstatuslist =[{'label': 'WIP', 'value' : 'WIP'}];
  @track bustypelist = [{'label': 'All Bus Type', 'value' : 'All Bus Type'}];
  @track buspropulsionlist = [{'label': 'All Propulsion Types', 'value' : 'All Propulsion Types'}];
  @track partShortageFilter = false;
  @track discrepancyFilter = false;
  @track retaincustomer;
  @track fromshowEcardList=false;

  // For Sorting
  @track sortedDirection = 'asc';
  @track sortedColumn;
  @track previousColumn;
  //For Operations View
  @track selectedEcardId;
  @track selectedBusLabel;
  @track selectedBusChasis;
  @track selectedBusName;
  @track selectedview='Operations';
  @track previousview = 'Operations';
  @track status = ['WIP'];
  @track scheduleview = false;
  @track scheduledata;
  @track exportpdf = 'Export PDF';
  @track exportfullpdf = 'Export Full PDF';

  @track showbusoverview;
  @track rejectbutton = 'Rejects';   
  @track reworkbutton = 'Reworks';  
  @track Jobs = 'Jobs'; 

    // Use whenever a false attribute is required in Component.html
    get returnfalse(){
    return false;
  }

  // Use whenever a true attribute is required in Component.html
    get returntrue(){
    return true;
    }


  get isSelectedOperations(){
    return this.selectedview === 'Operations';
  }
  get isSelectedDiscrepancies(){
    return this.selectedview === 'Issues';
  }
  get isSelectedShortages(){
    return this.selectedview === 'Shortages';
  }
  get isSelectedSlnologs(){
    return this.selectedview === 'Serial No. Logs';
  }
  handleExportFullPDF(event){
    this.exportpdf = event.target.label;
    if(event.target.label == 'Export PDF'){
      this.exportfullpdf = 'Export Full PDF';
    }else{
      this.exportfullpdf = 'Export PDF';
    }
    
  }

handleChangeFunction(event){
  this.Jobs = event.target.label;


  if(event.target.label == 'Rejects'){
    this.Jobs = 'Rejects';
    this.rejectbutton = 'Jobs';
    this.reworkbutton = 'Reworks';
  }
  else if(event.target.label == 'Reworks'){
  this.Jobs = 'Reworks';
    this.rejectbutton = 'Rejects';
    this.reworkbutton = 'Jobs';
  }
  else{
    this.Jobs = 'Jobs';
    this.rejectbutton = 'Rejects';
    this.reworkbutton = 'Reworks';
  }

  const dropDownButton = this.template.querySelector('[data-label="Operation Checks"]');
  if (dropDownButton) {
    dropDownButton.variant = null;
  }

}
handleSwap(btnvalue){
  this.Jobs = btnvalue;



  if(btnvalue == 'Rejects'){
    this.Jobs = 'Rejects';
    
    this.rejectbutton = 'Jobs';
    this.reworkbutton = 'Reworks';
  
  }
  else if(btnvalue == 'Reworks'){
  this.Jobs = 'Reworks';
    this.rejectbutton = 'Rejects';
    this.reworkbutton = 'Jobs';
  }
  else{
  this.Jobs = 'Jobs';
    this.rejectbutton = 'Rejects';
    this.reworkbutton = 'Reworks';
  }


  
}
  get isecardlistempty(){
    return this.filteredecards.length == 0;
  }  
  // To get the app permissions from server to handle access within the component.
  wiredPermissions;
  permissionset;
  async getPermissionsfromserver(event){
      await getPermissions()
        .then((data) => {
          this.wiredPermissions = JSON.parse(data.responsebody);
          this.permissionset = permissions(this.wiredPermissions);
          if (this.loggedinuser.approle_id == 8){
            this.permissionset["discrepancy_ci_new"] = { read: true, write: true };
        }
          this.error = undefined;
        })
        .catch((error) => {
          this.error = error;
          this.wiredPermissions = undefined;
        });
    }

  // Loads the default data for intial view of the component.  
  connectedCallback(){
    this.getloggedinuser();
    loadStyle(this, HideLightningHeader);
    this.register();
    //this.getPermissionsfromserver();
    this.decideview(event);
    }
    @track IsFirstTimeRunning  = false;
    @track loggedinuser;
    getloggedinuser() {
        this.IsFirstTimeRunning = true;
        EcardLogin()
            .then((result) => {
                this.loggedinuser = result.data.user;
            })
            .catch((error) => {
            });
    }

  // To decide the view between Ecard list or detail of the selected Ecard.  
  decideview(event){
    // Show List or Operations
    this.getPermissionsfromserver();
    var ecardid = JSON.parse(localStorage.getItem('ecardid'));
    if(ecardid == undefined || ecardid == null){
        this.showops = false;
        this.showTable = true;
        this.loaddata();
    }
    else{
      if (ecardid.scheduleboard != undefined || ecardid.scheduleboard != null || ecardid.scheduleflow) {
        var data = (ecardid.scheduleboard != undefined || ecardid.scheduleboard != null) ? ecardid : ecardid.scheduledata;
        this.scheduledata = data;
        this.scheduleview = true;
        localStorage.setItem('scheduleflowdata', JSON.stringify(data));
        ecardid = (ecardid.scheduleboard != undefined || ecardid.scheduleboard != null) ? ecardid.ecardid : ecardid;
      }
        this.showops = true;
        this.showTable = false;
        this.selectedEcardId = ecardid.ecardid;
        this.selectedBusLabel = `${ecardid.BusName}, ${ecardid.ChasisNumber}`;
        this.selectedBusChasis = ecardid.ChasisNumber;
        this.selectedBusName = ecardid.BusName;
        this.sequence = ecardid.busSequence!=undefined?ecardid.busSequence.replace(/[{()}]/g, ''):'';
        this.sequanceavailable=ecardid.busSeqavailable;
        localStorage.removeItem('ecardid');
        localStorage.setItem('opsecardid', JSON.stringify(ecardid));
        this.showSpinner = false;
    }
    if((this.isAPIExecuted == false && this.isExecuted == false) && (this.scheduleview == true || (ecardid != undefined && ecardid != null))){     
      this.getAllCustomerBusesList(this.selectedBusChasis);
      setTimeout(() => {
        this.getListofCustomerBuses(this.selectedBusChasis);
      },
      1000);
    }
  }
  // In order to reduce the callout limit we are fetching the picklist values of filter only on focus.
  loadpicklistvalues(event){
    var picklistname = event.target.name;
    if(event.target.options.length == 1){
      getPicklistOptions({picklistName:picklistname})
      .then(data => {
        if(data.isError){
          const alertmessage = new ShowToastEvent({
              title : 'Data fetch failed.',
              message : 'Something unexpected occured. Please contact your Administrator',
              variant : 'error'
          });
          this.dispatchEvent(alertmessage);
          throw 'Data fetch failed';
        }
        else{
            var options = data.options;
            if(picklistname == 'bustype'){
              this.bustypelist = options;
            }
            if(picklistname == 'buspropulsions'){
              this.buspropulsionlist = options;
            }
            if(picklistname == 'busstatus'){
              for( var i = 0; i < options.length; i++){  
                if (options[i].value === 'Sold' || options[i].value === 'All Bus Status') { 
                  options.splice(i, 1); 
                }
              }
              this.busstatuslist = options;
            }
        }
    })
    .catch(error => {
      this.error = error;
      const alertmessage = new ShowToastEvent({
          title : 'Data fetch failed.',
          message : 'Something unexpected occured. Please contact your Administrator',
          variant : 'error'
      });
      this.dispatchEvent(alertmessage);
      
    });
    }
  }
  // Load the list view of Ecards.
  loaddata(){
    var today = new Date();
    var start = today;
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds()+":"+today.getMilliseconds();
    this.showSpinner = true;
    var statuslist=[];
    for(var i=0;i<this.status.length;i++){
      var val = this.status[i];
      statuslist.push(val.replaceAll(" ", "%20"));
    }
    var statusparm={bus_status:statuslist};
      getEcarddataWrapper({status : JSON.stringify(statusparm)})
      .then(data => {
          today = new Date();
          time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds()+":"+today.getMilliseconds();
          var elapsed = today. getTime() - start;
          // Setting up data to view End
          let moddedecardlist = [];
          let searchlist = [];
          for (var index in data.ecarddata) {
              var ecard = data.ecarddata[index];
              
              var seqavailable=ecard.bus_relative_seq!=undefined?true:false;
              var imgdefault=(ecard.curb_side_image_url=="" || ecard.curb_side_image_url==null )?true:false;
              var showwc=true;
              if( ecard.workcenter_name =='9999' || ecard.workcenter_name =='0' ||  
                  ecard.workcenter_name == undefined || ecard.workcenter_name ==null){
                showwc=false;
              }                
              searchlist.push(ecard.customer_name);
              searchlist.push(ecard.chassis_no);
              var formatteddate = new Date(ecard.schedule_date).valueOf();
              var source = { styleclass: ' ', 
                              validecard:' ',
                              showworkcenter:showwc,
                              formattedscheduledate: formatteddate,
                              defaultimage:imgdefault,
                              sequanceavailable:seqavailable
                            };
              let modifiedecard = Object.assign(source,ecard);
              moddedecardlist.push(modifiedecard);
          }
          this.itemstosearch = Array.from(new Set(searchlist));
          this.completeecarddata = moddedecardlist;
          this.filteredecards = moddedecardlist;
          if(this.selectedBusPropulsion!='All Propulsion Types' || this.selectedBusType != 'All Bus Type' || this.selectedCustomer != null){
            this.handleallFilterchanges();
          }
          // Setting up data to view End
          this.showSpinner = false;
          var pageload = new Date();
          time = pageload.getHours() + ":" + pageload.getMinutes() + ":" + pageload.getSeconds()+":"+pageload.getMilliseconds();
          elapsed = pageload. getTime() - today;
          this.error = undefined;
          
      })
      .catch(error => {
          this.error = error;
          const alertmessage = new ShowToastEvent({
            title : 'Data fetch failed.',
            message : 'Something unexpected occured. Please contact your Administrator',
            variant : 'error'
        });
        this.dispatchEvent(alertmessage);  
      });
    }
  // To handle all the filter changes and filter the ecard list based on the filter conditions.  
  handleallFilterchanges(event){
      var selectedbustype = this.selectedBusType;
      var selectedcustomer = this.selectedCustomer;
      var selectedpropulsion = this.selectedBusPropulsion;
      //var selectedbusstatus = this.selectedBusStatus;
      if(this.fromshowEcardList){
        this.loaddata();
        this.fromshowEcardList=false;
      }

      this.showSpinner = true;
      var filteredecardlist = [];
      var completedata = JSON.parse(JSON.stringify(this.completeecarddata));
      for (var index in completedata) {
              var ecard = completedata[index];
              var ecardStyle = ecard.styleclass;
              if (selectedcustomer != undefined) {
                  if (ecard.customer_name == selectedcustomer || ecard.chassis_no == selectedcustomer) {

                  } else {
                      ecard.styleclass = ecardStyle + ' makeinvisible';
                      }
              }
              if (selectedbustype != undefined && selectedbustype != 'All Bus Type') {
                  if (ecard.bustype_name == selectedbustype) {

                  } else {
                      ecard.styleclass = ecardStyle + ' makeinvisible';
                      }
              }
            //   if (selectedbusstatus != undefined && selectedbusstatus != 'All Bus Status') {
            //     if (ecard.busstatus_name == selectedbusstatus) {

            //     } else {
            //       ecard.styleclass = ecardStyle + ' makeinvisible';
            //     }
            // }
            if (selectedpropulsion != undefined && selectedpropulsion != 'All Propulsion Types') {
              if (ecard.buspropulsion_name == selectedpropulsion) {

              } else {
                  ecard.styleclass = ecardStyle + ' makeinvisible';
              }
          }             
          // setting up filteredbus
            if(!ecard.styleclass.includes("makeinvisible"))
            filteredecardlist.push(ecard);
          }
      this.filteredecards = filteredecardlist;
      this.showSpinner = false;
    }

  // To handle when a selected customer/chassis number needs to be cleared.
  onclearcustomer(event) {
      this.selectedCustomer = undefined;
      this.retaincustomer =undefined;
      this.handleallFilterchanges(event);
    }
  // To handle the search result when a customer is selected from the list.
  handleSearch(event) {
      if (event.detail.labelvalue == "Customer") {
          this.selectedCustomer = event.detail.selectedRecord;
          this.retaincustomer=event.detail.selectedRecord;
        }
      this.handleallFilterchanges(event);
    }

  // To handle  when filter on Bus Propulsion is selected.  
  handlebuspropulsionchange(event){
    this.selectedBusPropulsion = event.detail.value;
    this.handleallFilterchanges(event);
    }

  // To handle  when filter on Bus Status is selected.
  handlebusstatuschange(event){
    var statusval = event.detail.value;
    if(!this.status.includes(statusval)){
    this.status.push(statusval);
    this.allStatusValues = this.status;
    }
    this.loaddata();
    }
    
  // To handle  when filter on Bus Type is selected.  
  handlebustypechange(event) {
    this.selectedBusType = event.detail.value;
    this.handleallFilterchanges(event);
    }

  // To handle  when filter on Part Shortage is selected.  
  onPartShortageselection(event) {
    this.partShortageFilter = event.target.checked;
    this.handleallFilterchanges(event);
    }

  // To handle  when filter on Discrepancy is selected.  
  onDiscrepancyselection(event) {
    this.discrepancyFilter = event.target.checked;
    this.handleallFilterchanges(event);
    }

  // To handle sort on columns in Bus/Ecard view. 
  sort(event) {
      var previousSorted = this.previousColumn;
      if(previousSorted !=undefined){
          if(event.currentTarget.dataset.id != previousSorted){
              const element = this.template.querySelector('[data-id="' + previousSorted +'"]');
              element.iconName = '';
              this.previousColumn = event.currentTarget.dataset.id;
          }
          else{
              this.previousColumn = event.currentTarget.dataset.id;
          }
      }
      else{
          this.previousColumn = event.currentTarget.dataset.id;
      }
      
      
      if(this.sortedColumn === event.currentTarget.dataset.id){
          this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
      }else{
          this.sortedDirection = 'asc';
      }        
      var reverse = this.sortedDirection === 'asc' ? 1 : -1;
      let table = JSON.parse(JSON.stringify(this.filteredecards));
      table.sort((a,b) => {return a[event.currentTarget.dataset.id] > b[event.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});
      this.sortedColumn = event.currentTarget.dataset.id;        
      this.filteredecards = table;
      if(this.sortedDirection === 'asc'){
          event.target.iconName='utility:chevronup';
      }
      if(this.sortedDirection === 'desc'){
          event.target.iconName='utility:chevrondown';
      }

  } 

  // Used to change the style and get data for the tab selected. (Operations/Discrepancies/Shortages/Serial No.logs)

  changeview(event){
    this.selectedview = event.currentTarget.dataset.label;

    if (event.currentTarget.label === 'Rejects' || event.currentTarget.label === 'Reworks' ) {

    this.selectedview = event.currentTarget.label; // Update with dropdown selection

}

  
  
        event.target.variant = 'brand';
        
        let selectedviewTemp = this.selectedview == 'Rejects' || this.selectedview == 'Reworks' ?  'Operation Checks':this.selectedview;
        let previewTemp = this.previousview == 'Rejects' || this.previousview == 'Reworks' ?  'Operation Checks':this.previousview;
        var ele = this.template.querySelector('[data-label="' + selectedviewTemp +'"]');
    if(this.selectedview != this.previousview){
      var element = this.template.querySelector('[data-label="' + previewTemp +'"]'); 
    if(selectedviewTemp != previewTemp)
        element.variant = '';
      this.previousview = event.currentTarget.dataset.label;
      this.template.querySelector('c-operations-component').operationchanged(this.selectedview);
    }
  }


  // To register the event fired from Bus Overview component
  register(){
    pubsub.register('applyfilters', this.applyfilters.bind(this));
  }

  // To change the tab selected when a filter from Bus Overview is been applied.
  applyfilters(messageFromEvt){
    if(messageFromEvt != undefined){
      var valueforfilters = JSON.parse(messageFromEvt);
    this.selectedview = valueforfilters.view;
    if(this.selectedview === 'Rejects' || this.selectedview === 'Reworks' || this.selectedview === 'Operation Checks'){
      this.handleSwap(this.selectedview);
    }
    let selectedviewTemp = this.selectedview == 'Rejects' || this.selectedview == 'Reworks' ?  'Operation Checks':this.selectedview;
    let previewTemp = this.previousview == 'Rejects' || this.previousview == 'Reworks' ?  'Operation Checks':this.previousview;
    
    
    var ele = this.template.querySelector('[data-label="' + selectedviewTemp +'"]');
  ele.variant = 'brand';
  if(this.selectedview != this.previousview){
      var element = this.template.querySelector('[data-label="' + previewTemp +'"]');

      if(selectedviewTemp != previewTemp)
        element.variant = '';
      this.previousview = valueforfilters.view;
      this.template.querySelector('c-operations-component').operationchanged(this.selectedview, messageFromEvt);
    }
    else{
      this.template.querySelector('c-operations-component').operationchanged(this.selectedview, messageFromEvt);
    }
    }
    else{
      this.template.querySelector('c-operations-component').operationchanged(this.selectedview, undefined);
    }
    
  }

  // To show the operations/details tab of a Selected Ecard.
  @track sequence;
  @track sequanceavailable;
  @track currentDepartment ; //Phase 1.1: To set the current Department 
@track hasNext=true;
@track hasPrevious=true;
@track fleetbuses =[];
@track isAPIExecuted = false;
@track isExecuted = false;
getAllCustomerBusesList(chasisno){
  this.isAPIExecuted = true;
  getAllCustomerBuses({chasisno: chasisno}).then(result => {
    if(result.isError){
      const alertmessage = new ShowToastEvent({
        title: "Failed to fetch customer buses in the fleet.",
        message:"Something unexpected occured. Please contact your Administrator",
        variant: "error"
    });
    this.dispatchEvent(alertmessage);
    }else{
      const resp = JSON.parse(result.responsebody);
      this.fleetbuses = resp.data.ecard;
      console.log('result '+JSON.stringify(result));
      console.log('result.operationlogresponse.data '+this.fleetbuses);
      console.log(JSON.stringify(result.responsebody));
    }
  });
}
getListofCustomerBuses(chasis) {
  this.isExecuted = true;
  const selectedRec = this.fleetbuses.filter(record => record.chassis_no === chasis);
  if(selectedRec.length >0){
  const selectedlistRec = this.fleetbuses.filter(record => record.base_serial_fleet === selectedRec[0].base_serial_fleet);
  selectedlistRec.sort((a, b) => b.chassis_no.localeCompare(a.chassis_no));
  for (let record of selectedlistRec) {
      if (selectedRec[0].chassis_no > record.chassis_no) {
          this.hasPrevious = false;
          this.previousMockEvent = {
              currentTarget: {
                  dataset: {
                      department: record.department_name,
                      id: record.chassis_no,
                      label: record.customer_name,
                      value: record.ecard_id,
                      sequence: record.bus_relative_seq
                  }
              }
          };
          break;// Stop after finding the next record
      }else{
        this.hasPrevious = true;
      }
      

  }
  selectedlistRec.sort((a, b) => a.chassis_no.localeCompare(b.chassis_no));
  for (let rec of selectedlistRec) {   
    if (rec.chassis_no > selectedRec[0].chassis_no) {
      this.hasNext = false;
      this.nextMockEvent = {
        currentTarget: {
          dataset: {
            department: rec.department_name,
            id: rec.chassis_no,
            label: rec.customer_name,
            value: rec.ecard_id,
            sequence: rec.bus_relative_seq
          }
        }        
      };
      break; // Stop the loop as soon as the next record is found
    }else{
      this.hasNext = true;
    }
  }
}
}

@track nextMockEvent;
@track previousMockEvent;
showNextBus(){
this.showops = false;
setTimeout(() => {
  this.showOperations(this.nextMockEvent);
}, 300);
  }
showPreviousBus(){
this.showops = false;
setTimeout(() => {
this.showOperations(this.previousMockEvent);
}, 300);
  }
  showOperations(event){
    this.Jobs = 'Jobs';
    this.rejectbutton = 'Rejects';
    this.reworkbutton = 'Reworks';
    this.showops = true;
    this.showTable = false;
    let chasis = event.currentTarget.dataset.id;
    let customer = event.currentTarget.dataset.label;
    this.customer = customer;
    this.sequence = event.currentTarget.dataset.sequence;
    this.sequanceavailable=this.sequence==undefined?false:true;
    this.selectedEcardId = event.currentTarget.dataset.value;
    this.selectedBusChasis = chasis;
    this.selectedBusName = customer;
    this.selectedBusLabel = `${customer}, ${chasis}`;
    this.currentDepartment = event.currentTarget.dataset.department ; //Phase 1.1: Getting the Department Name
    this.getAllCustomerBusesList(chasis);
    setTimeout(() => {
      this.getListofCustomerBuses(chasis);
    },
    1000); 
  }

  // To show the Ecard list when redirecting back from a detail of an Ecard.
  showEcardList(event){
      this.showops = false;
      this.showTable = true;
      this.selectedview='Operations';
      this.previousview = 'Operations'; 
      if(this.scheduleview){
        this.scheduleview = false;
        this.navigatetoscheduleboard();
      }
      else{
        if(this.filteredecards.length!=0){
          this.fromshowEcardList=true;
          this.handleallFilterchanges(event);
        }
        else{
          this.connectedCallback();
        }
      }
    } 

  async downloadecard(event){
    var ecardid=event.currentTarget.dataset.id;
    var pdfurl=undefined;
    this.showSpinner = true;
    debugger;
    await getecardpdf({ ecardid: ecardid,val:this.exportpdf })
    .then((data) => {
        if (data.isError) {
          this.showSpinner = false;
            const alertmessage = new ShowToastEvent({
            title: "Failed to fetch Ecard PDF url.",
            message:"Something unexpected occured. Please contact your Administrator",
            variant: "error"
        });
        this.dispatchEvent(alertmessage);
        } else {
            debugger;
            var pdfdetails = JSON.parse(data.responsebody).data;
            var htmlcontent= pdfdetails.EcardHtml;
            var pdfname=this.customer+'-'+this.selectedBusChasis;
            var pdfkey=docraptorkey;
            this.createAndDownloadDoc(pdfkey, {  
                type: "pdf",
                name: pdfname,
                document_content: htmlcontent
            });              
            this.showSpinner = false;
        }   
    })
    .catch((error) => {
        const alertmessage = new ShowToastEvent({
        title: "Failed to fetch Ecard PDF url.",
        message:"Something unexpected occured. Please contact your Administrator",
        variant: "error"
        });
        this.dispatchEvent(alertmessage);
        this.showSpinner = false;
    });
    }
    // Creates an HTML form with doc_attrs set, submits it. If successful
    // this will force the browser to download a file. On failure it shows
    // the DocRaptor error directly.
    createAndDownloadDoc (api_key, doc_attrs) {
        var makeFormElement = function(name, value) {
          var element = document.createElement("textarea")
          element.name = name
          element.value = value
          return element
        }
    
        var form = document.createElement("form")
        form.action = "https://docraptor.com/docs"
        form.method = "post"
        form.style.display = "none"
    
        form.appendChild(makeFormElement("user_credentials", api_key))
    
        for (var key in doc_attrs) {
          if (key == "prince_options") {
            for (var option in doc_attrs.prince_options) {
              form.appendChild(makeFormElement("doc[prince_options][" + option + "]", doc_attrs.prince_options[option]))
            }
          } else {
            form.appendChild(makeFormElement("doc[" + key + "]", doc_attrs[key]))
          }
        }
        document.body.appendChild(form);
        form.submit()
      }
//Added to enable navigation back to schedule board page
navigatetoscheduleboard() {
  localStorage.setItem('scheduledata', JSON.stringify(this.scheduledata)); 
  this[NavigationMixin.Navigate]({
    type: 'standard__navItemPage',
    attributes: {
      // CustomTabs from managed packages are identified by their
      // namespace prefix followed by two underscores followed by the
      // developer name. E.g. 'namespace__TabName'
      apiName: 'Schedules_Board'
    }
  });
}
@track allStatusValues = ["WIP"];
handleStatusRemove(event) {
  const valueRemoved = event.target.name;
  this.allStatusValues.splice(this.allStatusValues.indexOf(valueRemoved), 1);
  if (this.allStatusValues.length === 0) {
    this.allStatusValues = ["WIP"];
    this.status = ['WIP'];
  }else{
    this.status = this.status.filter(item => item !== valueRemoved);
}
if(this.status.length > 1){
  this.selectedBusStatus = this.status[this.status.length - 1];
}else{
  this.selectedBusStatus = this.status;
}
  this.loaddata();
}

}