/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 7, 2016 at 4:59:15 PM
 *********************************************/
tuple Node {
	int id;
};
 
tuple Link {
	string name;
	Node input_node;
	Node output_node;
	int cost;
	float capacity;
};

tuple Demand{
	string name;
	Node source_node;
	Node end_node;
	int amount;
};

{Node} Nodes = ...;
{Link} Links = ...;
{Demand} Demands = ...;

int a[Links][Nodes];
int b[Links][Nodes];

dvar float+ x[Links][Nodes];

execute{
	function fill_a_and_b_matrices(){
		for(var link in Links){
			a[link][link.input_node] = 1;
			b[link][link.output_node] = 1;		
		}
	};
	
	fill_a_and_b_matrices();	
}


minimize
  sum(link in Links)
    sum(node in Nodes)
      x[link][node] * link.cost;
      
subject to {
	capacity_constraint:
	forall(link in Links){
		sum(node in Nodes)
		  x[link][node] <= link.capacity;	
	}
	
	demand_constraint:
	forall(node in Nodes){
		sum(link in Links)
			a[link][node] * x[link][node] ==  sum(demand in Demands : demand.source_node == node) demand.amount;		  
 	}	  
 	
 	// tego warunku nie czaję, ideksowanie jest jakies z dupy
	flow_constraint:
	forall(node_v in Nodes){
		forall(node_w in Nodes){	
			// to jest brzydkie, trzeba by poprawić na coś z "continue"
			if(node_v != node_w){
				sum(link in Links)
					(a[link][node_w] * x[link][node_v] - b[link][node_w]*x[link][node_v]) == 
					sum(demand in Demands : demand.source_node == node_v && demand.end_node == node_w) demand.amount;
  			}				
 		}					  
 	}	
}


execute {

}
