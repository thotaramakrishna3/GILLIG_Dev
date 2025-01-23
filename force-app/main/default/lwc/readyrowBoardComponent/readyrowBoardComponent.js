import { LightningElement, track } from "lwc";

import getAllShortageslist from "@salesforce/apex/ShortagesDatabaseController.getEcardShortagePaginationData";

export default class ReadyrowBoardComponent extends LightningElement {
  @track count = 0;

  // @track filtereddiscrepancy = [{
  //   "customer_name" : "Rome, GA",
  //   "chassis_number" : "B093736",
  //   "coach_number" : 2503,
  //   "alignment_OP_CK" : "OK",
  //   "dyno_OP_CK" : "OK",
  //   "water_OP_CK" : "OK",
  //   "disc_count" : 5,
  //   "Shortage_name" : "16-63203-010, SIGN,DESTINATION,CURBSIDE,14x112,SMART",
  //   "ETA" : "10-10-2022",
  //   "comments" : "Needs vendor rep",
  //   "location" :"DIRT"
  //   },
  //   {
  //   "customer_name" : "",
  //   "chassis_number" : "",
  //   "coach_number" : "",
  //   "alignment_OP_CK" : "",
  //   "dyno_OP_CK" : "",
  //   "water_OP_CK" : "",
  //   "disc_count" : "",
  //   "Shortage_name" : "16-63203-010, SIGN,DESTINATION,CURBSIDE,14x112,SMART",
  //   "ETA" : "10-10-2022",
  //   "comments" : "CIS touch up" ,
  //   "location" :""
  //   },
  //   {
  //   "customer_name" : "Rome, GA",
  //   "chassis_number" : "B093737",
  //   "coach_number" : 2504,
  //   "alignment_OP_CK" : "OK",
  //   "dyno_OP_CK" : "OK",
  //   "water_OP_CK" : "OK",
  //   "disc_count" : 6,
  //   "Shortage_name" : "51-55046-000, FAN ASM, 24v with High/Off/Low SW",
  //   "ETA" : "10/30/2022",
  //   "comments" : "Customer visit" ,
  //   "location" :"FENCE"
  //   }
  //   ];

