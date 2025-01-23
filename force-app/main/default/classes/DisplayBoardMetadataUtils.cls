public with sharing class DisplayBoardMetadataUtils { 
	
	public static Map<String, String> boardSettings;	
	public static Map<String, String> jsonFieldNameLabels;
	public static Map<String, String> colorsSetting;
	
	public static Map<String, String> fieldMapper = null; // DB labels to jsonFieldName
    
    static { 
    	fieldMapper = new Map<String, String>();
    	fieldMapper.put( 'ID', 'recordID');
    	fieldMapper.put( 'Internal Name','companyName');
    	fieldMapper.put( 'Mode','mode');
    	fieldMapper.put( 'Style','style');
    	fieldMapper.put( 'Bus Length','busLength');
    	fieldMapper.put( 'Length','busLength');
    	fieldMapper.put( 'Bus Number','serialNumber');
    	fieldMapper.put( 'Sequence','sequence');
    	fieldMapper.put( 'Quantity','quantity');

    	fieldMapper.put( 'Slot Index In Day','slotInDayIndex');
    	fieldMapper.put( 'Start Date','slotDate');
    	
    	fieldMapper.put( 'Slots','slotSize');
    	fieldMapper.put( 'Pilot','isPilot');
    	fieldMapper.put( 'is Reserved','isReserved');
    	fieldMapper.put( 'is Scheduled','isScheduled');
    	fieldMapper.put( 'is Future Holding','isFutureHolding');
    	fieldMapper.put( 'is Firm','isFirm');
    	
    	fieldMapper.put( 'Brakes', 'brakes');
    	fieldMapper.put( 'Engine', 'engine');
    	fieldMapper.put( 'HVAC System', 'HVACSystem');
    	fieldMapper.put( 'ITS System', 'ITSSystem');
    	fieldMapper.put( 'ITS System Type', 'ITSSystemType');
    	fieldMapper.put( 'Preproduction Meeting Date', 'preprodMeetingDate');
    	fieldMapper.put( 'Preproduction Meeting', 'preprodMeetingDate');
    	fieldMapper.put( 'Sales Order Release Date', 'SOReleaseDate');
    	fieldMapper.put( 'Sales Order Release', 'SOReleaseDate');
    	fieldMapper.put( 'Transmission', 'transmission');
    	fieldMapper.put( 'Wheelchair Ramp', 'wheelchairRamp');

        fieldMapper.put( 'First Bus', 'firstBus');
        fieldMapper.put( 'Project Sales Manager', 'projectSalesMgr');
    	
		jsonFieldNameLabels = getDisplayBoardSettingsJsonFieldNamesMDT();
		boardSettings = getDisplayBoardSettingsMDT();
	}
	
	private DisplayBoardMetadataUtils() { }
	
	/*
	private static Map<String , String> getDisplayBoardSettingsJsonFieldNamesNOUSE() {
    	Map<String,Display_Board_Settings__c> customSettingMap = Display_Board_Settings__c.getAll();
    	Map<String, String> jsonFieldNameLabelsTemp = new Map<String, String>();
    	List<String> keyList = new List<String>();
    	keyList.addAll( customSettingMap.keySet());
    	for ( String jsonFieldName: keyList) {
    		if ( jsonFieldName.startsWith( 'jsonfieldname')) {
    			jsonFieldNameLabelsTemp.put( jsonFieldName, Display_Board_Settings__c.getValues( jsonFieldName).value__c);	
    		} // if	
    	}
    	return jsonFieldNameLabelsTemp;
    }
	*/
	
	private static Map<String , String> getDisplayBoardSettingsMDT() {
    	List<Display_Board_Setting__mdt> settingsMDT = [ SELECT MasterLabel, value__c FROM Display_Board_Setting__mdt];
    	Map<String, String> cmtSettings= new Map<String, String>();
    	for ( Display_Board_Setting__mdt record: settingsMDT) {
    		cmtSettings.put( record.MasterLabel, record.value__c);	
    	}
    	return cmtSettings;
    }

	private static Map<String , String> getDisplayBoardSettingsJsonFieldNamesMDT() {
    	List<Display_Board_Setting__mdt> settingsMDT = [ SELECT MasterLabel, value__c FROM Display_Board_Setting__mdt];
    	Map<String, String> jsonFieldNameLabelsTemp = new Map<String, String>();
    	for ( Display_Board_Setting__mdt record: settingsMDT) {
    		if ( record.MasterLabel.startsWith( 'jsonfieldname')) {
    			jsonFieldNameLabelsTemp.put( record.MasterLabel, record.value__c);	
    		} // if	
    	}
    	return jsonFieldNameLabelsTemp;
    }
    
     
    public static List<DisplayBoardHoverField> getDisplayBoardHoverFields() {
	
		List<DisplayBoardHoverField> displayBoardHoverFields = new List<DisplayBoardHoverField>();
		// Get the fieldset first and then describe them
		Schema.SObjectType sObjectType  = Schema.getGlobalDescribe().get(DisplayBoardConstants.DB_BUS_OBJECT_NAME);
		Schema.FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(DisplayBoardConstants.DB_HOVER_DIALOG_FSET);
		
		DisplayBoardHoverField hField = null;
		DisplayBoardFilterField fField = null;
		for(Schema.FieldSetMember member : fieldSet.getFields()) {
			fField = getFieldMetaData( sObjectType, member);
			hField = new DisplayBoardHoverField();
			hField.jsonFieldName = fField.jsonFieldName;
			hField.dataType = fField.dataType;
			// hField.label = fField.label;
			displayBoardHoverFields.add( hField);
		}

		return displayBoardHoverFields;
    }
    
    
       
    public static List<DisplayBoardFilterField> getDisplayBoardFilterFields() {
	
		List<DisplayBoardFilterField> displayBoardFilterFields = new List<DisplayBoardFilterField>();
		// Get the fieldset first and then describe them
		Schema.SObjectType sObjectType  = Schema.getGlobalDescribe().get(DisplayBoardConstants.DB_OPPLINE_OBJECT_NAME);
		Schema.FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(DisplayBoardConstants.DB_OPPLINE_SEARCH_FILTER_FSET);
		
		for(Schema.FieldSetMember member : fieldSet.getFields()) {
			displayBoardFilterFields.add(getFieldMetaData( sObjectType, member));
		}

		sObjectType  = Schema.getGlobalDescribe().get(DisplayBoardConstants.DB_SALESORDER_OBJECT_NAME);
		fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(DisplayBoardConstants.DB_SALESORDER_SEARCH_FILTER_FSET);
		
		for(Schema.FieldSetMember member : fieldSet.getFields()) {
			displayBoardFilterFields.add(getFieldMetaData( sObjectType, member));
		}
 
		sObjectType  = Schema.getGlobalDescribe().get(DisplayBoardConstants.DB_BUS_OBJECT_NAME);
		fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(DisplayBoardConstants.DB_SEARCH_FILTER_FSET);
		
		for(Schema.FieldSetMember member : fieldSet.getFields()) {
			displayBoardFilterFields.add(getFieldMetaData( sObjectType, member));
		}

		return displayBoardFilterFields;
    }
    
    
    public static DisplayBoardFilterField getFieldMetaData(Schema.SObjectType sObjectType, Schema.FieldSetMember member) {
    	
    	DisplayBoardFilterField field = new DisplayBoardFilterField();
    	field.dataType = member.getType().name();
    	if ( field.dataType == 'MULTIPICKLIST') {
    		field.dataType = 'PICKLIST';
    	}
    	
    	System.debug( member.getLabel());
    	
    	field.jsonFieldName = DisplayBoardMetadataUtils.fieldMapper.get( member.getLabel());
    	// field.label = DisplayBoardMetadataUtils.jsonFieldNameLabels.get( 'jsonfieldname.' + field.jsonFieldName);
		if ( field.dataType.equalsIgnorecase('picklist') || field.dataType.equalsIgnorecase('multipicklist') ) {
    		field.values = getPicklistValues( sObjectType, member);
    	} else if (field.jsonFieldName == 'projectSalesMgr') {
            field.dataType = 'AUTOFILL';
            List<Profile> psmProfile = [select Id from Profile where Name = 'Project Sales Manager'];
            List<String> psmList = new List<String>();
            for (user tpsm:[select Name from user where profileID in :psmProfile]) {
                psmList.add(tpsm.Name);
            }
            field.values = psmList;
        } else if ( field.dataType.equalsIgnorecase('Reference')) {
	    	field.dataType = 'AUTOFILL';
    		field.values = getReferenceValues( sObjectType, member);
    		field.jsonFieldName = DisplayBoardMetadataUtils.fieldMapper.get( 'Internal Name'); 
	    	// field.label = DisplayBoardMetadataUtils.jsonFieldNameLabels.get( 'jsonfieldname.' + field.jsonFieldName);
    	} else if ( field.dataType.equalsIgnorecase('double')) {
	    	field.dataType = 'INTEGER';
    	}
       	return field;
    }
    
    private static List<String> getPicklistValues(Schema.SObjectType sObjectType, Schema.FieldSetMember member) {
    	List<String> values = new List<String>();
		Schema.DescribeFieldResult result = sObjectType.getDescribe().fields.getMap().get(member.getFieldPath()).getDescribe();
		for (Schema.PicklistEntry entry : result.getPicklistValues()) {
		if ( entry.isActive() )
			values.add( entry.getValue());
		}
    	return values;
    }

    private static List<String> getReferenceValues(Schema.SObjectType sObjectType, Schema.FieldSetMember member) {
    	List<String> values = new List<String>();
		Schema.DescribeFieldResult result = sObjectType.getDescribe().fields.getMap().get(member.getFieldPath()).getDescribe();
		List<Schema.sObjectType> relatedToObjects = result.getReferenceTo();
		
		// if account 
		if ( relatedToObjects.get(0).getDescribe().getName() == 'Account') { 
			// System.debug( 'inside account building');
			String query = 'SELECT Id, Name, Internal_Name__c From ' + relatedToObjects.get(0).getDescribe().getName() + ' Order By Name ASC';
			List<SObject> results = Database.query(query);
			String iName = null;
			for(SObject sObj : results) {
				iName = (String) sObj.get('Internal_Name__c');
				if ( iName != null) {
					iName = iName.replace(' ', '');
					if ( iName.length() > DisplayBoardConstants.CUSTOMER_NAME_LENGTH ) { 
				    	iName = iName.substring(0, DisplayBoardConstants.CUSTOMER_NAME_LENGTH).replace('\'','');
					} else { 
				    	iName = iName.replace('\'','');
					} // if
				} else {
					iName = 'NO NAME';
				} // if
					
					values.add( iName);
				} // for
			} // if
    	return values;
    }
}