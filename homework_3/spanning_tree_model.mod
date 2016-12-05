/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Nov 15, 2016 at 4:43:29 PM
 *********************************************/

tuple Node {
	key int id;
}
 
tuple Link {
	key string name;
	Node input_node;
	Node output_node;
	int cost;
}

int n = ...;

{Link} Links = ...;
{Node} Nodes = ...;
{Node} Source = ...;
{Node} Other = ...;

dvar int+ x[Links];
 
 
minimize
  sum(link in Links)
    x[link] * link.cost;
    
    
subject to {

	source:
	forall(node in Source){
  	  sum (link in Links: link.input_node == node) (x[link]) - sum(link in Links: link.output_node == node) (x[link]) == n-1;  
 	}
 	
 	others:
 	forall(node in Other){
  	  sum (link in Links: link.input_node == node) (x[link]) - sum(link in Links: link.output_node == node) (x[link]) == -1;  
 	}
 	
}

execute {
	writeln("Wybrano nastęujące ścieżki: ");

	for(var link in Links){
		if (x[link] > 0){
			writeln(" ", link.name);
		}
	}  
}