import { LightningElement, track } from "lwc";
import noDatadessert from "@salesforce/resourceUrl/nodatadessert";
import HideLightningHeader from "@salesforce/resourceUrl/HideLightningHeader";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getPicklistOptions from "@salesforce/apex/DiscrepancyDatabaseController.getPicklistOptions";
import getAllEcarddetailsfromServer from "@salesforce/apex/DiscrepancyDatabaseController.getAllEcarddetails";
import getDepartmentdata from "@salesforce/apex/masterDataController.getDepartmentdata";
import getCompleteDefectCodes from "@salesforce/apex/ecardOperationsController.getDefectCodes";
import getAllComments from "@salesforce/apex/DiscrepancyDatabaseController.getAllComments";
import addnewComment from "@salesforce/apex/DiscrepancyDatabaseController.addnewComment";
import getcrewingsuserslist from "@salesforce/apex/CrewingScheduleController.getcrewingsuserslist";
import deleteDiscOrShortage from "@salesforce/apex/ecardOperationsController.deleteDiscOrShortage";

import { permissions, modifieduserlist, getmoddeddate, getselectedformandetails, preassignforeman, preassignqc, setstatusfordisplay } from 'c/userPermissionsComponent';
import getPermissions from "@salesforce/apex/userAuthentication.getPermissions";
import EcardLogin from "@salesforce/apex/userAuthentication.EcardLogin";
import getStatusPicklistOptions from "@salesforce/apex/scheduleBoardController.getPicklistOptions";
import pubsub from 'c/pubsub';
import getPartshortagecauselist from "@salesforce/apex/ecardOperationsController.getPartshortageCauses";
import getAllShortageslist from "@salesforce/apex/ShortagesDatabaseController.getEcardShortagePaginationData";
import getAllpartsVendorlist from '@salesforce/apex/ecardOperationsController.getAllpartsVendorlist';
import getDefaultVendorandBuyer from '@salesforce/apex/ecardOperationsController.getDefaultVendorandBuyer';
import updatePartshortage from "@salesforce/apex/ecardOperationsController.updatePartshortage";
import getallUsers from "@salesforce/apex/UserListingController.getallUsers";
import getEcarddataWrapper from '@salesforce/apex/ecardListController.getEcarddataWrapper';
import getBuyerforFilterOptions from '@salesforce/apex/ShortagesDatabaseController.getBuyerforFilterOptions';

export default class ShortageDbPaginationComponent extends LightningElement {
  nodatadessert = noDatadessert;
  @track error; // to track the error occuring
  @track showSpinner; // to show loading spinner
  @track currentuserid = 2;
  @track loggedinuser;

  @track alldiscrepancy = [];

  // New Discrepancy variables
  @track ecardoptions = [];
  @track ecardnamechasislist = [];
  @track buildstationoptions = [];
  @track departmentoptions = [];
  @track defectoptions = [];
  @track priorityoptions = [
    { label: "High", value: "High" },
    { label: "Normal", value: "Normal" },
    { label: "Low", value: "Low" }
  ];
  @track newdiscrepancymodal = false;
  @track deptsupervisorforselecteddept;
  @track selecteddeptbsdetails;
  @track alldefectcode;
  @track paintdefects = [];
  @track otherdefects = [];
  @track newdiscrepancy;

  // For Filteration
  @track itemstosearch = ["Disney", "Suyati", "Gillig", "123232"];
  @track createdbyuserslist = [];
  @track assigneduserslist = [];
  @track selectedCustomer;
  @track selecteddepartement = "0";
  @track departmentlist = [
    { label: "All Departments", value: "0" }
  ];
  @track selectedstatus = "Open";
  @track statuslist = [{ label: "All Shortage Status", value: "All Status" }, { label: "Open", value: "Open" }, { label: "Resolved", value: "Resolve" }, { label: "Verified", value: "Approve" }];
  @track selectedbuyer = "All Buyer";
  @track buyerlist = [
    { label: "All Buyer", value: "All Buyer" }
  ];

  @track selectedcreatedbyuser;
  @track selectedassignedtouser;
  @track selectedcreatedddate;

  // For Sorting
  @track sortedDirection = "asc";
  @track sortedColumn;
  @track previousColumn;

  // For Details View
  @track detailsmodal = false;
  @track selecteddiscrepancy;
  @track selecteddiscrepancycomments = [];
  @track qccapturerole = false;
  @track qccaptureaction = false;
  @track isdelenabled = false;
  @track busstatuslist = [{ label: 'All Bus Status', value: 'All Bus Status' }];
  @track selectedBusStatus = 'All Bus Status';
  @track isbusareaarray = false;
  @track departmentIdMap = [{
    'bus_area_discrepancy_enabled': true,
    'label': 'All Departments',
    'value': '0'
  }];
  @track statusascomment = false;
  @track statuscommentmap = {
    "resolve": "Status changed to Resolved",
    "approve": "Status changed to Verified",
    "open": "Status changed to Open"
  };
  @track isupdated;
  @track carrieroptions = [
    { "label": "None", "value": "null" },
    { "label": "UPS", "value": "UPS" },
    { "label": "UPS 2ND DAY", "value": "UPS 2ND DAY" },
    { "label": "UPS NDA", "value": "UPS NDA" },
    { "label": "UPS NDA EARLY AM", "value": "UPS NDA EARLY AM" },
    { "label": "FEDEX", "value": "FEDEX" },
    { "label": "FEDEX 2ND DAY", "value": "FEDEX 2ND DAY" },
    { "label": "FEDEX NDA", "value": "FEDEX NDA" },
    { "label": "COURIER", "value": "COURIER" },
    { "label": "VENDOR TRUCK", "value": "VENDOR TRUCK" },
    { "label": "OTHER", "value": "OTHER" }
  ];
  @track allbuyerslist = [];
  @track modifiedshortageslist = [];
  @track scrolltoTop = true;


  

  // Use whenever a false attribute is required in Component.html
  get returnfalse() {
    return false;
  }

  get isdeletable() {
    return this.isdelenabled;
  }

  // Use whenever a true attribute is required in Component.html
  get returntrue() {
    return true;
  }

  get disctype() {
    var discrepancytypes = [
      { label: "Normal Discrepancy", value: "buildstation" },
      { label: "Department Discrepancy", value: "department" }
    ];
    return discrepancytypes;
  }

  get disclistempty() {
    return this.modifiedshortageslist.length == 0;
  }
  get isdepartmentdisclistempty() {
    return this.filtereddepartmentdiscrepancy.length == 0;
  }

  get disableprodforupdate() {
    return !this.permissionset.shortage_update_prod.write || this.selectedshortage.discrepancy_status.toLowerCase() != "open";//added
  }

  get disableqcforupdate() {
    if (this.selecteddiscrepancy.discrepancy_status.toLowerCase() == "approve") {
      return true;
    } else {
      return false;
    }
  }

  get departmentnotselected() {
    if (this.newdiscrepancy.departmentid == undefined) {
      return true;
    } else {
      return false;
    }
  }

  get ecardnotselected() {
    if (this.newdiscrepancy.ecardid == undefined) {
      return true;
    } else {
      return false;
    }
  }

  //used to dispaly/hide the preview image colomn
  get isdepartmentPaint() {
    var isdepartmentpaintortrim = false;
    var departmentname = this.selecteddepartement;
    for (var i in this.departmentIdMap) {
      if (this.departmentIdMap[i].label == departmentname) {
        isdepartmentpaintortrim = this.departmentIdMap[i].bus_area_discrepancy_enabled;
      }
    }
    return isdepartmentpaintortrim;
  }

  //used to display/hide the shortage button
  get disableshortgbtn() {
    if (this.permissionset != undefined) {
      return !this.permissionset.shortage_new.write;
    }
    else return false;
  }

  get returntrue() {
    return true;
  }

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

  connectedCallback() {
    loadStyle(this, HideLightningHeader);
    this.loadpartshotcauselist();//to-do
    this.getloggedinuser();
    this.getPermissionsfromserver();
    this.setdepartmentidmap();
    this.showSpinner = true;
    this.applyfilter();
    this.getuserlistfromserver();
    this.getEcardandCustomerforSearch();
    pubsub.register('refreshdata', this.refreshDiscrepancy.bind(this));
  }

  @track currentuserempid;
  getloggedinuser() {
    EcardLogin()
      .then((result) => {
        this.loggedinuser = result.data.user;
        if (this.loggedinuser.approle_id == 1 || this.loggedinuser.approle_id == 4) {
          this.qccapturerole = true;
        } else {
          this.qccapturerole = false;
        }
        this.currentuserempid = this.loggedinuser.employee_id;
      })
      .catch((error) => {
      });
  }


