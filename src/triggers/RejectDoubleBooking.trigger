trigger RejectDoubleBooking on Session_Speaker__c (before insert, before update) {
    //collect ID's to reduce data calls
    List<Id> speakerIds = new List<Id>();
    Map<Id,DateTime> sessionIdToDateMap = new Map<Id,DateTime>();
    //get all speakers related to the trigger
    //set booking map with ids to fill later
    for(Session_Speaker__c newItem : trigger.new) {
        sessionIdToDateMap.put(newItem.Session__c,null);
        speakerIds.add(newItem.Speaker__c);
    }
    //fill out the start date/time for the related sessions
    List<Session__c> related_sessions = [SELECT ID, Session_Date__c from Session__c WHERE ID IN :sessionIdToDateMap.keySet()];
    for(Session__c related_session : related_sessions) {
        sessionIdToDateMap.put(related_session.Id,related_session.Session_Date__c);
    }
    //get related speaker sessions to check against
    List<Session_Speaker__c> sessionSpeakers = [SELECT ID, Speaker__c, Session__c, Session__r.Session_Date__c from Session_Speaker__c WHERE Speaker__c IN :speakerIds];
    //check one list against the other
    for(Session_Speaker__c sessionSpeakerTriggerNew : trigger.new) {
        DateTime booking_time = sessionIdToDateMap.get(sessionSpeakerTriggerNew.Session__c);
        for(Session_Speaker__c sessionSpeaker : sessionSpeakers) {
            if(sessionSpeaker.Speaker__c == sessionSpeakerTriggerNew.Speaker__c &&
                    sessionSpeaker.Session__r.Session_Date__c == booking_time) {
                sessionSpeakerTriggerNew.addError('The speaker is already booked at that time');
            }
        }
    }
}
