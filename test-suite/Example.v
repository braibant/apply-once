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

Section u. 
  
  Inductive P : nat -> Prop :=
    p0 : P 0
  | p1 : forall n, P n -> P (S n).
  

  (* here we have a **syntactic** search for n in the list ns *)
  Require Import List. 
  Ltac is_in_dec n ns := match ns with
                           | nil     => false
                           | n :: _  => true
                           | _ :: ?tl => is_in_dec n tl
                         end.

  (* Here the first case looks for new values by failing on old ones,
and the catch-all one allows the tactics to succeed when all the work
has been done.  cf. this bit of cpdt for more details on the behaviour
of the first match: http://adam.chlipala.net/cpdt/html/Match.html *)

  Ltac inverse_P ns := match goal with
                         | [ H: P ?x |- _ ] =>
                           let test := is_in_dec x ns in
                           match constr:test with
                             | true  => fail
                             | false =>
                               let H' := fresh "H" in
                               let m' := fresh "m" in
                               inversion H as [H' | m' H'] ;
                                 match type of H' with
                                   | P ?z => inverse_P (z :: x :: ns)
                                   | _ => inverse_P (x :: ns)
                                 end
                           end
                         | _ => idtac ""
                       end.

  (* Finally an example *)
  
  Goal forall x y z, P x -> P y -> P z.
  intros.
  inverse_P (@nil nat).
  Restart. 
  intros. iter_tac (fun x => 
                      match type of x with 
                          | P _ => inversion x
                          | _ => idtac
                      end). 
  Admitted. 
  
  Fixpoint test n :=
    match n with 
      | 0 => True
      | S n => (forall x, P x -> test n)
    end. 
  
  Goal test 10. compute. 
  intros.
  Time inverse_P (@nil nat).      (*  10 s *)
  Restart. 
  compute; intros. 
  Time iter_tac (fun x => 
                      match type of x with 
                          | P _ => inversion x
                          | _ => idtac
                      end).     (* 1.5 *)
  Admitted. 

End u.   
