/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 3, 2016 at 4:48:17 PM
 *********************************************/


// wczytaj wszystie nody 
// dla każdego node :
//  - podmien source node
// 	- wywołaj shortest_path_model (wezel) <zwraca list of Links>
// 	- wywołaj spanning_tree_model (wezel) <zwraca list of Links>
//  - for link in Links sprawdz czy nalezy do obydwu i czyli liczba loinkow w modelach sie zgadza

tuple Node {
	key int id;
};

{Node} others;

main{

	thisOplModel.generate();

	function prepareData(source, nodes){
		write("Preparing data for node: ", source);
		thisOplModel.others.clear();
		
		for(var node in nodes){
			if(source != node) {
				thisOplModel.others.add(node);			
			}		
		}
		
		var data = new IloOplDataElements();
		data.Source = source;
		data.Other = thisOplModel.others;
		
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
	
	var opl_original_model = new IloOplModel(spanning_tree_definition, cplex_spanning_tree_model);
	
	var model_input_data_source = new IloOplDataSource("graph.dat");

	opl_shortest_path_model.addDataSource(model_input_data_source);
	opl_spanning_tree_model.addDataSource(model_input_data_source);
	
	write("Generating models...");
	opl_shortest_path_model.generate();
	opl_spanning_tree_model.generate();
	write("\tDone!\n");
	
	var Nodes = opl_spanning_tree_model.Nodes;

	for( var node in Nodes){
		var data = prepareData(node, Nodes);	
		
		opl_spanning_tree_model.addDataSource(data);
		opl_shortest_path_model.addDataSource(data);
		
	
		if(cplex_shortest_path_model.solve() && cplex_spanning_tree_model.solve()){
			writeln("Both models were solved! for node ", node);
			var shortest_path_solution = opl_shortest_path_model.x;
			var spanning_tree_solution = opl_spanning_tree_model.x;
			
			for(var i in shortest_path_solution){
						
			// product 0 means that at least one on them is zero, but 
			// sum greater than zero means that at least one of them is not zero
			// so they must be different. I done it like this because we we need them
			// both to be greater than 0, not necessary equal
				if(shortest_path_solution[i] * spanning_tree_solution == 0
				&& shortest_path_solution[i] + spanning_tree_solution > 0){
					writeln("Nie działa dla Node'a: ", node);
				} else {
					writeln("Cokolwiek!");				
				}
			}
		
		} else {
			writeln("Not solved :( ");		
		}
	
	}
}



