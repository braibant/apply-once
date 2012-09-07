Require Import String. 
Add Rec LoadPath "../src/" as Ltac_ext.  
Add ML Path "../src/". 

Require Ltac_ext. 


Section t. 

  Variable a b c d e : nat. 
  
  Goal  True -> True -> True. 
  intros. 
  iter_tac (fun x =>  
              match type of x with 
                | True => clear x
                | ?t => change t with (id t) in x
              end). 

  Abort. 
End t. 