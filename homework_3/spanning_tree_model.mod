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

{Node} Neighbours[node in Nodes] = { link.output_node | link in Links: link.output_node == node};
 

range S = 1.. ftoi(round(2^n));

// All subsets of vertices
{Node} Subsets[s in S] = { node | node in Nodes:
					(s div ftoi(round(2^node.id-1))) mod 2 == 1 };

{Node} Compl[s in S] = Nodes diff Subsets[s]; 					

dvar boolean x[Links];


 constraint cutConstraint[S];
 
minimize
  sum(link in Links)
    x[link] * link.cost;
    
    
subject to {

	forall(s in S : 0 < card(Subsets[s]) < n){

	// There must be an edge for every cut, #cutConstraint for spanning tree, checkout wikipedia
	cutConstraint[s]:
		sum(node_in in Subsets[s], node_out in Neighbours[node_in] inter Compl[s])
		  x[first({link | link in Links : link.input_node == node_in && link.output_node==node_out})] +
		sum(node_in in Compl[s], node_out in Neighbours[node_in] inter Subsets[s])
		  x[first({link | link in Links: link.input_node == node_in && link.output_node==node_out})] >= 1; 		  
	}	
	
	// number of used links must be lower than number of all links, otherwise we have a loop
 	global:
	sum(link in Links) x[link] == n-1;
 	
}

execute {
	writeln("Wybrano nastęujące ścieżki: ");

	for(var link in Links){
		if (x[link] > 0){
			writeln(" ", link.name);
		}
	}  
}