  @track modedshortagegdata = [];
  @track filtereddiscrepancy = [
    {
      assigend_qc_id: null,
      base_serial_fleet: "B197679",
      buildstation_code: "327.5050",
      buildstation_id: 1584,
      bus_area: null,
      bus_area_picture_id: null,
      bus_relative_seq: "2 of 6",
      bus_seq_in_day: 5,
      bus_start_date: "2022-11-30T08:00:00+00:00",
      buspart_id: null,
      buspart_name: null,
      buspart_no: null,
      busstatus_id: 2,
      busstatus_name: "WIP",
      buyer: "Andrew Perez",
      carrier_arrival_text: "05:45:00.000",
      carrier_text: "UPS 2ND DAY",
      chassis_no: "B197680",
      component: null,
      createdby_id: {
        appuser_name: "95671",
        employee_id: 987,
        employee_number: "95671",
        first_name: "Vishwas",
        last_name: "S U"
      },
      current_line_location: "8050",
      custom_part_name: "test part shortage for staged bus",
      customer_id: 87,
      customer_name: "Kitsap, WA",
      cut_off_date: "2022-11-09T10:53:26+00:00",
      dat_defect_code_id: null,
      date_received: null,
      defect_code: null,
      defect_name: null,
      defect_type: null,
      department_id: 21,
      department_name: "03 - ELECTRICAL",
      discrepancy: "test part shortage for staged bus",
      discrepancy_log_number: 1,
      discrepancy_priority: "Normal",
      discrepancy_status: "Open",
      discrepancy_type: "partshortage",
      ecard_discrepancy_log_id: 6303,
      ecard_id: 3552,
      ecard_operation_log_id: 10488,
      forman1_id: {
        appuser_name: "13703",
        employee_id: 464,
        employee_number: "13703",
        first_name: "Peter",
        last_name: "Ha"
      },
      forman2_id: null,
      forman3_id: null,
      forman4_id: null,
      forman5_id: null,
      image_url: null,
      is_b_whs_kit: true,
      is_long_term: false,
      is_ship_short: true,
      modified_date: "2022-12-03T20:06:13.266966+00:00",
      modifiedby_id: {
        appuser_name: "EliezerL",
        employee_id: 371,
        employee_number: "62073",
        first_name: "Eliezer",
        last_name: "Lopez"
      },
      part_shortage_id: 2376,
      planner_code: "1*",
      po_no: "1234567",
      prod: [
        {
          appuser_name: "13703",
          buildstation_id: 1584,
          employee_id: 464,
          employee_number: "13703",
          first_name: "Peter",
          last_name: "Ha"
        }
      ],
      product_code: null,
      qc: [],
      quantity: 1.0,
      raised_date: "2022-11-17T06:11:54+00:00",
      raised_status_updated_date: "2022-11-17T06:11:54.912739+00:00",
      reference_key: "03",
      remarks: "Demo shortage in purchasing shortage.",
      resolved_date: null,
      resolved_status_updated_date: null,
      resolved_status_updatedby_id: null,
      root_cause: null,
      ship_short_pco: "f110",
      shortage_cause_id: 2,
      tracking: null,
      vendor_name: "abc",
      vendor_number: null,
      verified_date: "2022-12-03T20:06:13.266959+00:00",
      verified_status_updated_date: "2022-12-03T20:06:13.266951+00:00",
      verifiedby_id: {
        appuser_name: "EliezerL",
        employee_id: 371,
        employee_number: "62073",
        first_name: "Eliezer",
        last_name: "Lopez"
      },
      workcenter_code: "0327",
      workcenter_name: "0327"
    },
    {
      assigend_qc_id: null,
      base_serial_fleet: "B196478",
      buildstation_code: "4002",
      buildstation_id: 1610,
      bus_area: null,
      bus_area_picture_id: null,
      bus_relative_seq: "1 of 1",
      bus_seq_in_day: 5,
      bus_start_date: "2022-12-07T08:00:00+00:00",
      buspart_id: 518711,
      buspart_name: "PIPING & MTG,40' W/O C-SIDE MTD HTR(S),",
      buspart_no: "21-0002-0704D",
      busstatus_id: 2,
      busstatus_name: "WIP",
      buyer: null,
      carrier_arrival_text: "06:00:00.000",
      carrier_text: "UPS 2ND DAY",
      chassis_no: "B196478",
      component: null,
      createdby_id: {
        appuser_name: "22222",
        employee_id: 879,
        employee_number: "22222",
        first_name: "Appu",
        last_name: "Milon"
      },
      current_line_location: "5600",
      custom_part_name: null,
      customer_id: 86,
      customer_name: "Chapel Hill, NC",
      cut_off_date: "2023-01-02T10:45:45+00:00",
      dat_defect_code_id: null,
      date_received: null,
      defect_code: null,
      defect_name: null,
      defect_type: null,
      department_id: 1,
      department_name: "04A - CHASSIS",
      discrepancy: "PIPING & MTG,40' W/O C-SIDE MTD HTR(S),",
      discrepancy_log_number: 2,
      discrepancy_priority: "Normal",
      discrepancy_status: "Open",
      discrepancy_type: "partshortage",
      ecard_discrepancy_log_id: 6323,
      ecard_id: 3381,
      ecard_operation_log_id: 10542,
      forman1_id: {
        appuser_name: "rbarnes",
        employee_id: 223,
        employee_number: "61418",
        first_name: "Robert",
        last_name: "Barnes"
      },
      forman2_id: null,
      forman3_id: null,
      forman4_id: null,
      forman5_id: null,
      image_url: null,
      is_b_whs_kit: true,
      is_long_term: false,
      is_ship_short: true,
      modified_date: "2022-12-02T10:46:18.358031+00:00",
      modifiedby_id: {
        appuser_name: "80006",
        employee_id: 1125,
        employee_number: "80006",
        first_name: "Sathish",
        last_name: "testuser"
      },
      part_shortage_id: 2388,
      planner_code: null,
      po_no: "4741528",
      prod: [
        {
          appuser_name: "rbarnes",
          buildstation_id: 1610,
          employee_id: 223,
          employee_number: "61418",
          first_name: "Robert",
          last_name: "Barnes"
        },
        {
          appuser_name: "61705",
          buildstation_id: 1610,
          employee_id: 476,
          employee_number: "61705",
          first_name: "Ramesh",
          last_name: "Kumar"
        }
      ],
      product_code: "BM34",
      qc: [],
      quantity: 2.3,
      raised_date: "2022-11-30T09:07:05+00:00",
      raised_status_updated_date: "2022-11-30T09:04:32.452980+00:00",
      reference_key: "04A",
      remarks: "Testing staging shortage 02-12",
      resolved_date: null,
      resolved_status_updated_date: null,
      resolved_status_updatedby_id: null,
      root_cause: null,
      ship_short_pco: "324325",
      shortage_cause_id: 2,
      tracking: "2345235",
      vendor_name: "test",
      vendor_number: null,
      verified_date: "2022-12-02T10:46:18.358023+00:00",
      verified_status_updated_date: "2022-12-02T10:46:18.358010+00:00",
      verifiedby_id: {
        appuser_name: "80006",
        employee_id: 1125,
        employee_number: "80006",
        first_name: "Sathish",
        last_name: "testuser"
      },
      workcenter_code: "4000",
      workcenter_name: "4000"
    },
    {
      assigend_qc_id: null,
      base_serial_fleet: "B196478",
      buildstation_code: "4002",
      buildstation_id: 1610,
      bus_area: null,
      bus_area_picture_id: null,
      bus_relative_seq: "1 of 1",
      bus_seq_in_day: 5,
      bus_start_date: "2022-12-07T08:00:00+00:00",
      buspart_id: 652021,
      buspart_name: "KIT, ALUM-PIPE, 40', DRIVER HTR,E-BUS",
      buspart_no: "XX-00002-354",
      busstatus_id: 2,
      busstatus_name: "WIP",
      buyer: "Stephanie Beard",
      carrier_arrival_text: null,
      carrier_text: null,
      chassis_no: "B196478",
      component: null,
      createdby_id: {
        appuser_name: "EliezerL",
        employee_id: 371,
        employee_number: "62073",
        first_name: "Eliezer",
        last_name: "Lopez"
      },
      current_line_location: "5600",
      custom_part_name: null,
      customer_id: 86,
      customer_name: "Chapel Hill, NC",
      cut_off_date: null,
      dat_defect_code_id: null,
      date_received: null,
      defect_code: null,
      defect_name: null,
      defect_type: null,
      department_id: 1,
      department_name: "04A - CHASSIS",
      discrepancy: "KIT, ALUM-PIPE, 40', DRIVER HTR,E-BUS",
      discrepancy_log_number: 4,
      discrepancy_priority: "Normal",
      discrepancy_status: "Open",
      discrepancy_type: "partshortage",
      ecard_discrepancy_log_id: 6329,
      ecard_id: 3381,
      ecard_operation_log_id: 10542,
      forman1_id: {
        appuser_name: "rbarnes",
        employee_id: 223,
        employee_number: "61418",
        first_name: "Robert",
        last_name: "Barnes"
      },
      forman2_id: null,
      forman3_id: null,
      forman4_id: null,
      forman5_id: null,
      image_url: null,
      is_b_whs_kit: null,
      is_long_term: null,
      is_ship_short: true,
      modified_date: "2022-12-03T19:34:10.609838+00:00",
      modifiedby_id: {
        appuser_name: "EliezerL",
        employee_id: 371,
        employee_number: "62073",
        first_name: "Eliezer",
        last_name: "Lopez"
      },
      part_shortage_id: 2392,
      planner_code: "13K",
      po_no: "",
      prod: [
        {
          appuser_name: "rbarnes",
          buildstation_id: 1610,
          employee_id: 223,
          employee_number: "61418",
          first_name: "Robert",
          last_name: "Barnes"
        },
        {
          appuser_name: "61705",
          buildstation_id: 1610,
          employee_id: 476,
          employee_number: "61705",
          first_name: "Ramesh",
          last_name: "Kumar"
        }
      ],
      product_code: "XKIT",
      qc: [],
      quantity: 1.0,
      raised_date: "2022-12-03T19:21:06+00:00",
      raised_status_updated_date: "2022-12-03T19:21:45.608587+00:00",
      reference_key: "04A",
      remarks: "Testing the order in which buses shortage appear under staging",
      resolved_date: null,
      resolved_status_updated_date: null,
      resolved_status_updatedby_id: null,
      root_cause: null,
      ship_short_pco: "f110",
      shortage_cause_id: null,
      tracking: null,
      vendor_name: "S.F. Tube",
      vendor_number: "P684082",
      verified_date: "2022-12-03T19:34:10.609831+00:00",
      verified_status_updated_date: "2022-12-03T19:34:10.609823+00:00",
      verifiedby_id: {
        appuser_name: "EliezerL",
        employee_id: 371,
        employee_number: "62073",
        first_name: "Eliezer",
        last_name: "Lopez"
      },
      workcenter_code: "4000",
      workcenter_name: "4000"
    }
  ];

