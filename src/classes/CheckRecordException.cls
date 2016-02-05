public class CheckRecordException extends Exception{
    public Map<Integer, Map<String, String>> messageList{
      get;
      set;
    }
    public String errorMessage{
      get {
        //return 'AAAAAAAJJJJJJJJJ';
        return JSON.serialize(this.messageList);
      }
      set;
    }
    public void setMessageList(Integer pRecNo, String pField, String pMess) {
      if (this.messageList == null) {
        this.messageList = new Map<Integer, Map<String, String>>();
      }

      Map<String, String> newmp = new Map<String, String>();
      if (this.messageList.get(pRecNo) == null) {
        // その行のマップがない場合
        newmp.put(pField, pMess);
      } else {
        newmp = this.messageList.get(pRecNo);
        newmp.put(pField, pMess);
      }
      this.messageList.put(pRecNo, newmp);
    }
}