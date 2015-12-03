public with sharing class RecordMaker {
    static Integer STR_LENGTH = 32;
    List<Opportunity> dataRecords;
    String domId;
    
    /**
     * データレコードを取得する
     */
    public List<Opportunity> getDataRecords() {
        // オブジェクト読み込み
        dataRecords = [
            SELECT
                id,
                name,
                Amount,
                CalcTest__c
            FROM
                Opportunity
            ];

        return dataRecords;

    }

    /**
     * ランダム文字列を生成する
     */
    public String getDomId() {
        if (!String.isEmpty(domId)) {
          return domId;
        }
        String CharList = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
        domId = '';
        Integer position;

        for(Integer i = 0; i <= STR_LENGTH; i++) {
            position = Integer.valueof(String.valueof(Math.roundToLong(CharList.length()*Math.random()))) -1;
            domId += CharList.substring(position,position+1);
            system.debug(position);
        }
        return domId;
    }

}