  loadShortagesdata(event, disableScroll) {
    this.showSpinner = true;
    this.scrolltoTop = true;
    if (disableScroll) {
      this.scrolltoTop = false;
    }
    var statusparm = this.paginationfilter;
    statusparm['page'] = this.currentPage;
    getAllShortageslist({ ecardbusstatus: JSON.stringify(statusparm) })
      .then(data => {
        var recordperpage = JSON.parse(data.responsebody).data.max_record_per_page;
        var totalrecordcount = JSON.parse(data.responsebody).data.count;
        var totalPage = Math.ceil(totalrecordcount / recordperpage);
        this.totalPage = totalPage != 0 ? totalPage : 1;
        var shortageslist = [];

        var shortagelogs = JSON.parse(data.responsebody).data.discrepancylog;
        var modshortagesList = [];
        for (var disc in shortagelogs) {
          var index = Number(disc) + 1;
          var shortageobj = shortagelogs[disc];
          var created_by = modifieduserlist([shortageobj.createdby_id]);
          var raised_date = getmoddeddate(shortageobj.raised_date);
          var createdbyname;
          var displaycreatedbyname;
          var createdbyempid = undefined;
          if (created_by != undefined && created_by.length != 0) {
            if (created_by[0] != undefined) {
              displaycreatedbyname = `${created_by[0].name} (${created_by[0].userid}) on ${raised_date}`;
              createdbyname = `${created_by[0].name}`;
              createdbyempid = `${created_by[0].userid}`;
            }
          }
          var is_deletable = false;
          if ((createdbyempid == this.currentuserempid) && (shortageobj.discrepancy_status.toLowerCase() == "open")) {
            is_deletable = true;
          }
          var partname;
          if (shortageobj.buspart_id != null) { //to-do add param in api resp
            // if (shortageobj.buspart_no != null) { //remove this component
            partname = shortageobj.buspart_name;
          }
          else {
            partname = shortageobj.custom_part_name;
          }
          var bsavailable = shortageobj.buildstation_code == '9999' ? false : true;
          var currentlocationavailable = (shortageobj.current_line_location != '9999' && shortageobj.current_line_location != null) ? true : false;
          var qc_avilable = shortageobj.assigend_qc_id != null ? true : false;
          var moddedshortage = {
            index: index,
            departmentid: shortageobj.department_id,
            departmentcode: this.getdepartmentcode(shortageobj.department_id, this.departmentIdMap),
            createdbyname: createdbyname,
            displaycreatedbyname: displaycreatedbyname,
            modified_date: shortageobj.modified_date,
            buildstation_code: shortageobj.buildstation_code,
            buildstation_id: shortageobj.buildstation_id,
            disc_bsavailable: bsavailable,
            part_shortage_id: shortageobj.part_shortage_id,
            buspart_id: shortageobj.buspart_id,
            buspart_name: partname,
            custom_part_name: shortageobj.custom_part_name,
            buspart_no: shortageobj.buspart_no,
            busstatus_id: shortageobj.busstatus_id,
            busstatus_name: shortageobj.busstatus_name,
            chassis_no: shortageobj.chassis_no,
            component: shortageobj.component,
            createdby_id: modifieduserlist([shortageobj.createdby_id]),
            defect_codename: `${shortageobj.defect_code}, ${shortageobj.defect_name}`,
            discrepancy_statusdisplay: setstatusfordisplay(shortageobj.discrepancy_status.toLowerCase()),
            discrepancy_type: this.capitalize(shortageobj.discrepancy_type),
            cut_off_date: shortageobj.cut_off_date != null ? this.modedlocatdatetime(shortageobj.cut_off_date) : shortageobj.cut_off_date,
            displaycutoffdate: getmoddeddate(shortageobj.cut_off_date),
            dat_defect_code_id: shortageobj.dat_defect_code_id,
            defect_code: shortageobj.defect_code,
            defect_name: shortageobj.defect_name,
            defect_type: shortageobj.defect_type,
            isdeletable: is_deletable,
            department_id: shortageobj.department_id,
            department_name: shortageobj.department_name,
            discrepancy: shortageobj.discrepancy,
            discrepancy_priority: this.capitalize(shortageobj.discrepancy_priority),
            discrepancy_status: shortageobj.discrepancy_status.toLowerCase(),
            ecard_discrepancy_area_id: shortageobj.ecard_discrepancy_area_id,
            ecard_discrepancy_log_id: shortageobj.ecard_discrepancy_log_id,
            ecard_discrepancy_log_number: shortageobj.discrepancy_log_number,
            ecard_id: shortageobj.ecard_id,
            ecard_operation_log_id: shortageobj.ecard_operation_log_id,
            first_name: shortageobj.first_name,
            last_name: shortageobj.last_name,
            customername: `${shortageobj.customer_name}`,
            has_part_shortage: shortageobj.has_part_shortage,
            assignedprod: getselectedformandetails(shortageobj),
            part_avilable: shortageobj.part_avilable,
            buyer_code_avilable: (shortageobj.buyer == null || shortageobj.planner_code == null) ? false : true,
            po_no: shortageobj.po_no,
            allprodlist: modifieduserlist(shortageobj.prod),
            allqclist: modifieduserlist(shortageobj.qc),
            quantity: shortageobj.quantity,
            assigend_qc_id: modifieduserlist([shortageobj.assigend_qc_id]),
            qcavailable: qc_avilable,
            raised_date: shortageobj.raised_date,
            raised_date_display: getmoddeddate(shortageobj.raised_date),
            raised_status_updated_date: shortageobj.raised_status_updated_date,
            resolved_date: shortageobj.resolved_date,
            resolved_status_updatedby_id: modifieduserlist([shortageobj.resolved_status_updatedby_id]),
            resolved_status_updated_date: shortageobj.resolved_status_updated_date,
            root_cause: shortageobj.root_cause,
            verifiedby_id: modifieduserlist([shortageobj.verifiedby_id]),
            verified_date: shortageobj.verified_date,
            verified_status_updated_date: shortageobj.verified_status_updated_date,
            workcenter_code: shortageobj.workcenter_code,
            workcenter_name: shortageobj.workcenter_name,
            filtered: "",
            created_by: created_by,
            buyer: shortageobj.buyer,
            carrier_arrival_text: shortageobj.carrier_arrival_text,
            carrier_text: shortageobj.carrier_text,
            date_received: shortageobj.date_received != null ? this.modedlocatdatetime(shortageobj.date_received) : shortageobj.date_received,
            is_b_whs_kit: shortageobj.is_b_whs_kit,
            is_long_term: shortageobj.is_long_term,
            is_ship_short: shortageobj.is_ship_short,
            remarks: shortageobj.remarks,
            planner_code: shortageobj.planner_code,
            shortage_cause_id: shortageobj.shortage_cause_id != null ? shortageobj.shortage_cause_id.toString() : null,
            tracking: shortageobj.tracking,
            vendor_name: shortageobj.vendor_name,
            vendor_number: shortageobj.vendor_number,
            bus_start_date: shortageobj.bus_start_date,
            bus_seq_in_day: shortageobj.bus_seq_in_day,
            current_line_location: shortageobj.current_line_location,
            currentlocation_available: currentlocationavailable,
            current_line_location_sort: (shortageobj.current_line_location == null || shortageobj.current_line_location == '9999') ? 'zzzz' : shortageobj.current_line_location,
            buspart_no_sort: shortageobj.buspart_no == null ? "" : shortageobj.buspart_no,
            vendor_name_sort: shortageobj.vendor_name == null ? "" : shortageobj.vendor_name,
            date_received_sort: shortageobj.date_received == null ? "" : shortageobj.date_received,
            status_bgcolor: this.getStatusColor(shortageobj.discrepancy_status),
            ship_short_pco: shortageobj.ship_short_pco
          };
          modshortagesList.push(moddedshortage);
        }
        shortageslist.push(...modshortagesList);
        var modifiedshortagesList = [];
        for (var i in shortageslist) {
          modifiedshortagesList.push(shortageslist[i]);
        }
        if (this.shortgecauselist.length > 1) {
          for (var item in modifiedshortagesList) {
            if (modifiedshortagesList[item].shortage_cause_id != null) {
              for (var entry in this.shortgecauselist) {
                if (modifiedshortagesList[item].shortage_cause_id == this.shortgecauselist[entry].value) {
                  modifiedshortagesList[item]['shortage_cause_value'] = this.shortgecauselist[entry].label;
                }
              }
            }
          }
        }
        this.modifiedshortageslist = modifiedshortagesList;
        this.allshortages = modifiedshortagesList;
        if (this.scrolltoTop) {
          let discrepacydblistElement = this.template.querySelector('.opcontentbody');
          discrepacydblistElement.scrollTop = 0;
        }
        this.showSpinner = false;
        this.error = undefined;
        //
      })
      .catch(error => {
        this.error = error;
        this.showmessage('Data fetch failed.', 'Something unexpected occured. Please try again or contact your Administrator.', 'error');
      });

  }