  @track nodatadessert = "";

  connectedCallback() {
    //this.processData();
    console.log('Inside connected call back');
    this.recurrentcall();
    this.applyfilter();
  }

  recursivecall = 0;

  recurrentcall(){
    console.log('Inside recurrent call');
    // this.recursivecall = setInterval(() => {
    //   this.applyfilter();
    //   }, 10000);
  }

  disconnectedCallback(){
    // console.log('HTML removed from DOM');
    clearInterval(this.recursivecall);
  }

  @track currentPage = 1;
  @track paginationfilter = {};
  totalPage = 1;

  applyfilter() {
    //this.resetpaginationdata();
    console.log('Inside apply filter call back');
    this.currentPage = (Math.floor(Math.random()*10)) === 0 ? 1 : Math.floor(Math.random()*10);
    this.applypaginationfilter();
  }

  // resetpaginationdata() {
  //   this.currentPage = 1;
  // }

  applypaginationfilter(event) {
    console.log('Inside apply filter call back');
    var statuslist = [];
    var shortagestatus = [];
      // statuslist = null;
    statuslist = ["WIP", "Out%20of%20Factory"];
    shortagestatus = null;
    //workaround ends
    var statusparm = {
      page: this.currentPage,
      bus_status: statuslist,
      discrepancy_status: shortagestatus,
      search:"",
      department_id:null,
      is_ship_short:null,
      has_date_recieved:null,
      buyer:null,
      createdby_id:null
    };
    this.paginationfilter = statusparm;
    this.loadShortagesdata(event, false);
  }

