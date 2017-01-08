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
	  sum(link in Links) link.cost * y[link];
  
subject to {
	capacity:
		forall(link in Links){
			y[link] <= link.capacity;
		}	
 		
 	demand:
	 	forall(demand in Demands){
	 		sum(path in Paths)
	 		  x[demand][path] == demand.amount; 	
	 	}
 	
 	path:
	 	forall(link in Links){
	 	 	sum(demand in Demands)
	 	 	  sum(path in Paths)
	 	 	    (delta[link][demand][path]*x[demand][path]) == y[link];
	 	}		
}


execute {
	
	for(var link in Links){
		writeln("Na linku ", link.name, " uzywamy ", y[link], " z ", link.capacity, " dostepnych.");
	}
	
}