trigger customApp on TestCustom__c (before insert) {
    List<TestCustom__c> tclist = Trigger.new;
    
    UserInfo ui = new UserInfo();
    String un = UserInfo.getUserId();
    
    tclist[0].approver__c= un;
}