/*********************************************
 * OPL 12.6.1.0 Model
 * Author: cholda
 * Creation Date: 02-04-2016 at 13:56:09
 *********************************************/

 int n = ...;

 range V = 1..n;
 
 {int} NodeSet = asSet(V);
 
 int s = ...;
 int t = ...;

 {int} NodKirch = NodeSet diff {s} diff {t};

 tuple Arc
 {
   int start;
   int stop;
 }   
 
 {Arc} A with start in V, stop in V = ...;

 float Capacity[A] = ...;
  
 {int} NbsO[i in V] = {j | <i,j> in A};
 //Set of outgoing neighbors
 
 {int} NbsI[i in V] = {j | <j,i> in A};
 //Set of ingoing neighbors
  
 dvar float+ x[A];
 
 maximize sum(n in NbsO[s]) x[<s,n>];
  
 subject to{
   forall(n in NodKirch)
     intermediary_node: 
   		sum(j in NbsO[n]) x[<n,j>] == sum(j in NbsI[n]) x[<j,n>];

   forall(a in A)
     capacities:
     	x[a] <= Capacity[a];
 }  