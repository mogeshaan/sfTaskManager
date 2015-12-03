public class CommonUtil {
    public String domId{get;set;}
    static Integer STR_LENGTH = 32;

    public CommonUtil() {
        this.createDomId();
    }
    /**
     * ランダム文字列を生成する
     */
    public void createDomId() {
        String CharList = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
        domId = '';
        Integer position;


        for(Integer i = 0; i <= STR_LENGTH; i++) {
            position = Integer.valueof(String.valueof(Math.roundToLong(CharList.length()*Math.random()))) -1;
            if (position < 0) {position = 0;}
            this.domId += CharList.substring(position,position+1);
        }
    }
}