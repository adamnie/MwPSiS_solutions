/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Nov 15, 2016 at 3:01:30 PM
 *********************************************/


tuple Link {
	string name;
	int input_node;
	int output_node;
	int capacity;
}

{int} Nodes = ...; 

{Link} Links = ...;

dvar float+ x[Links];
 
 maximize 
  	sum(link in Links)
  	  x[link];
 
 subject to {
  	forall(link in Links)
  		x[link] <= link.capacity;
  		
  	forall(node in Nodes){
  	  sum (link in Links: link.input_node == node) (x[link]) == sum(link in Links: link.output_node == node) (x[link]);  
 	}	  
 };
 
 execute{ 
 
 	for(link in Links){
 	  write("The flow for ", link.name, " is ", x[link]); 
 	  writeln();
  	} 	  
 
	writeln("Works!");  
 };