  loadShortagesdata(event, disableScroll) {
    console.log('Inside loadshortage data call back');
    var statusparm = this.paginationfilter;
    statusparm["page"] = this.currentPage;
    getAllShortageslist({ ecardbusstatus: JSON.stringify(statusparm) })
      .then((data) => {
        // var recordperpage = JSON.parse(data.responsebody).data
        //   .max_record_per_page;
        // var totalrecordcount = JSON.parse(data.responsebody).data.count;
        // var totalPage = Math.ceil(totalrecordcount / recordperpage);
        // this.totalPage = totalPage != 0 ? totalPage : 1;
        //var shortageslist = [];

        var shortagelogs = JSON.parse(data.responsebody).data.discrepancylog;

        this.filtereddiscrepancy = shortagelogs;
        this.processData();
        
        //
      })
      .catch((error) => {
        this.error = error;
        this.showmessage(
          "Data fetch failed.",
          "Something unexpected occured. Please try again or contact your Administrator.",
          "error"
        );
      });
  }

  processData() {
    const shortageMap = new Map();
    const busMap = new Map();
    if (this.filtereddiscrepancy.length > 0) {
      for (var item in this.filtereddiscrepancy) {
        var readyRowdata = this.filtereddiscrepancy[item];

        busMap.set(readyRowdata.chassis_no, readyRowdata);

        var shortageList = [];
        // var shortageData = {
        //     "shortage_name" : readyRowdata.Shortage_name,
        //     "eta" : readyRowdata.ETA,
        //     "comments" : readyRowdata.comments,
        // }
        var shortageData = {
          shortage_name: readyRowdata.buspart_name != null ? readyRowdata.buspart_name : readyRowdata.custom_part_name,
          eta: readyRowdata.cut_off_date,
          comments: readyRowdata.remarks
        };
        if (shortageMap.has(readyRowdata.chassis_no)) {
          shortageList = shortageMap.get(readyRowdata.chassis_no);
        }
        shortageList.push(shortageData);
        shortageMap.set(readyRowdata.chassis_no, shortageList);
      }
    }

    var buswithshortages = [];
    for (let key of busMap.keys()) {
      var bus = busMap.get(key);
      var shortage = shortageMap.get(key);
      // bus['shortage'] = shortage;
      var busdetails = {
        customer_name: bus.customer_name,
        chassis_number: bus.chassis_no,
        coach_number: bus.base_serial_fleet,
        alignment_OP_CK: "OK",
        dyno_OP_CK: "OK",
        water_OP_CK: "OK",
        disc_count: 5,
        Shortage_name: bus.buspart_name != null ? bus.buspart_name : bus.custom_part_name,
        ETA: bus.date_received,
        comments: bus.remarks,
        location: bus.current_line_location,
        shortage: shortage
      };
      buswithshortages.push(busdetails);
    }

    console.log("Bus and Shortage List " + JSON.stringify(buswithshortages));

    //this.modedshortagegdata = buswithshortages;

    this.modedshortagegdata = this.buildlistdata(buswithshortages);

    //this.filtereddiscrepancy = ;

    console.log(
      "Bus and Shortage List after css adding " +
        JSON.stringify(this.modedshortagegdata)
    );
  }

