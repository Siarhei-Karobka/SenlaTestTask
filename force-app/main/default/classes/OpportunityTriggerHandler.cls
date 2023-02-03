public with sharing class OpportunityTriggerHandler {
    private static final String OPP_NEEDS_ANALYSIS = 'Needs Analysis';
    private static final String OPP_ACCESS_LEVEL = 'Read';
    private static final String CHIEF_MANAGER_USER_ROLE_NAME = 'Chief Manager';
    private static final Decimal OPP_AMOUNT = 10000;

    public void execute(List<Opportunity> newList,
                        Map<Id, Opportunity> newMap,
                        Map<Id, Opportunity> oldMap,
                        System.TriggerOperation triggerEvent){
        switch on triggerEvent {
            when AFTER_UPDATE {
                amountChangedToMoreThanValue(newList, oldMap);
            }
        }
    }

    public void amountChangedToMoreThanValue(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<Opportunity> oppsNA = new List<Opportunity>();
        Map<String, List<Opportunity>> managerIdToOpps = new Map<String, List<Opportunity>>();
		for(Opportunity opp : newList){
			if (opp.Amount > OPP_AMOUNT
                && opp.StageName != oldMap.get(opp.Id).StageName
                && opp.StageName == OPP_NEEDS_ANALYSIS){
				if(managerIdToOpps.get(opp.LastModifiedBy.ManagerId) == null){
                    managerIdToOpps.put(opp.LastModifiedBy.ManagerId, new List<Opportunity>{opp});
				} else {
                    managerIdToOpps.get(opp.LastModifiedBy.ManagerId).add(opp);
                }
                oppsNA.add(opp);
			}
		}

        if (!managerIdToOpps.keyset().isEmpty()) {
            sendBellNotificationToManager(managerIdToOpps);
        }
        if (!oppsNA.isEmpty()) {
            shareAccessToChiefManager(oppsNA);
        }
    }

    public void sendBellNotificationToManager (Map<String, List<Opportunity>> managerIdToOpps){
        CustomNotificationType notificationType =
            [SELECT Id, DeveloperName
             FROM CustomNotificationType
             WHERE DeveloperName='Opp_Stage_changed_to_Needs_Analysis'];

        for (String managerId : managerIdToOpps.keySet()) {
            for (Opportunity opp : managerIdToOpps.get(managerId)) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Apex Custom Notification');
                notification.setBody('The notifications are coming from INSIDE the Apex!');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(opp.Id);

                notification.send(new set<String>{managerId});
            }
        }
    }

    public void shareAccessToChiefManager (List<Opportunity> oppsNA){
        //Assume that only one ChiefManager User in organization
        User chiefManager = [SELECT Id, Email FROM User WHERE UserRole.name =: CHIEF_MANAGER_USER_ROLE_NAME LIMIT 1];
        List<OpportunityShare> oppShrRecords = new List<OpportunityShare>();

        for (Opportunity opp : oppsNA) {
            OpportunityShare oppShr = new OpportunityShare();
            oppShr.OpportunityAccessLevel = OPP_ACCESS_LEVEL;
            oppShr.OpportunityId = opp.Id;
            oppShr.UserOrGroupId = chiefManager.Id;
            oppShrRecords.add(oppShr);
        }

        Database.SaveResult[] srList = Database.insert(oppShrRecords, false);
        sendEmail(chiefManager.Email, 'Subject', oppsNA.toString());
    }

    public void sendEmail(String recipientEmail, String subject, String body) {
		Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
		String[] sendingTo = new String[]{recipientEmail};
		sEmail.setToAddresses(sendingTo);
		sEmail.setSubject(subject);
		sEmail.setPlainTextBody(body);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sEmail});
	}
}