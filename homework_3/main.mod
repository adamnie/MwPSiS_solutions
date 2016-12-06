/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 3, 2016 at 4:48:17 PM
 *********************************************/

tuple Node {
	key int id;
};

{Node} sources;
main{

	thisOplModel.generate();

	//helper functions
	function prepareData(source){
		write("Preparing data for node: ", source);
		
		thisOplModel.sources.clear();
		thisOplModel.sources.add(source);
		
		var data = new IloOplDataElements();
		data.Source = thisOplModel.sources;
		
		write("\tDone!\n");
		return data;
	};

	write("Preparing model for shortest path...");
	var shortest_path_model_source = new IloOplModelSource("shortest_path_model.mod");
	var shortest_path_definition = new IloOplModelDefinition(shortest_path_model_source);
	var cplex_shortest_path_model = new IloCplex();
	var opl_shortest_path_model = new IloOplModel(shortest_path_definition, cplex_shortest_path_model);
	write("\tDone!\n");
	
	write("Preparing model for spanning tree...");
	var spanning_tree_model_source = new IloOplModelSource("spanning_tree_model.mod");
	var spanning_tree_definition = new IloOplModelDefinition(spanning_tree_model_source);
	var cplex_spanning_tree_model = new IloCplex();
	var opl_spanning_tree_model = new IloOplModel(spanning_tree_definition, cplex_spanning_tree_model);
	write("\tDone!\n");
	
	write("Generating models...");
	var model_input_data_source = new IloOplDataSource("graph.dat");
	opl_shortest_path_model.addDataSource(model_input_data_source);
	opl_spanning_tree_model.addDataSource(model_input_data_source);
	opl_shortest_path_model.generate();
	opl_spanning_tree_model.generate();
	write("\tDone!\n");
	
	var Nodes = opl_spanning_tree_model.Nodes;
	var Links = opl_spanning_tree_model.Links;

	for(var node in Nodes){
		
		write("\n\n");
		writeln("============= Solving for node ", node, " =============");
	
		var data = prepareData(node, Nodes);	
		
		opl_spanning_tree_model.addDataSource(data);
		opl_shortest_path_model.addDataSource(data);
		
	
		if(cplex_shortest_path_model.solve() && cplex_spanning_tree_model.solve()){
			writeln("Both models were solved!");
			var shortest_path_solution = opl_shortest_path_model.x;
			var spanning_tree_solution = opl_spanning_tree_model.x;
			var links_are_the_same = true;
			
			for(var i in shortest_path_solution){
				// product 0 means that at least one on them is zero, but 
				// sum greater than zero means that at least one of them is not zero
				// so they must be different. I done it like this because we we need them
				// both to be greater than 0, not necessary equal	
				if(shortest_path_solution[i] * spanning_tree_solution[i] == 0
				&& shortest_path_solution[i] + spanning_tree_solution[i] > 0){
					links_are_the_same = false;
				}
			}
			
			if(links_are_the_same){
				writeln("Links are the same for root: ", node, "!");			
			} else {
				writeln("Links are different for root: ", node, "!");
				writeln("Shorstest path: ", opl_shortest_path_model.Used);
				writeln("Spanning tree: ", opl_spanning_tree_model.Used);
			}
		
		} else {
			writeln("Not solved!");		
		}
		
		writeln("======== Finished  solving for node ", node, " ========");
	}
}