  @track allshortages;
  @track shortgecauselist = [{ "label": "None", "value": "null" }];
  //To load the partshortage cause list
  loadpartshotcauselist() {
    if (this.shortgecauselist.length == 1) {
      getPartshortagecauselist()
        .then(data => {
          if (data.isError) {
            this.showmessage('Sorry we could not fetch the Shortage Cause List operation.',
              'Something unexpected occured. Please try again or contact your Administrator.',
              'error');
          }
          else {
            var causelist = JSON.parse(data.responsebody).data.shortagecauses;
            var modifiedcauselist = [{ "label": "None", "value": "null" }];
            for (var item in causelist) {
              causelist[item]['label'] = causelist[item].shortage_cause_name;
              causelist[item]['value'] = causelist[item].shortage_cause_id.toString();
              modifiedcauselist.push(causelist[item]);
            }
            this.shortgecauselist = modifiedcauselist;
          }

        }).catch(error => {
          this.error = error;
          this.showmessage('Sorry we could not complete Shortage Cause List operation.',
            'Something unexpected occured. Please try again or contact your Administrator.',
            'error');
        });
    }
  }



  // Update PROD list with users not in scheduled
  updateprodlistwithall(selectedprod, allprod) {
    function checkifexisting(element, searcharray) {
      var elementexisting = true;
      for (var i in searcharray) {
        if (searcharray[i].Id == element) {
          elementexisting = false;
        }
      }
      return elementexisting;
    }
    var updatedprodlist = [];
    if (allprod != undefined && allprod.length != 0) {
      updatedprodlist = JSON.parse(JSON.stringify(allprod));
    }
    if (selectedprod != undefined && selectedprod.length != 0) {
      for (var i in selectedprod) {
        if (checkifexisting(selectedprod[i].Id, updatedprodlist)) {
          updatedprodlist.push(selectedprod[i]);
        }
      }
    }
    return updatedprodlist;
  }

  // Capitalize string passe
  capitalize(text) {
    if (typeof text !== "string") return "";
    return text.charAt(0).toUpperCase() + text.slice(1);
  }

  // Set date format for searching
  getformatedsearchformat(datetoformat) {
    var formatteddate = undefined;
    if (datetoformat != undefined) {
      formatteddate = new Date(datetoformat);
      var month = formatteddate.getMonth() + 1;
      var newmonth = month <= 9 ? "0" + month : month;
      var date = formatteddate.getDate();
      var newdate = date <= 9 ? "0" + date : date;
      var year = formatteddate.getFullYear();
      return `${year}-${newmonth}-${newdate}`;
    } else {
      return undefined;
    }
  }

  // Get stringified modded date
  getmoddeddate(date) {
    var formatteddate = undefined;
    if (date != undefined) {
      var jsdate = new Date(date);
      var hours = jsdate.getHours();
      var minutes = jsdate.getMinutes();
      var ampm = hours >= 12 ? "PM" : "AM";
      hours = hours % 12;
      hours = hours ? hours : 12; // the hour '0' should be '12'
      minutes = minutes < 10 ? "0" + minutes : minutes;
      var strTime = hours + ":" + minutes + " " + ampm;
      return (
        jsdate.getMonth() +
        1 +
        "/" +
        jsdate.getDate() +
        "/" +
        jsdate.getFullYear() +
        ", " +
        strTime
      );
    }
    return formatteddate;
  }

  // To modify userlist for Display purposes.
  modifyuserlistfordisplay(userlist) {
    var newuserlist = [];
    if (userlist.length != 0 && userlist != undefined) {
      for (var count in userlist) {
        var user = userlist[count];
        if (user != undefined) {
          var name = `${user.first_name} ${user.last_name}`; // 
          var dispname = `${user.first_name} ${user.last_name} (${user.employee_number})`;
          var emp_id = `${user.employee_number}`;
          var initials = name.match(/\b\w/g) || [];
          initials = (
            (initials.shift() || "") + (initials.pop() || "")
          ).toUpperCase();
          var newuser = {
            Id: user.employee_id,
            Name: `${user.first_name} ${user.last_name} (${user.employee_number})`,
            name: `${user.first_name} ${user.last_name} (${user.employee_number})`,
            fullname: name,
            displayname: dispname,
            empid: emp_id,
            userid: user.employee_id,
            piclink: "",
            username: user.appuser_name,
            intials: initials
          };
          newuserlist.push(newuser);
        }
      }
    }
    return newuserlist;
  }

  // To get the forman details in a list format from API structure.
  getselectedformandetails(discrepancyobj) {
    var users = [];
    for (var i = 0; i < 5; i++) {
      if (discrepancyobj[`forman${i + 1}_id`] != undefined) {
        users.push(discrepancyobj[`forman${i + 1}_id`]);
      }
    }
    return this.modifyuserlistfordisplay(users);
  }

  // To sort Normal Discrepancy Table
  sortdiscrepancytable(event) {
    var previousSorted = this.previousColumn;
    if (previousSorted != undefined) {
      if (event.currentTarget.dataset.id != previousSorted) {
        const element = this.template.querySelector(
          '[data-id="' + previousSorted + '"]'
        );
        element.iconName = "";
        this.previousColumn = event.currentTarget.dataset.id;
      } else {
        this.previousColumn = event.currentTarget.dataset.id;
      }
    } else {
      this.previousColumn = event.currentTarget.dataset.id;
    }

    if (this.sortedColumn === event.currentTarget.dataset.id) {
      this.sortedDirection = this.sortedDirection === "asc" ? "desc" : "asc";
    } else {
      this.sortedDirection = "asc";
    }
    var reverse = this.sortedDirection === "asc" ? 1 : -1;
    let table = JSON.parse(JSON.stringify(this.allshortages));
    table.sort((a, b) => {
      return a[event.currentTarget.dataset.id] >
        b[event.currentTarget.dataset.id]
        ? 1 * reverse
        : -1 * reverse;
    });
    this.modifiedshortageslist = table;
    this.sortedColumn = event.currentTarget.dataset.id;

    if (this.sortedDirection === "asc") {
      event.target.iconName = "utility:chevronup";
    }
    if (this.sortedDirection === "desc") {
      event.target.iconName = "utility:chevrondown";
    }
  }

