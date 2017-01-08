// struktury danych

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

// load data

{Node} Nodes = ...;
{Link} Links = ...;
{Demand} Demands = ...;

int a[Links][Nodes] = ...;
int b[Links][Nodes] = ...;

dvar float+ x[Links][Nodes];

minimize
  sum(link in Links)
    sum(node in Nodes)
      x[link][node] * link.cost;
      
subject to {

	capacity:
		forall(link in Links){
			sum(node in Nodes)
			  x[link][node] <= link.capacity;	
		}
	
	demand:
		forall(node in Nodes){
			sum(link in Links)
				a[link][node] * x[link][node] ==  sum(demand in Demands: demand.source_node == node) demand.amount;		  
	 	}	  
 	
	flow:
		forall(src in Nodes){
			forall(dest in Nodes: dest != src){	
				sum(link in Links)
					(a[link][dest] * x[link][src] - b[link][dest]*x[link][src]) == sum(demand in Demands: demand.source_node == src && demand.end_node == dest) (-1) * demand.amount;
	 		}					  
	 	}	
}




execute {

	var infeasible = 0;

	for(var link in Links){
		var used_capacity = 0;
		for(var node in Nodes){
			used_capacity += x[link][node];	
		}
		write("Na linku ", link.name, " uzywamy ", used_capacity, " z ", link.capacity, " dostepnych.");
		if (used_capacity > link.capacity){
			infeasible += 1;	
			write(" <- za duzo");
		}
		writeln();
	}
	if (infeasible > 0){
		writeln("Sprzeczne - na ", infeasible, " linkach brakuje capacity.");	
	} else {
		writeln("OK!");	
	}
}