  buildlistdata(buswithshortages) {
    var modeddatalist = [];
    for (var item in buswithshortages) {
      var data = buswithshortages[item];
      var shortagedata = data.shortage;
      for (var entries in shortagedata) {
        var shortagedetails = shortagedata[entries];
        var busdetails = {
          customer_name: "",
          chassis_number: "",
          coach_number: "",
          alignment_OP_CK: "",
          dyno_OP_CK: "",
          water_OP_CK: "",
          disc_count: "",
          Shortage_name: shortagedetails.shortage_name,
          ETA: shortagedetails.eta,
          comments: shortagedetails.comments,
          index: shortagedetails.ecard_discrepancy_log_id,
          location: "",
          css: "verticlebold"
        };
        if (entries == shortagedata.length - 1) {
          busdetails.customer_name = data.customer_name;
          busdetails.chassis_number = data.chassis_number;
          busdetails.coach_number = data.coach_number;
          busdetails.alignment_OP_CK = data.alignment_OP_CK;
          busdetails.dyno_OP_CK = data.dyno_OP_CK;
          busdetails.water_OP_CK = data.water_OP_CK;
          busdetails.disc_count = data.disc_count;
          busdetails.css = "verticlebold horizontalbold";
        }
        modeddatalist.push(busdetails);
      }
    }
    return modeddatalist;
  }

  sortdiscrepancytable() {
    //dummy
  }

  get isdepartmentPaint() {
    return false;
  }

  get disclistempty() {
    return this.filtereddiscrepancy.length === 0;
  }
}