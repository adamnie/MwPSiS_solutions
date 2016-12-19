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
 	float packet_loss; 
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
 
 {Flow} Flows = ...;
 {Arc} Arcs = ...;
 {Tenant} Tenants = ...;
 {Node} Nodes = ...;
 
 int QueuingDelay = ...;
 
 int x[Arcs][Tenants] = ...;

 dvar float+  X[Tenants][Flows][Arcs];
 dvar float+ lambda[Tenants][Flows];
 
 maximize
  	sum(tenant in Tenants)
  	  	min(flow in Flows) sum(node in Nodes) lambda[tenant][flow];
  	    
 
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
	  	forall(flow in Flows: flow.tenant_id == tenant && node != flow.dest){	
	  		if(node == flow.source ){  	
				(sum(arc in Arcs: arc.output_node==node) X[tenant][flow][arc] -
		  		sum(arc in Arcs: arc.input_node==node) X[tenant][flow][arc]) == lambda[tenant][flow];
   			}  else {
   			   	(sum(arc in Arcs: arc.output_node==node) X[tenant][flow][arc] -
		  		sum(arc in Arcs: arc.input_node==node) X[tenant][flow][arc]) == 0;	
   			}  		
	  	}  
	  }
  }  
  
  data_rate_constraint:
  forall(tenant in Tenants){
  	forall(flow in Flows){
  		forall(arc in Arcs){
			lambda[tenant][flow] <= X[tenant][flow][arc]; 		 			
  		}  	
	}  	
  }
  
//  delay_constraint:
//  forall(tenant in Tenants){
//  	forall(flow in Flows){
//  		sum(arc in Arcs) ((1.0/X[tenant][flow][arc]) + QueuingDelay) <= flow.max_delay;   		 
// 	}  		  
//  }
//  
//  jitter_constraint:
//  forall(tenant in Tenants){
//  	forall(flow in Flows){
//  	 standardDeviation(sum(arc in Arcs) ((1.0/X[tenant][flow][arc]) + QueuingDelay)) < flow.jitter_max;  	
//  	}  
//  }
//
//packet_loss_constraint:
//forall(tenant in Tenants){
//	forall(flow in Flows){
//		prod(arc in Arcs) arc.packet_loss <= flow.max_packet_loss;
//	}
//}
  
  
 }
 
 execute {

 }
 