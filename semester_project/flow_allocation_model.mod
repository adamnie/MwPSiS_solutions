/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 12, 2016 at 5:39:44 PM
 *********************************************/

 tuple Flow {
 	int id; 
 };
 
 tuple Node {
 	int id; 
 };
 
 tuple Arc {
 	string name;
 	Node input_node;
 	Node output_node;
 	int capacity;
 	int cost;	 
 };
 
 tuple Tenant {
  	int id;
 };
 
 {Flow} Flows = ...;
 {Arc} Arcs = ...;
 {Tenant} Tenants = ...;
 {Node} Nodes = ...;

 dvar float+  X[Tenants][Flows][Arcs];
 dvar float+ lambda[Tenants][Flows][Nodes];
 
 maximize
  	sum(tenant in Tenants)
  	  min(flow in Flows) sum(node in Nodes) lambda[tenant][flow][node];
  	    
 
 subject to {
  capacity_constraint:
  forall(arc in Arcs){
  	sum(tenant in Tenants)
  	  sum(flow in  Flows)
  	    X[tenant][flow][arc] <= arc.capacity;  
  }
  
  flow_conservation:
  forall(node in Nodes){
	  forall(tenant in Tenants){
	  	forall(flow in Flows){
			( sum(arc in Arcs: arc.input_node==node) X[tenant][flow][arc] -
	  		sum(arc in Arcs: arc.output_node==node) X[tenant][flow][arc]) == lambda[tenant][flow][node];
	  	}  
	  }
  }  
  
  
 }
 
 execute {
 	writeln("Kurwa mać!"); 
 }
 