/**
 * Presents Study Point in Exercise format.
 * Custom Object access is enforced by the doNext method. 
 * CRUD is enforced by the Factory.logComplete method. 
 * Standard objects are not accessed.
 */
public with sharing class ExerciseCtrl {

    // -- Properties --
    
    /**
     * Module field for the current Study Point.
     */ 
    public String Module { get; set; }

    /**
     * Objective field for the current Study Point.
     */ 
    public String Objective { get; set; } 

    /**
     * Field for the current Study Point.
     */ 
    public String Exercise { get; set; } 
    
    /**
     * Option fields for the current Study Point.
     */     
    public String[] Option { get; set; } 
    
    /**
     * Correct fields for the current Study Point.
     */     
    public Boolean[] Correct { get; set; }
    
    /**
     * Options chosen by the user.
     */     
    public String[] Selections { get; set; } 
    
    /**
     * Tracks bites at the apple. Only the first bite counts as a success.
     */     
    public Integer Tries { get; set; } 

    /**
     * Local object Id for the current Excerise Point.
     */     
    public Id PointId { get; set; }

    
    /**
     * Relative number of the current Exercise (12 -- of 100).
     */
    public String Current { get; set; }
    
    /**
     * Count of all Exercises in the curent Moudle. 
     */
    public String Total { get; set; }    
    
    /**
     * User-facing legend indicsting Current of Total.
     */
    public String Progress { get; set; }    
    
    /**
    * User-facing indicator of how many correct options to select. 
    */
    public String SelectionLabel { get; set; }
    
    /**
     * User-facing message indicating success or failure (try again).
     */
    public String Outcome { get; set; }
    
    /**
     * User-facing prompt to continue. Not visible when exercise is first presented.
     */
    public String NextLabel { get; set; }
    
    /**
     * Tracks whether page is bin
     */
    public Boolean PostBack { get; set; }
    
    /**
     * Tracks count of correct options for current exercise. 
     */
    public Integer Corrects {get; set; }
    
    /**
     * Tracks whether to display select command.
     */
    public Boolean Done { get; set; }
    
    // -- Helpers --
    
    // "After four we raise our swords"
    private void initOption(String myOption, Boolean isCorrect, Integer count) {
        if (isCorrect) Corrects++;
        Option[count] = Factory.checkOption(myOption, count);
        Correct[count] = isCorrect;
    }
    
    // Clear the table
    private void reset() {
        // Point and Score proxies
        Module = '';
        Objective = '';
        Exercise = '';
        Option = new String[]{};
        Correct = new Boolean[]{};
        Selections = new String[]{}; 
        Tries = 0;
        PointId = null;
        // Page helpers
        Current = '';
        Total = '';
        Progress = '';        
        SelectionLabel = '';
        Outcome = '';
        NextLabel = '';
        PostBack = false;
        Corrects = 0;
        Done = false;
    }
    
    private Integer next(Integer range) {
        Double x = math.random() * range; 
        return x.intValue();
    }
              
   // -- Methods --
    
    /** 
     * Returns four options with label and value set to the same String, 
     * corresponding to the Option property. 
     */
    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i=0; i<Factory.OPS; i++) {
            String myOption = Factory.checkOption(Option[i],i);
            options.add(new SelectOption(myOption, myOption)); 
        }
        return options;
    }
              
    // -- Actions --
    
    /**
     * Prepares a new exercise for user response and sets page properties. 
     * If all exercises are complete, redirects to the guide page. 
     * If a module has not been selected, redirects to the prep page. 
     */
    public PageReference doNext(Id userId) {    
        // Verify user session and object access
        Active__c a = Factory.getActive(userId);
        Boolean isAccessible = Point__c.sObjectType.getDescribe().isAccessible();
        if (a==null || !isAccessible) {
          ApexPages.addMessage(
              new ApexPages.Message(
                  ApexPages.Severity.FATAL,Factory.ERROR_INSUFFICIENT_ACCESS)
          );
          return Page.Main;
        } else {
            reset();
            List<Point__c> left = Factory.getLeft(a);
            if (left.size()==0) {
                PageReference guide = Page.Guide;
                guide.getParameters().put('module',a.Module__c);        
                return guide;
            } else {
                // Where are we?
                Integer haveSize = Factory.ModuleCount(a);
                Integer doneSize = Factory.DoneCount(a);
                Integer remaining = haveSize - doneSize;
                Current = String.valueOf(++doneSize);
                Total = String.valueOf(haveSize);
                Progress = 'Exercise ' + Current + ' out of ' + Total + '.';
                // Who's next?
                Point__c Point = left[next(remaining)]; 
                    Module = Point.Module__c;
                    Objective = Point.Objective__c;
                    Exercise = Point.Exercise__c;
                    PointId = Point.Id;
                // Are we legion?
                Corrects = 0;
                Option = new String[Factory.OPS];
                Correct = new Boolean[Factory.OPS];
                // (Sigh) An array field type should would be nice ...
                initOption(Point.Option1__c, Point.Correct1__c, 0); 
                initOption(Point.Option2__c, Point.Correct2__c, 1); 
                initOption(Point.Option3__c, Point.Correct3__c, 2); 
                initOption(Point.Option4__c, Point.Correct4__c, 3); 
                // Tell 'em what they won, Johnny ...
                SelectionLabel = (Corrects==1) ? 
                    'Select one option' : 'Select ' + Corrects + ' options';   
            }                    
        }
        
        // nothing to see here, move along
        return null;
    }
        
    // Also called by Page at construction
    public PageReference doNext() {
        return doNext(UserInfo.getUserId());
    }
            
     /**
     * Compares selected options against correct options for the current point, 
     * sets the Outcome to SUCCESS or NOT SUCCESS, and logs the result when 
     * selected matches correct. Returns null regardless. 
     */
    public PageReference doSelect() {
        if (!PostBack) NextLabel = Factory.CONTINUE_NEXT;
        PostBack = true;
        Tries++;
        Set<String> selected = new Set<String>(Selections);
        Boolean ok = Factory.isCorrect(selected,Correct,Option);
        // logComplete enforces creatibility
        if (ok) Factory.logComplete(PointId, Tries);
        Outcome = ok ? Factory.CORRECT : Factory.NOT_CORRECT ;
        Done = ok;
        return null;
    }
        
}