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
 range n = 1..N;
  
 
 {Arc} Arcs = ...;
 {Node} Nodes = ...;
 {Tenant} Tenants = ...;
 {Flow} Flows = ...;
 
 int weights[Tenants] = ...;
 
 {Node} Neighbours[node in Nodes] = { link.output_node | link in Arcs: link.input_node == node};
 range S = 1.. ftoi(round(2^N));

// All subsets of vertices
{Node} Subsets[s in S] = { node | node in Nodes:
					(s div ftoi(round(2^node.id-1))) mod 2 == 1 };

{Node} Compl[s in S] = Nodes diff Subsets[s]; 
 
 
 dvar boolean x[Arcs][Tenants];
 
  minimize 
	sum(tenant_a in Tenants)
	  sum(tenant_b in Tenants)
		sum(arc in Arcs)
		  (x[arc][tenant_a] == 1 && x[arc][tenant_b] == 1);		
	  
 
subject to {	
	
	weights_contraint:
	forall(tenant in Tenants){
		forall(arc in Arcs)
		  arc.cost * x[arc][tenant] <= weights[tenant];
 	}	  
 	
 	forall(tenant in Tenants){
 	 	sum (arc in Arcs) (x[arc][tenant]) >= N-1; 
 	}
 	
 	set_cut_contraint:
 	forall(tenant in Tenants){
	 	forall(s in S : 0 < card(Subsets[s]) < N){
			sum(node_in in Subsets[s], node_out in Neighbours[node_in] inter Compl[s])
			  x[first({link | link in Arcs : link.input_node == node_in && link.output_node==node_out})][tenant] +
			sum(node_in in Compl[s], node_out in Neighbours[node_in] inter Subsets[s])
			  x[first({link | link in Arcs: link.input_node == node_in && link.output_node==node_out})][tenant] >= 1; 		  
				
	 	}
 	} 	
 	
}