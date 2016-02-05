@isTest
private class TestTaskManage {
  private final static String COND_ALL = 'ALL';
  private final static String COND_ALL_KANA = '--すべて--';
  private final static String COLUMN_COMPANY = 'COMP';
  private final static String COLUMN_DEPARTMENT = 'DEPT';
  private final static String NULL_COMPANY = '--会社未設定--';
  private final static String NULL_DEPARTMENT = '--部署未設定--';

  /**
   * 部署取得テスト
   * @return {[type]} [description]
   */
  @isTest static void testGetDepartment() {
    // データ準備
    List<User> lu = new List<User>();
    lu.add(new User(Username='MINAMOTOTEST1@example.com', CompanyName='TEST1Comp', Department='TEST1Dept', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST2@example.com', CompanyName='TEST2Comp', Department='', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST3@example.com', CompanyName='', Department='TEST3Dept', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST4@example.com', CompanyName='', Department='', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    insert lu;
    Test.startTest();
      List<User> result = TaskManage.getDepartment();
    Test.stopTest();
    for (User tu : result) {
      if (tu.Username == 'MINAMOTOTEST1@example.com') {
        System.assertEquals('TEST1Comp', tu.CompanyName);
        System.assertEquals('TEST1Dept', tu.Department);
      } else if (tu.Username == 'MINAMOTOTEST2@example.com') {
        System.assertEquals('TEST2Comp', tu.CompanyName);
        System.assertEquals('--部署未設定--', tu.Department);
      } else if (tu.Username == 'MINAMOTOTEST3@example.com') {
        System.assertEquals('--会社未設定--', tu.CompanyName);
        System.assertEquals('TEST3Dept', tu.Department);
      } else if (tu.Username == 'MINAMOTOTEST4@example.com') {
        System.assertEquals('--会社未設定--', tu.CompanyName);
        System.assertEquals('--部署未設定--', tu.Department);
      }
    }
  }

  /**
   * 会社名取得テスト
   * @return {[type]} [description]
   */
  @isTest static void testGetCompanyName() {
    // 最初に現在の状態を取得
    List<String> nowValue = TaskManage.getCompanyName();
    Integer nowRowCount = nowValue.size();
    // データ準備
    List<User> lu = new List<User>();
    lu.add(new User(Username='MINAMOTOTEST1@example.com', CompanyName='TEST1Comp', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST2@example.com', CompanyName='TEST2Comp', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST3@example.com', CompanyName='TEST2Comp', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST4@example.com', CompanyName='', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST5@example.com', CompanyName='', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    insert lu;
    Test.startTest();
      List<String> result = TaskManage.getCompanyName();
    Test.stopTest();
    system.assertEquals(2 + nowRowCount, result.size()); // 会社名無がすでにあるので＋2となる
  }

  /**
   * [testGetSplitName description]
   * @return {[type]} [description]
   */
  @isTest static void testGetSplitName() {
    String pConcatName1 = null;
    String pConcatName2 = '--すべて--';
    String pConcatName3 = 'ああああ:いいうう';

    // null
    Map<String, String> result1 = TaskManage.getSplitName(pConcatName1);
    System.assertEquals(null, result1);

    // すべて
    Map<String, String> result2 = TaskManage.getSplitName(pConcatName2);
    System.assertEquals(null, result2.get('COMP'));
    System.assertEquals(null, result2.get('DEPT'));

    // 正常分割
    Map<String, String> result3 = TaskManage.getSplitName(pConcatName3);
    System.assertEquals('ああああ', result3.get('COMP'));
    System.assertEquals('いいうう', result3.get('DEPT'));
  }

  @isTest static void TestGetUserByDept() {
    String pDept1 = 'ALL';
    String pDept2 = '--すべて--:--すべて--';
    String pDept3 = 'TEST2Comp:--すべて--';
    String pDept4 = 'TEST2Comp:TEST2Comp';

    // 最初に現在の状態を取得
    List<User> nowValue = [SELECT Id FROM User];
    Integer nowRowCount = nowValue.size();

    // データ準備
    List<User> lu = new List<User>();
    lu.add(new User(Username='MINAMOTOTEST1@example.com', CompanyName='TEST1Comp', Department='TEST1Dept', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST2@example.com', CompanyName='TEST2Comp', Department='TEST2Comp', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST3@example.com', CompanyName='', Department='TEST1Dept', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    lu.add(new User(Username='MINAMOTOTEST4@example.com', CompanyName='TEST2Comp', Department='', LastName='TEST' , Email='TEST@example.com', Alias='TEST', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=UserInfo.getProfileId(), LanguageLocaleKey='en_US'));
    insert lu;

    // テスト
    Test.startTest();
    List<User> result1 = TaskManage.getUserByDept(pDept1);
    List<User> result2 = TaskManage.getUserByDept(pDept2);
    List<User> result3 = TaskManage.getUserByDept(pDept3);
    List<User> result4 = TaskManage.getUserByDept(pDept4);
    List<User> resultAll = TaskManage.getUser();
    Test.stopTest();

    // 検証
    // すべて
    System.assertEquals(nowRowCount + 4, result1.size());
    // 会社すべて
    System.assertEquals(nowRowCount + 4, result2.size());
    // 部署すべて
    System.assertEquals(2, result3.size());
    // 会社部署指定
    System.assertEquals(1, result4.size());

    // 全て版のラッパー
    System.assertEquals(nowRowCount + 4, resultAll.size());
  }
}