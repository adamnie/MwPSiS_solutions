/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 10, 2016 at 1:50:42 PM
 *********************************************/

 tuple Node {
 	int id; 
 };

 tuple Arc{
  	string name;
  	Node input_node;
  	Node output_node;
  	int cost;
  	int capacity;
 };
 
 tuple Tenant {
 	int id; 
 };
 
 int N = ...;
 range n = 1..N;
 
 {Arc} Arcs = ...;
 {Node} Nodes = ...;
 
 {Tenant} Tenants = {};
 
 execute{
	 for(var id in n){
	 		Tenants.add(id);
	 } 
 };
 
 int weights[Tenants] = ...;
 
 dvar boolean x[Arcs][Tenants];
 
 minimize 
	sum(tenant_a in Tenants)
	  sum(tenant_b in Tenants)
		sum(arc in Arcs)
		  (x[arc][tenant_a] == x[arc][tenant_b] == 1);		
 
subject to {	
	forall(tenant in Tenants){
		sum(arc in Arcs)
		  arc.cost <= weights[tenant];
 	}	  
}