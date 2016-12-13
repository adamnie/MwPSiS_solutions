/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 12, 2016 at 5:39:44 PM
 *********************************************/

 
 tuple Node {
 	int id; 
 };
 
 tuple Arc {
 	string name;
 	Node input_node;
 	Node output_node;
 	int cost;
 	int capacity;	 
 };
 
 tuple Tenant {
  	int id;
 };

tuple Flow {
  	int id;
  	Tenant tenant_id;
  	Node source;
  	Node dest;
  	float max_delay;
  	float max_jitter;
  	float max_packet_loss;
 };

 
 int T = ...;
 int N = ...;
 
 {Flow} Flows = ...;
 {Arc} Arcs = ...;
 {Tenant} Tenants = ...;
 {Node} Nodes = ...;
 
 int weights[Tenants] = ...;
 
 int x[Arcs][Tenants] = ...;

 dvar float+  X[Tenants][Flows][Arcs];
 dvar float+ lambda[Tenants][Flows][Nodes];
 
 maximize
  	sum(tenant in Tenants)
  	  max(flow in Flows) sum(node in Nodes) abs(lambda[tenant][flow][node]) / 2 ;
  	    
 
 subject to {
  capacity_constraint:
  forall(arc in Arcs){
  	sum(tenant in Tenants)
  	  sum(flow in Flows: flow.tenant_id == tenant && x[arc][tenant] == 1)
  	    X[tenant][flow][arc] <= arc.capacity;  
  }

  flow_conservation:
  forall(node in Nodes){
	  forall(tenant in Tenants){
	  	forall(flow in Flows: flow.tenant_id == tenant){
			(sum(arc in Arcs: arc.input_node==node && x[arc][tenant] == 1) X[tenant][flow][arc] -
	  		sum(arc in Arcs: arc.output_node==node && x[arc][tenant] == 1) X[tenant][flow][arc]) == lambda[tenant][flow][node];
	  	}  
	  }
  }  
  
  
 }
 
 execute {

 }
 