global with sharing class Holiday {

    @RemoteAction
    global static List<Holiday__c> loadHoliday() {
      Date pDate = Date.today();
      Date startDate = Date.newinstance(pDate.year(), pDate.month(), 1);
      Date endDate = startDate.addMonths(2);
      String qp = 'SELECT Id, Name, ymd__c FROM Holiday__c WHERE ymd__c >= String.valueOf(startDate) AND ymd__c < String.valueOf(endDate)';
      List<Holiday__c> lh = Database.query(qp);
      return lh;
    }
    
}