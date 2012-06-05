/**
 * Generates Study Guide for a particular Review Module for the Study Points with completed Scores.
 */
 public with sharing class GuideCtrl {
 
    public class GuideRow {
        public Point__c Point {get; set;}
        public Decimal Tries {get; set;}
        public String getResult() {
            if (Tries==1) { 
                return 'Correct'; 
            } else { 
                return 'Incorrect (' + String.valueOf(Tries) + 'x)';              
            }
        }
    }

    /**
     * Holds Points with Scores. 
     */ 
    public List<GuideRow> Rows { get; set; }
    
  
    /**
     * Selects Study Guide Module. Set via parameter ('module=').
     */
    public String Module { get; set; }
    
    /**
     * Presents number of Scores with multiple tries for the Study Guide Module.
     */
    public String Incorrect { get; set; }    
    
    /**
     * Presents number of Scores with a single tries for the Study Guide Module.
     */   
    public String Correct { get; set; }
    
    /**
     * Presents number of Points without Scores for the Study Guide Module.
     */
    public String Remaining { get; set; }
    
    /**
     * Sets module for study guide via a parameter. 
     */
    public GuideCtrl() {
        Module = System.currentPagereference().getParameters().get(Factory.PARAM_MODULE);
    }
    
    /**
     * Prepares properties for the current module for presentation on the study guide page.
     * Redirects to Main if there are no Scores for the selected module, 
     * or Scores__c object is not accessible.
     */
    public PageReference doModule() {
    
        Integer doneCount = 0; 
        Boolean isAccessible = Score__c.sObjectType.getDescribe().isAccessible();
        if (isAccessible) doneCount = Factory.doneCount(Module);      
        if (!isAccessible ||0==doneCount) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                Factory.ERROR_PENDING_NOT_SELECTED)); 
            return Page.Main;      
        }
    
        List<Point__c> correctPoints = Factory.getCorrect(Module);
        List<Point__c> incorrectPoints = Factory.getIncorrect(Module);
        
        Integer correctCount = correctPoints.size();
        Integer incorrectCount = incorrectPoints.size();
        
        Integer moduleCount = Factory.moduleCount(Module);
        Integer leftCount = moduleCount - doneCount ;
 
        Incorrect = String.valueOf(incorrectCount); 
        Correct = String.valueOf(correctCount);
        Remaining = String.valueOf(leftCount);
        
        Map<Id,Decimal> tries = Factory.getTries(Module);
        
        List<Point__c> ps = new List<Point__c>();
            ps.addAll(incorrectPoints);
            ps.addAll(correctPoints);
        
        List<GuideRow> rs = new List<GuideRow>();
        
        for (Point__c p : ps) {
            GuideRow row = new GuideRow();
            row.Point = p;
            row.Tries = tries.get(p.Id);   
            rs.add(row);     
        }
        
        Rows = rs;
        
        return null;
    }      
}