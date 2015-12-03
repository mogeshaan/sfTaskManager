public with sharing class Excel2Controller {
    public String getXmlVer() {
        return '<?xml version="1.0"?>' + '\r\n';
    }

    public String getXmlApp() {
        return '<?mso-application progid="Excel.Sheet"?>' + '\r\n';
    }
}