  // To load picklist values for view on request.
  loadpicklistvalues(event) {
    var options = [];
    if (event.target.options.length == 1) {
      for (var i in this.departmentIdMap) {
        if (this.departmentIdMap[i].value != 'None') {
          options.push(this.departmentIdMap[i]);
        }
      }
      this.departmentlist = options;
    }
  }

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
        this.showSpinner = true;
        const alertmessage = new ShowToastEvent({
          title: 'Department data fetch failed.',
          message: 'Something unexpected occured. Please contact your Administrator',
          variant: 'error'
        });
        this.dispatchEvent(alertmessage);
      });
  }

  // Handle Department Change
  handledepartmentchange(event) {
    this.selecteddepartement = event.detail.value;
    this.applyfilter();
  }

  // Handle Shortage status Change
  handleshortgstatuschange(event) {
    this.selectedstatus = event.detail.value;
    this.applyfilter();
  }

  // Handle Defect Change
  handledisctypechange(event) {
    this.selectedbuyer = event.detail.value;
    this.applyfilter();
}


  handlecreateddatechange(event) {
    this.selectedcreatedddate = this.getformatedsearchformat(
      event.target.value
    );
  }

  // On Customer Name/Chasis Number selection
  oncustomerselection(event) {
    if (event.detail.labelvalue == "Customer") {
      this.selectedCustomer = event.detail.selectedRecord;
      this.applyfilter();
    }
  }

  // On clearing the customer selection.
  onclearcustomer(event) {
    this.selectedCustomer = undefined;
    this.applyfilter();
  }


  @track shipshortfilter;
  //handle toggle button change for shipshort filter
  onshipshortselection(event) {
    this.shipshortfilter = event.target.checked;
    this.applyfilter();
  }

  // On selecting created by user filter
  oncreatedbyselect(event) {
    if (event.detail.labelvalue == "Created By") {
      var user = event.detail.selectedRecord;
      this.selectedcreatedbyuser = this.usermaplist.get(user);
    }
    this.applyfilter();
  }

  // On clearing the created by user selection.
  onclearcreatedby(event) {
    this.selectedcreatedbyuser = undefined;
    this.applyfilter();
  }  

  //To get all Ecard Details from Server
  getAllEcarddetails(event) {
    getAllEcarddetailsfromServer()
      .then((result) => {
        var ecards = JSON.parse(result.response).data.ecard;
        var ecardoptions = [];
        for (var ec in ecards) {
          var ecardopt = {
            label: `${ecards[ec].chassis_no} (${ecards[ec].customer_name})`,
            value: ecards[ec].ecard_id.toString()
          };
          ecardoptions.push(ecardopt);
        }
        this.ecardoptions = ecardoptions;
        var ecardnamelist = [];
        for (var ecard in this.ecardoptions) {
          ecardnamelist.push(this.ecardoptions[ecard].label);
        }
        this.ecardnamechasislist = ecardnamelist;
      })
      .catch((error) => {
        const alertmessage = new ShowToastEvent({
          title: "Failed to fetch list of Bus.",
          message:
            "Something unexpected occured. Please contact your Administrator",
          variant: "error"
        });
        this.dispatchEvent(alertmessage);
      });
  }  

  @track buildstationrequired = true;

    
  // To Update the responsebody with selected formanIds from List Views.
  updateformans(responsebody, formanlist) {
    var newresponse = JSON.parse(responsebody);
    var newformanlist;
    if (formanlist.length > 5) {
      newformanlist = formanlist.slice(0, 5);
    } else {
      newformanlist = formanlist;
    }
    for (var i = 0; i < newformanlist.length; i++) {
      newresponse[`forman${i + 1}_id`] = newformanlist[i].userid;
    }
    return newresponse;
  }

  // Get Department picklist from server
  getdepartmentPicklist(event) {
    var authorisationdata = "Parameter to be removed from Apex Class";
    getDepartmentdata({ authdata: authorisationdata })
      .then((result) => {
        var departmentlistvalues = result.departmentPickList;
        var deptpickvalues = [];
        for (var dept in departmentlistvalues) {
          var deprtmentopt = departmentlistvalues[dept];
          if (deprtmentopt.value != 'None') {
            deptpickvalues.push(deprtmentopt);
          }
        }
        this.departmentoptions = deptpickvalues;
      })
      .catch((error) => {
        const alertmessage = new ShowToastEvent({
          title: "Department data fetch failed.",
          message:
            "Something unexpected occured. Please contact your Administrator",
          variant: "error"
        });
        this.dispatchEvent(alertmessage);
      });
  }

  // To modify the userlist from API to shown in userlistIconComponent.(Will need to incorporate picture link.)
  // List structure needs to contain [first_name, employee_id, appuser_name]
  // List returned will be of contain [name, userid, piclink, username, intials]
  getmodifiediserlist(userlist) {
    var newuserlist = [];
    if (userlist.length != 0) {
      for (var count in userlist) {
        var user = userlist[count];
        var name = `${user.first_name} ${user.last_name}`;
        var dispname = `${user.first_name} ${user.last_name} (${user.employee_number})`;
        var emp_id = `${user.employee_number}`;
        var initials = name.match(/\b\w/g) || [];
        initials = (
          (initials.shift() || "") + (initials.pop() || "")
        ).toUpperCase();
        var newuser = {
          Name: user.name,
          name: user.name,
          fullname: name,
          displayname: dispname,
          empid: emp_id,
          Id: user.employee_id,
          userid: user.employee_id,
          piclink: "",
          username: user.appuser_name,
          intials: initials
        };
        newuserlist.push(newuser);
      }
    }
    return newuserlist;
  }

  // To get Complete Defect List from API.
  fetchcompletedefectList(event) {
    if (this.defectlist.length == 1) {
      getCompleteDefectCodes()
        .then((data) => {
          if (data.isError) {
            this.error = error;
            const alertmessage = new ShowToastEvent({
              title: "Defect Data fetch failed.",
              message:
                "Something unexpected occured. Please contact your Administrator",
              variant: "error"
            });
            this.dispatchEvent(alertmessage);
          }
          else {
            var alldefects = JSON.parse(data.responsebody).data.defects;
            var alldefectcodes = [{ label: "All Defects", value: "All Defects" }];
            for (var defect in alldefects) {
              if (alldefects[defect].is_active) {
                var option = {
                  label:
                    alldefects[defect].defect_code +
                    ", " +
                    alldefects[defect].defect_name,
                  value: alldefects[defect].dat_defect_code_id.toString(),
                  defectname: alldefects[defect].defect_name,
                  defecttype: alldefects[defect].defect_type
                };
                alldefectcodes.push(option);
                if (alldefects[defect].defect_type != "paint") {
                  this.otherdefects.push(option);
                } else {
                  this.paintdefects.push(option);
                }
              }
            }
            this.defectlist = alldefectcodes;
          }
        })
        .catch((error) => {
          this.error = error;
          const alertmessage = new ShowToastEvent({
            title: "Defect Data fetch failed.",
            message:
              "Something unexpected occured. Please contact your Administrator",
            variant: "error"
          });
          this.dispatchEvent(alertmessage);
        });
    }

  }

  // To modify defect picklist values based on Department Selection
  moddifydefectpickvalues(deptcode) {
    var defecttype = 'department';
    var deptlist = JSON.parse(JSON.stringify(this.departmentoptions));
    for (var i in deptlist) {
      if (deptlist[i].value === deptcode.toString()) {
        defecttype = deptlist[i].defect_type;
      }
    }
    if (defecttype == 'paint') {
      this.defectoptions = this.paintdefects;
    } else {
      this.defectoptions = this.otherdefects;
    }
  }

  // For getting Buildstation Details on department/ecardId change for new Discrepancy.
  getcompleteBuilstationlist(data) {
    let workstationdata = data.builstationMapWrapper.workcenter;
    var prod_supervisor = this.modifyuserlistfordisplay(
      data.builstationMapWrapper.prod_supervisor
    );
    this.deptsupervisorforselecteddept = prod_supervisor;
    let modifiedworkstationdata = [];
    var QC = this.modifyuserlistfordisplay(data.builstationMapWrapper.qc);
    if (workstationdata.length != 0) {
      for (var wc in workstationdata) {
        let workcentre = workstationdata[wc];
        let workcenter_id = workcentre.workcenter_id;
        let workcentername = workcentre.workcentername;
        for (var bs in workcentre.buildstation) {
          var buildstation = workcentre.buildstation[bs];
          var PROD = this.modifyuserlistfordisplay(buildstation.prod);
          var selectedprod = this.getselectedformandetails(buildstation);
          var selectedqc = this.modifyuserlistfordisplay([
            buildstation.qc_approvedby_id
          ]);
          var modifiedwsdata = {
            workcenter_id: workcenter_id,
            ecard_operation_log_id: buildstation.ecard_operation_log_id,
            workcentername: workcentername,
            operation: buildstation.operation,
            hasdescrepancy:
              buildstation.has_descrepancy != undefined
                ? buildstation.has_descrepancy
                : false,
            buildstation_id: buildstation.buildstation_id,
            buildstation_code: buildstation.buildstation_code,
            selectedprod: selectedprod,
            selectedqc: selectedqc,
            PRODlist: PROD,
            QClist: QC
          };
          modifiedworkstationdata.push(modifiedwsdata);
        }
      }
    }
    return modifiedworkstationdata;
  }


  get disablevendorselection() {
    return this.partsvendorslist.length == 0;
  }


  get disablebuyercode() {
    return this.newpartshortage.buyer_code == undefined;
  }
  //TO disable the selected part shortage fields from edit
  get disableeditshortage() {
    return this.permissionset.shortage_update.write != true || this.selectedshortage.discrepancy_status.toLowerCase() != "open"; //corrected
  }

  //to display shortage details
  @track selectedshortage;
  @track partshortagedetailsmodal = false;
  // To Show Part Shortage Detail
  async showpartshortagedetail(event) {
    this.isupdated = false;
    var selectepartshortagelogid = event.currentTarget.dataset.id;
    for (var i in this.modifiedshortageslist) {
      if (this.modifiedshortageslist[i].ecard_discrepancy_log_id == selectepartshortagelogid) {
        this.selectedshortage = Object.assign({}, this.modifiedshortageslist[i]);
      }
    }
    if (this.selectedshortage.allprodlist.length == 0) {
      var userdetails = [];
      await getcrewingsuserslist({ deptid: this.selectedshortage.departmentid })
        .then((result) => {
          userdetails = JSON.parse(result.responsebody).data.user;
          userdetails = this.removeDuplicates(userdetails);//todo
          this.selectedshortage.allprodlist = userdetails.length > 0 ? modifieduserlist(userdetails) : userdetails;
        })
        .catch((error) => {
        });
    }
    this.getselecteddiscrepancycomments(selectepartshortagelogid);
    this.getVendorlistforparts(this.selectedshortage.buspart_no);
    if (this.selectedshortage.vendor_name == null) { //to-do list in partsvendor list
      this.getPartsVendorBuyerDetails(this.selectedshortage.buspart_no, this.selectedshortage);
    }
  
    if (this.selectedshortage.buyer != null && this.selectedshortage.planner_code != null) {
      this.selectedshortage.buyer_code = this.selectedshortage.buyer;
      
    }
    this.isdelenabled = false;
    if (this.selectedshortage.isdeletable || (this.permissionset.shortage_delete.write && this.selectedshortage.discrepancy_status.toLowerCase() == 'open')) {
      this.isdelenabled = true;
    }
    this.partshortagedetailsmodal = true;

  }

  // To Hide Part Shortage Detail.
  hidepartshortagedetail(event) {
    this.partshortagedetailsmodal = false;
  }

  // Update selected shortage fields.
  updateselectedshortage(event) {
    this.isupdated = true;
    var targetvalue;
    if (event.target.type == "checkbox") {
        targetvalue = event.target.checked;
        if (targetvalue) {
            this.selectedshortage.ship_short_pco;
            if(event.target.name == "is_ship_short"){ 
              this.selectedshortage.date_received = new Date().toISOString();
            }
        } else {
          if(event.target.name == "is_ship_short"){ 
            this.selectedshortage.date_received = null;
          }
        }
    } else if (event.target.type == "date") {
        targetvalue = this.getLocaldatetime(event.target.value);
    } else {
        targetvalue = event.target.value;
    }
    var targetname = event.target.name;
    this.selectedshortage[targetname] = targetvalue;
    this.updatedisable = false;
}


  updatepartshortage(event) {
  //newly added by sathish for auto resolve status while date received is populated
    if(this.selectedshortage.date_received !== null && this.selectedshortage.is_ship_short == true && this.selectedshortage.discrepancy_status != 'resolve'){
      this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('resolve');
      this.selectedshortage.discrepancy_status = 'resolve';
      this.statusascomment = true;
    }
    else if(this.selectedshortage.date_received == null && this.selectedshortage.is_ship_short == false && this.selectedshortage.discrepancy_status != 'open'){ 
      this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('open'); 
      this.selectedshortage.discrepancy_status = 'open'; 
      this.statusascomment = true; 
    }
  //end
    this.updatepartshortagetoserver(event, true);
  }

  updateuserpartshortage(event) {
    var detail = event.detail;
    if (detail.type == 'QC') {
      this.selectedshortage.assigend_qc_id = detail.userlist;
    }
    if (detail.type == 'PROD') {
      this.selectedshortage.assignedprod = detail.userlist;
    }
    this.updatepartshortagetoserver(event, false);
  }

  // Handle actions from Part Shortage Detail modal.
  handlepartshortageactions(event) {
    var action = event.detail.action;
    var passedallvalidation = true;
    if (action == "Reject") {
      this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('open'); // reject
      this.selectedshortage.discrepancy_status = 'open'; //reject
      this.qccaptureaction = true;
    }
    if (action == 'Verify') {
      this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('approve');
      this.selectedshortage.discrepancy_status = 'approve';
      this.qccaptureaction = true;
    }
    if (action == 'Mark as done') {
      const allValid = [
        ...this.template.querySelectorAll(".shipshortvalid, .checkvalid")
      ].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);
      if (allValid) {
        this.qccaptureaction = false;
        this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('resolve');
        this.selectedshortage.discrepancy_status = 'resolve';
        this.isdelenabled = false;
        this.selectedshortage.isdeletable = false;
      } else {
        passedallvalidation = false;
        const alertmessage = new ShowToastEvent({
          title: "Fill all required fields.",
          message: "Please fill in all the required fields..",
          variant: "warning"
        });
        this.dispatchEvent(alertmessage);
      }
    }
    if (action == 'Cancel') {
      this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('open');
      this.selectedshortage.discrepancy_status = 'open';
      this.qccaptureaction = true;
    }
    if (action == 'Cancel Verified') {
      this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('resolve');
      this.selectedshortage.discrepancy_status = 'resolve';
      this.qccaptureaction = true;
    }
    if (action == 'Cancel Rejected') {
      this.selectedshortage.discrepancy_statusdisplay = setstatusfordisplay('resolve');
      this.selectedshortage.discrepancy_status = 'resolve';
      this.qccaptureaction = true;
    }
    if (passedallvalidation) {
      this.statusascomment = true;
      this.updatepartshortagetoserver(event, false);
    }
  }

  // To update the Part Shortage changes to server.
  updatepartshortagetoserver(event, closeModal) {
    const allValid = [
      ...this.template.querySelectorAll(".shipshortvalid, .checkvalid")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    if (allValid) {
      var discrepancytobeupdated = this.selectedshortage;
      var part_shortage;
      if (discrepancytobeupdated.buspart_no == 'Part No. Not Found') {
        part_shortage = {
          "buspart_id": null,
          "quantity": discrepancytobeupdated.quantity,
          "po_no": discrepancytobeupdated.po_no,
          "custom_part_name": discrepancytobeupdated.buspart_name,
          "part_shortage_id": discrepancytobeupdated.part_shortage_id
        };
      }
      else {
        part_shortage = {
          "buspart_id": discrepancytobeupdated.buspart_id,
          "quantity": discrepancytobeupdated.quantity,
          "po_no": discrepancytobeupdated.po_no,
          "part_shortage_id": discrepancytobeupdated.part_shortage_id
        };
      }
      part_shortage['buyer'] = discrepancytobeupdated.buyer == undefined ? null : discrepancytobeupdated.buyer;
      part_shortage['planner_code'] = discrepancytobeupdated.planner_code == undefined ? null : discrepancytobeupdated.planner_code;
      part_shortage['vendor_number'] = discrepancytobeupdated.vendor_number == undefined ? null : discrepancytobeupdated.vendor_number;
      if (discrepancytobeupdated.vendor_name == undefined) {
        if (this.partsvendorslist.length > 0) {
          part_shortage['vendor_name'] = this.partsvendorslist[0].vendor_name;
          part_shortage['vendor_number'] = this.partsvendorslist[0].vendor_number;
        }
        else
          part_shortage['vendor_name'] = null;
      }
      else {
        part_shortage['vendor_name'] = discrepancytobeupdated.vendor_name;
      }
      part_shortage['carrier_text'] = discrepancytobeupdated.carrier_text == 'null' ? null : discrepancytobeupdated.carrier_text;
      part_shortage['carrier_arrival_text'] = discrepancytobeupdated.carrier_arrival_text == undefined ? null : discrepancytobeupdated.carrier_arrival_text;
      part_shortage['shortage_cause_id'] = discrepancytobeupdated.shortage_cause_id == 'null' ? null : discrepancytobeupdated.shortage_cause_id;
      part_shortage['tracking'] = discrepancytobeupdated.tracking == undefined ? null : discrepancytobeupdated.tracking;
      part_shortage['date_received'] = discrepancytobeupdated.date_received == undefined ? null : discrepancytobeupdated.date_received;
      part_shortage['is_b_whs_kit'] = discrepancytobeupdated.is_b_whs_kit == undefined ? null : discrepancytobeupdated.is_b_whs_kit;
      part_shortage['is_long_term'] = discrepancytobeupdated.is_long_term == undefined ? null : discrepancytobeupdated.is_long_term;
      part_shortage['is_ship_short'] = discrepancytobeupdated.is_ship_short == undefined ? null : discrepancytobeupdated.is_ship_short;
      part_shortage['remarks'] = discrepancytobeupdated.remarks == undefined ? null : discrepancytobeupdated.remarks;
      part_shortage['ship_short_pco'] = discrepancytobeupdated.ship_short_pco;
      var responsebody = {
        "ecard_discrepancy_log_id": discrepancytobeupdated.ecard_discrepancy_log_id,
        "ecard_id": discrepancytobeupdated.ecard_id,
        "department_id": discrepancytobeupdated.department_id,
        "component": discrepancytobeupdated.component,
        "cut_off_date": discrepancytobeupdated.cut_off_date != null ? discrepancytobeupdated.cut_off_date : discrepancytobeupdated.cut_off_date,
        "root_cause": discrepancytobeupdated.root_cause,
        "discrepancy_status": discrepancytobeupdated.discrepancy_status,
        "discrepancy_type": discrepancytobeupdated.discrepancy_type,
        "discrepancy": discrepancytobeupdated.discrepancy,
        "part_shortage": part_shortage,
        "modified_date": discrepancytobeupdated.modified_date,
        "buildstation_id": discrepancytobeupdated.buildstation_id
      };
      if (this.qccaptureaction && this.qccapturerole) {
        responsebody["assigend_qc_id"] = this.loggedinuser.employee_id;
        this.qccaptureaction = false;
      }
      var requestwithforman = this.updateformans(JSON.stringify(responsebody), discrepancytobeupdated.assignedprod);

      updatePartshortage({ requestbody: JSON.stringify(requestwithforman) })
        .then(data => {
          if (data.isError) {
            if (data.errorMessage == 202) {
              this.showmessage('Sorry we could not complete the operation.', JSON.parse(data.responsebody).data.validation_message, 'error');
              this.partshortagedetailsmodal = false;
              this.loadShortagesdata(event, true);
            }
            else {
              this.showmessage('Sorry we could not complete the operation.', 'Something unexpected occured. Please try again or contact your Administrator.', 'error');
              this.partshortagedetailsmodal = false;
              this.loadShortagesdata(event, true);
            }
          }
          else {
            this.selectedshortage['modified_date'] = JSON.parse(data.operationlogresponse).data.modified_date;
            this.isupdated = false;
            if (this.statusascomment) {
              this.statusascomment = false;
              var response = JSON.parse(data.operationlogresponse).data;
              this.addstatusasdiscrepancycomment(response.ecard_discrepancy_log_id, this.statuscommentmap[`${response.discrepancy_status.toLowerCase()}`]);
            }
            this.showmessage('Record Updated.', 'Record successfully updated.', 'success');
            this.loadShortagesdata(event, true);
            if (closeModal) {
              this.hidepartshortagedetail();
            }
          }
        }).catch(error => {
          this.error = error;
          this.showmessage('Sorry we could not complete the operation.', 'Something unexpected occured. Please try again or contact your Administrator.', 'error');
        });
    }
    else {
      const alertmessage = new ShowToastEvent({
        title: "Fill all required fields.",
        message: "Please fill in all the required fields..",
        variant: "warning"
      });
      this.dispatchEvent(alertmessage);
    }
  }

  // For Hiding the Details Modal
  hidediscrepancydetail(event) {
    this.detailsmodal = false;
  }

  // Update other fields of selected discrepancy
  updateselecteddiscrepancy(event) {
    var targetvalue = event.target.value;
    var targetname = event.target.name;
    this.selecteddiscrepancy[targetname] = targetvalue;
  }


  // Add new Comment to Discreepancy
  addnewdiscrepancycomment(event) {
    var ecarddiscrepancylogid = event.detail.uniqueId;
    var newcommentbody = {
      ecard_discrepancy_log_id: event.detail.uniqueId,

      discrepancy_comments: event.detail.commenttext
    };
    addnewComment({ requestbody: JSON.stringify(newcommentbody) })
      .then((data) => {
        if (data.isError) {
          const alertmessage = new ShowToastEvent({
            title: "Failed to add Comments.",
            message:
              "Something unexpected occured. Please contact your Administrator",
            variant: "error"
          });
          this.dispatchEvent(alertmessage);
        } else {
          const alertmessage = new ShowToastEvent({
            title: "Comment saved successfully.",
            message: "Your Comment was recorded successfully.",
            variant: "success"
          });
          this.dispatchEvent(alertmessage);
          this.getselecteddiscrepancycomments(ecarddiscrepancylogid);
        }
      })
      .catch((error) => {
        const alertmessage = new ShowToastEvent({
          title: "Failed to add Comments.",
          message:
            "Something unexpected occured. Please contact your Administrator",
          variant: "error"
        });
        this.dispatchEvent(alertmessage);
      });
  }

  // Add the discrepancy status change as comment
  addstatusasdiscrepancycomment(discrepancylogid, commenttext) {
    var ecarddiscrepancylogid = discrepancylogid;
    var newcommentbody = {
      "ecard_discrepancy_log_id": discrepancylogid,
      "discrepancy_comments": commenttext
    };
    addnewComment({ requestbody: JSON.stringify(newcommentbody) })
      .then(data => {
        if (data.isError) {
          this.showmessage('Failed to add Comments.', 'Something unexpected occured. Please contact your Administrator.', 'error');
        }
        else {
          this.getselecteddiscrepancycomments(ecarddiscrepancylogid);
        }
      })
      .catch(error => {
        this.showmessage('Failed to add Comments.', 'Something unexpected occured. Please contact your Administrator.', 'error');
      });
  }

  // Get Comments of selected discrepancy
  getselecteddiscrepancycomments(selecteddiscrepancylogid) {
    var requesthead = selecteddiscrepancylogid.toString();
    getAllComments({ discrepancylogid: requesthead })
      .then((data) => {
        if (data.isError) {
          const alertmessage = new ShowToastEvent({
            title: "Failed to fetch Comments.",
            message:
              "Something unexpected occured. Please contact your Administrator",
            variant: "error"
          });
          this.dispatchEvent(alertmessage);
        } else {
          var commentsresponse = JSON.parse(data.response).data
            .discrepancycomments;
          var commentlist = [];
          if (commentsresponse.length != 0) {
            for (var comment in commentsresponse) {
              var com = commentsresponse[comment];
              if (
                com.commentedby_id != null &&
                com.commentedby_id != undefined
              ) {
                var name = `${com.commentedby_id.first_name} ${com.commentedby_id.last_name}`;
                var dispname = `${com.commentedby_id.first_name} ${com.commentedby_id.last_name} (${com.commentedby_id.employee_number})`;
                var emp_id = `${com.commentedby_id.employee_number}`;
                var initials = name.match(/\b\w/g) || [];
                initials = (
                  (initials.shift() || "") + (initials.pop() || "")
                ).toUpperCase();
                var moddedcomment = {
                  created_by: name,
                  initials: initials,
                  fullname: name,
                  displayname: dispname,
                  empid: emp_id,
                  commentedbyid: com.commentedby_id.employee_number,
                  commentedusername: com.commentedby_id.appuser_name,
                  commenttext: com.discrepancy_comments,
                  ecard_discrepancy_comments_id:
                    com.ecard_discrepancy_comments_id,
                  created_date: com.created_date
                };
                commentlist.push(moddedcomment);
              }
            }
          }
          this.selecteddiscrepancycomments = commentlist;
        }
      })
      .catch((error) => {
        const alertmessage = new ShowToastEvent({
          title: "Failed to fetch Comments.",
          message:
            "Something unexpected occured. Please contact your Administrator",
          variant: "error"
        });
        this.dispatchEvent(alertmessage);
      });
  }

  deletediscshortage(event) {
    var status = confirm("Issue/Shortage once deleted can not be retrieved. Are you sure you want to continue this action?");
    var discrepancyid = event.target.name;
    if (status) {
      var datatodelete = {
        id: JSON.stringify(discrepancyid)
      };
      deleteDiscOrShortage({ requestbody: JSON.stringify(datatodelete) })
        .then((data) => {
          if (data.isError) {
            const alertmessage = new ShowToastEvent({
              title: "Sorry we could not complete the operation.",
              message:
                "Something unexpected occured. Please contact your Administrator",
              variant: "error"
            });
            this.dispatchEvent(alertmessage);
          } else {
            const alertmessage = new ShowToastEvent({
              title: " Success",
              message: "Issue/Shortage deleted successfully.",
              variant: "success"
            });
            this.dispatchEvent(alertmessage);
            this.loadShortagesdata(event, true);
            this.partshortagedetailsmodal = false;
          }
        })
        .catch((error) => {
          this.error = error;
          const alertmessage = new ShowToastEvent({
            title: "Sorry we could not complete the operation.",
            message:
              "Something unexpected occured. Please contact your Administrator",
            variant: "error"
          });
          this.dispatchEvent(alertmessage);
        });
    }

  }

  // Generic function to Show alert toasts.
  showmessage(title, message, variant) {
    const alertmessage = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(alertmessage);
  }

  get disablecomponentdates() {
    return this.selecteddiscrepancy.discrepancy_status.toLowerCase() != "open";
  }


  activeSections = ["Details"];
  // For toogle sections within modal
  togglesection(event) { }


  @track showpreviewimage = false;
  @track previewimageexist = false;
  @track discrepancyimage;
  @track parentdivdimensions;
  @track showspinnerwithmodal = false;



  @track s3tempurlfornewdiscrepancy = [];


  deletetempattachments(event) {
    if (this.s3tempurlfornewdiscrepancy.length != 0) {
      var requestbody = {
        "s3_file_paths": JSON.stringify(this.s3tempurlfornewdiscrepancy)
      };
      deleteTempAttachment({ requestbody: JSON.stringify(requestbody) })
        .then(data => {
          if (data.isError) {
            const alertmessage = new ShowToastEvent({
              title: 'Sorry we could not complete the operation.',
              message: 'Something unexpected occured. Please contact your Administrator',
              variant: 'error'
            });
            this.dispatchEvent(alertmessage);

          }
          else {
            //Should we show a toast message for deleteing temp attachment ?
          }

        }).catch(error => {
          this.error = error;
          const alertmessage = new ShowToastEvent({
            title: 'Sorry we could not complete the operation.',
            message: 'Something unexpected occured. Please contact your Administrator',
            variant: 'error'
          });
          this.dispatchEvent(alertmessage);
        });


    }
  }

  //Added to refresh the Discrepancydblist after adding new Discrepancy
  refreshDiscrepancy(event) {
    this.loadShortagesdata(event, false);
  }

  // used to load the busStatus picklist
  loadstatuspicklistvalues(event) {
    var picklistname = event.target.name;
    if (event.target.options.length == 1) {
      getStatusPicklistOptions({ picklistName: picklistname })
        .then((data) => {
          if (data.isError) {
            const alertmessage = new ShowToastEvent({
              title: "Picklist data value failed to fetch.",
              message:
                "Something unexpected occured. Please contact your Administrator",
              variant: "error"
            });
            this.dispatchEvent(alertmessage);
            throw "Data fetch failed";
          } else {
            var options = data.options;
            if (picklistname == 'busstatus') {
              for (var i = 0; i < options.length; i++) {
                if (options[i].value === 'Sold') {
                  options.splice(i, 1);
                }
              }
              this.busstatuslist = options;
            }
          }
        })
        .catch((error) => {
          this.error = error;
          const alertmessage = new ShowToastEvent({
            title: "Picklist data value failed to fetch.",
            message:
              "Something unexpected occured. Please contact your Administrator",
            variant: "error"
          });
          this.dispatchEvent(alertmessage);
        });
    }
  }
  // To handle  when filter on Bus Status is selected.
  handlebusstatuschange(event) {
    this.selectedBusStatus = event.detail.value;
    this.applyfilter();
    this.getEcardandCustomerforSearch();
  }

  getdepartmentcode(departmentid, departmentIdMap) {
    var departmentcode = '-';
    for (var i in departmentIdMap) {
      if (departmentIdMap[i].value != 'None' && departmentIdMap[i].label != 'ALL DEPARTMENTS') {
        if (departmentIdMap[i].value == departmentid.toString()) {
          var departmentname = departmentIdMap[i].label;
          departmentcode = departmentname.split('-')[0];
        }
      }
    }
    return departmentcode;
  }

  
  @track partsvendorslist = [];
  @track vendornamelist = [];
  //to get default vendor and buyers details for selected part
  getVendorlistforparts(selectedpartno) {
    getAllpartsVendorlist({ partNumber: selectedpartno })
      .then(data => {
        if (data.isError) {
          this.showmessage('Sorry we could not fetch Vendor List for Shortage operation.',
            'Something unexpected occured. Please try again or contact your Administrator.',
            'error');
        }
        else {
          var partsvendorlist = JSON.parse(data.responsebody).data.vendors;
          var modifiedpartsvendorlist = [];
          var vendornamelist = [];
          for (var item in partsvendorlist) {
            partsvendorlist[item]['label'] = partsvendorlist[item].vendor_name;
            partsvendorlist[item]['value'] = partsvendorlist[item].vendor_number;
            modifiedpartsvendorlist.push(partsvendorlist[item]);
            vendornamelist.push(partsvendorlist[item].vendor_name);
          }
          this.partsvendorslist = modifiedpartsvendorlist;
          this.vendornamelist = vendornamelist;
        }

      }).catch(error => {
        this.error = error;
        this.showmessage('Sorry we could not complete Vendor List for Shortage operation.',
          'Something unexpected occured. Please try again or contact your Administrator.',
          'error');
      });
  }
  //to get default vendor and buyers details for selected part is not already selected
  getPartsVendorBuyerDetails(selectedpartno, shortagedata, operation) {
    getDefaultVendorandBuyer({ partNumber: selectedpartno })
      .then(data => {
        if (data.isError) {
          this.showmessage('Sorry we could not fetch the default Buyer and Vendor details operation.',
            'Something unexpected occured. Please try again or contact your Administrator.',
            'error');
        }
        else {
          var result = JSON.parse(data.responsebody).data;
          var selectedshortage = shortagedata;
          // Only assigne if the value is not emnpty
          Object.keys(result).forEach(function (key) {
            if (result[key] != '') {
              selectedshortage[key] = result[key];
            }
          })
          this.selectedshortage = selectedshortage;
        }

      }).catch(error => {
        this.error = error;
        this.showmessage('Sorry we could not complete the default Buyer and Vendor details.',
          'Something unexpected occured. Please try again or contact your Administrator.',
          'error');
      });
  }

  // Update vendor selected in shortage
  onvendorselection(event) {
    var selectedvendor = event.detail.selectedRecord;
    this.selectedshortage.vendor_name = selectedvendor;
    this.selectedshortage.vendor_number = null;
    for (var item in this.partsvendorslist) {
      if (selectedvendor == this.partsvendorslist[item].label) {
        this.selectedshortage.vendor_number = this.partsvendorslist[item].value;
      }
    }
    if (event.detail.incident == 'selection') {
      this.updatepartshortage(event);//timer triggered
    }
  }

  // On clearing the vendor selection. added
  onclearvendor(event) {
    this.selectedshortage.vendor_name = null;
    this.selectedshortage.vendor_number = null;
    this.updatepartshortage(event);//timer triggered commented to allow manual entry
  }

  // To update new shortage checkbox
  updatenewpartshortagecheckbox(event) {
    var targetvalue = event.target.checked;
    var targetname = event.target.name;
    this.newpartshortage[targetname] = targetvalue;
  }

  //To clear partvendor and buyer details
  clearpartsvendordetails() {
    this.newpartshortage['buyer'] = undefined;
    this.newpartshortage['planner_code'] = undefined;
    this.newpartshortage['vendor_number'] = undefined;
    this.newpartshortage['buyer_code'] = undefined;
    this.newpartshortage['vendor_name'] = undefined;
    this.partsvendorslist = [];
  }
  //To create custome date formate 2021-07-14 to 2021-07-14 00:00:00
  modifydate(date) {
    var formatteddate = undefined;
    if (date != undefined) {
      var jsdate = new Date(date);
      return jsdate;
    }
    return formatteddate;
  }
  //removeduplicate user
  removeDuplicates(objectArray) {
    // Declare a new array
    let newArray = [];
    // Declare an empty object
    let uniqueObject = {};
    var objTitle;
    // Loop for the array elements
    for (let item in objectArray) {
      // Extract the title
      objTitle = objectArray[item]['appuser_name'];
      // Use the title as the index
      uniqueObject[objTitle] = objectArray[item];
    }
    // Loop to push unique object into array
    for (let item in uniqueObject) {
      newArray.push(uniqueObject[item]);
    }
    // Display the unique objects
    return newArray;
  }

  getStatusColor(status) {
    var discrepancycolor = '';
    if (status.toLowerCase() == 'resolve') {
      discrepancycolor = '#e8bb07';
    }
    if (status.toLowerCase() == 'approve') {
      discrepancycolor = '#34c759';
    }
    var bgColor = `background-color: ${discrepancycolor};`;
    return bgColor;
  }

  /** Added below code as part of the pagination implementation */

  @track currentPage = 1;
  @track totalRecord;
  @track size = 50;//todo
  @track totalPage = 0;
  @track paginationfilter;

  get disablepreviousbtn() {
    return this.currentPage <= 1;
  }
  get disablenextbtn() {
    return this.currentPage == this.totalPage;
  }

  resetpaginationdata() {
    this.currentPage = 1;
  }

  previoushandler(event) {
    this.currentPage = this.currentPage - 1;
    this.loadShortagesdata(event, false);
  }

  nexthandler(event) {
    this.currentPage = this.currentPage + 1;
    this.loadShortagesdata(event, false);
  }

  applyfilter() {
    this.resetpaginationdata();    
    this.applypaginationfilter();
  }

 
  applypaginationfilter(event) {
    var statuslist = [];
    var shortagestatus = [];
    if (this.selectedBusStatus != 'All Bus Status') {
      statuslist.push(this.selectedBusStatus.replaceAll(" ", "%20"));
    }
    else {
      // statuslist = null;
      statuslist = ["WIP", "Out%20of%20Factory", "Staging"];
    }
    if (this.selectedstatus != 'All Status') {
      shortagestatus.push(this.selectedstatus);
    }
    else {
      shortagestatus = null;
    }

    //workaround ends
    var statusparm = {
      page: this.currentPage,
      bus_status: statuslist,
      discrepancy_status: shortagestatus,
      search: this.selectedCustomer == undefined ? "" : this.selectedCustomer.replaceAll(" ", "%20").replaceAll("\\","%2_").replaceAll("/","%1_"),
      department_id: this.selecteddepartement == "0" ? null : Number(this.selecteddepartement),
      is_ship_short: this.shipshortfilter == false ? null : this.shipshortfilter,
      has_date_recieved: this.datereceivedfilter == false ? null : (this.datereceivedfilter).toString(),
      //  buyer: this.selectedbuyer == "All Buyer" ? null : this.selectedbuyer.replaceAll(" ", "%20"),
      buyer: this.selectedbuyer == "All Buyer" ? null : this.selectedbuyer.split(",").map(buyer => buyer.trim().replaceAll(" ", "%20")),
     createdby_id: this.selectedcreatedbyuser == undefined ? null : this.selectedcreatedbyuser,  
    };
   
    this.paginationfilter = statusparm;
    this.loadShortagesdata(event, false);
  }

  @track usersnamelist = [];
  @track usermaplist;
  getuserlistfromserver(event) {
    getallUsers()
      .then((data) => {
        var userdata = JSON.parse(data.responsebody).data.user;
        var modifieduserlist = this.modifyuserlistfordisplay(userdata);
        var usernamelist = [];
        let usermap = new Map();
        for (var index in modifieduserlist) {
          usernamelist.push(modifieduserlist[index].name);
          usermap.set(modifieduserlist[index].name, modifieduserlist[index].Id);
        }
        var uniqenamelist = new Set(usernamelist);
        this.usersnamelist = Array.from(uniqenamelist);
        this.usermaplist = usermap;
      })
      .catch((error) => {
        this.usersnamelist = undefined;
      });
  }

  @track searchnamelists = [];
  //To get ecard and customer for search from server
  getEcardandCustomerforSearch(event) {
    var statuslist = [];
    if (this.selectedBusStatus != 'All Bus Status') {
      statuslist.push(this.selectedBusStatus.replaceAll(" ", "%20"));
    }
    else{
      statuslist = ["WIP", "Out%20of%20Factory", "Staging"];
    }
    var statusparm = { bus_status: statuslist };
    getEcarddataWrapper({ status: JSON.stringify(statusparm) })
      .then((result) => {
        var ecardcustomerlist = [];
        for (var index in result.ecarddata) {
          var ecard = result.ecarddata[index];
          ecardcustomerlist.push(ecard.chassis_no);
          ecardcustomerlist.push(ecard.customer_name);
        }
        var uniqenamelist = new Set(ecardcustomerlist);
        this.searchnamelists = Array.from(uniqenamelist);
      })
      .catch((error) => {
        const alertmessage = new ShowToastEvent({
          title: "Failed to fetch list of Bus.",
          message:
            "Something unexpected occured. Please contact your Administrator",
          variant: "error"
        });
        this.dispatchEvent(alertmessage);
      });
  }

  loadbuyerpicklists() {
    getBuyerforFilterOptions()
      .then((result) => {
        var options = JSON.parse(result.operationlogresponse).data;
        if (this.buyerlist.length == 1) {
          var buyerlist = [{ label: "All Buyer", value: "All Buyer" }];
          for (var index in options) {
            if (options[index].trim() != '') {
              var option = {
                label: options[index],
                value: options[index]
              }
              buyerlist.push(option);
            }
          }
          this.buyerlist = buyerlist;
        }
      })
      .catch((error) => {
        const alertmessage = new ShowToastEvent({
          title: "Failed to fetch list of Buyers.",
          message:
            "Something unexpected occured. Please contact your Administrator",
          variant: "error"
        });
        this.dispatchEvent(alertmessage);
      });
  }

  // this method is used to converted the date formate to utc date time formate 2022-06-29T09:16:38.884472+00:00 2022-06-30T00:00:00.000Z
  getLocaldatetime(ip_date) {
    if (ip_date != undefined) {
      var tempdate = new Date();

      var hour = tempdate.getHours();
      var min = tempdate.getMinutes();
      var sec = tempdate.getSeconds();

      hour = hour >= 10 ? hour : '0' + hour;
      min = min >= 10 ? min : '0' + min;
      sec = sec >= 10 ? sec : '0' + sec;

      var timezoneoffset = tempdate.getTimezoneOffset();
      var sign = Math.sign(timezoneoffset);
      var hourOffset = Math.trunc(Math.abs(timezoneoffset) / 60);
      var minoffset = Math.abs(timezoneoffset % 60);

      sign = sign > 0 ? '-' : '+';
      hourOffset = hourOffset >= 10 ? hourOffset : '0' + hourOffset;
      minoffset = minoffset >= 10 ? minoffset : '0' + minoffset;

      var strTime = hour + ':' + min + ':' + sec + '.000' + sign + hourOffset + ':' + minoffset;
      return ip_date + 'T' + strTime;
    }
    else
      return null;
  }

  highlightRow(event) {
    const clickedRow = event.currentTarget;
    const allRows = this.template.querySelectorAll('.cellfontstyle');
    allRows.forEach(row => {
        row.classList.remove('highlight');
    });
    clickedRow.classList.add('highlight');
}

  modedlocatdatetime(date) {
    var newdate = new Date(date);
    var year = newdate.getFullYear();
    var date = newdate.getDate();
    var month = newdate.getMonth() + 1;

    date = date >= 10 ? date : '0' + date;
    month = month >= 10 ? month : '0' + month;

    var hour = newdate.getHours();
    var min = newdate.getMinutes();
    var sec = newdate.getSeconds();

    hour = hour >= 10 ? hour : '0' + hour;
    min = min >= 10 ? min : '0' + min;
    sec = sec >= 10 ? sec : '0' + sec;

    var timezoneoffset = newdate.getTimezoneOffset();
    var sign = Math.sign(timezoneoffset);
    var hourOffset = Math.trunc(Math.abs(timezoneoffset) / 60);
    var minoffset = Math.abs(timezoneoffset % 60);

    sign = sign > 0 ? '-' : '+';
    hourOffset = hourOffset >= 10 ? hourOffset : '0' + hourOffset;
    minoffset = minoffset >= 10 ? minoffset : '0' + minoffset;

    var strTime = hour + ':' + min + ':' + sec + '.000' + sign + hourOffset + ':' + minoffset;

    return year + '-' + month + '-' + date + 'T' + strTime;
  }

  get isshipshortenabled() {
    return this.selectedshortage.is_ship_short == true;
  }

  //TO disable the ship short shortage fields from edit
  // get disableshipshortedit() {
  //   return this.permissionset.ship_short_shortage_update.write != true || this.selectedshortage.discrepancy_status.toLowerCase() != "open" ||
  //       this.selectedshortage.date_received != null; //corrected
       
  // }

  //to disable date recieved field edit or entry
  get disabledatereceiveedit() {
    return this.permissionset.shortage_update.write != true || this.selectedshortage.discrepancy_status.toLowerCase() != "open" ||
       this.selectedshortage.is_ship_short; //corrected
  }

  //handle toggle button change for date received filter
  @track datereceivedfilter = false;
  ondatereceivedselection(event) {
    this.datereceivedfilter = event.target.checked;
    this.applyfilter();
  }
}