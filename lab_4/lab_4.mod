/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 6, 2016 at 3:05:01 PM
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

tuple Path{
	key string name;
};

{Link} Links = ...;
{Demand} Demands = ...;
{Node} Nodes = ...;
{Path} Paths = ...;

int delta[Links][Demands][Paths] = ...;

dvar float+ x[Demands][Paths];
dvar float+ y[Links];

minimize
	  sum(link in Links)
	  	link.cost * y[link];
  
subject to {
	capacity_constraint:
	forall(link in Links){
		y[link] <= link.capacity;
	}	
 		
 	demand_contraint:
 	forall(demand in Demands){
 		sum(path in Paths)
 		  x[demand][path] == demand.amount; 	
 	}
 	
 	path_constraint:
 	forall(link in Links){
 	 	sum(demand in Demands)
 	 	  sum(path in Paths)
 	 	    delta[link][demand][path] == y[link];
 	}		
}

execute {

}