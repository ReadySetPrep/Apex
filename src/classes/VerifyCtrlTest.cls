@isTest
private class VerifyCtrlTest {

    static VerifyCtrl initTest() {
        PageReference pageRef = Page.Verify;
        Test.setCurrentPage(pageRef);
        VerifyCtrl ctrl = new VerifyCtrl();
        return ctrl;
    }

    static testMethod void testDoVerifyCtrl() {
        VerifyCtrl ctrl = initTest();        
        ctrl.Module = Factory.TD;
        PageReference pageRef = ctrl.doVerifyCtrl();        
        System.assert(null==pageRef, 
            'Expected no navigation.');
    }

    static testMethod void testDoVerifyCtrl_NoModule() {
        VerifyCtrl ctrl = initTest();        
        ctrl.Module = null;
        PageReference pageRef = ctrl.doVerifyCtrl();        
        System.assert(Factory.hasMessage(Factory.ERROR_PRIOR_NOT_SELECTED), 
            'Expected message: ' + Factory.ERROR_PRIOR_NOT_SELECTED);
    }    

    static testMethod void testDoMain() {
         VerifyCtrl ctrl = initTest();
         PageReference pageref = ctrl.doMain();
         System.assert(null!=pageRef,
             'Expected navigation not null');
         System.assert(Factory.URL_MAIN==pageRef.getUrl(), 
             'Expected navigation to main, not ' + pageRef.getUrl() + '.');
    }
    
    static testMethod void testClearScore() {
        VerifyCtrl ctrl = initTest();        
        List<Point__c> d = Factory.newModuleTest(Factory.TD);
        insert(d);
        for (Point__c p : d) {
            Factory.logComplete(p.Id,1);
        }
        Integer count = [SELECT COUNT() FROM Score__c];
        System.assert(d.size()==count, 
            'Expected a score for every point, not ' + count + '.');
        ctrl.Module = Factory.TD;
        PageReference pageRef = ctrl.doClearScore();
        count = [SELECT COUNT() FROM Score__c];
        System.assert(0==count, 
            'Expected scores to be cleared, not ' + count + '.');
    }    
}