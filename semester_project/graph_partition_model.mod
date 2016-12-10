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
  	int capacity;
 };
 
 {Arc} Arcs = ...;
 {Node} Nodes = ...;
 
 dvar int+ x[Arcs];
 
 minimize 
 	sum(link in Arcs)
 		x[link];
 
