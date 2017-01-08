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
 
 float QueuingDelay = ...;
 
 int x[Arcs][Tenants] = ...;

 dvar float+  X[Arcs][Tenants][Flows];
 dvar float+ lambda[Tenants][Flows];
 
 maximize
 	//minimalziacja maksymalnego delay
  	sum(tenant in Tenants)
  	  	(1.0/model.X[arc][tenant][flow]) + model.QueuingDelay
  	    
 
 subject to { 
 
  topology_constrain:
  forall(arc in Arcs){
  	forall(tenant in Tenants){
  		forall(flow in Flows){
  			if(x[arc][tenant] == 0){
  				X[arc][tenant][flow] == 0;  			
  			}  		
  		}
  	}  
  }

  capacity_constraint:
  forall(arc in Arcs){
  	(sum(tenant in Tenants)
  	  sum(flow in Flows: flow.tenant_id == tenant && x[arc][tenant] == 1)
  	    X[arc][tenant][flow]) <= arc.capacity;  
  }

  flow_conservation:
  forall(node in Nodes){
	  forall(tenant in Tenants){
	  	forall(flow in Flows: flow.tenant_id == tenant){	
	  		if(node == flow.source ){  	
				(sum(arc in Arcs: arc.output_node==node) X[arc][tenant][flow] -
		  		sum(arc in Arcs: arc.input_node==node) X[arc][tenant][flow]) == -lambda[tenant][flow];
   			} else if (node == flow.dest) {
				(sum(arc in Arcs: arc.output_node==node) X[arc][tenant][flow] -
		  			sum(arc in Arcs: arc.input_node==node) X[arc][tenant][flow]) == lambda[tenant][flow];	
   			} else {
   			   	sum(arc in Arcs: arc.output_node==node) X[arc][tenant][flow] == sum(arc in Arcs: arc.input_node==node) X[arc][tenant][flow];	
   			}  		
	  	}  
	  }
  }
    
 }
 
 execute {
 	var tab = "  "; 
 
	for(var tenant in Tenants){
		writeln("Tenant: ", tenant.id);
		for(var flow in Flows){
			if(flow.tenant_id == tenant){
				writeln(tab, "Flow: ", flow.id);			
				writeln(tab, tab, "Lambda: ", lambda[tenant][flow]);
				write(tab, tab, "Arcs: ");
				for(var arc in Arcs){
					if(X[arc][tenant][flow] > 0 ){
						write(arc.name, " ");		
   					}					
				}
				writeln();
			}
		}	
	}
 }
 