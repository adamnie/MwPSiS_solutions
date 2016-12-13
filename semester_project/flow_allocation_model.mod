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

 float X[Tenants][Flows][Arcs] = ...;
 
 dvar float+ lambda[Tenants][Flows][Nodes];
 float helper[Tenants][Flows];
 
 maximize
  	sum(tenant in Tenants)
  	  min(flow in Flows) sum(node in Nodes) lambda[tenant][flow][node];
  	    
 
 subject to {
  capacity_constraint:
  forall(arc in Arcs){
  	sum(tenant in Tenants)
  	  sum(flow in Flows: flow.tenant_id == tenant)
  	    X[tenant][flow][arc] == arc.capacity;  
  }
  
  flow_conservation:
  forall(node in Nodes){
	  forall(tenant in Tenants){
	  	forall(flow in Flows: flow.tenant_id == tenant){
			( sum(arc in Arcs: arc.input_node==node) X[tenant][flow][arc] -
	  		sum(arc in Arcs: arc.output_node==node) X[tenant][flow][arc]) == lambda[tenant][flow][node];
	  	}  
	  }
  }  
  
  
 }
 