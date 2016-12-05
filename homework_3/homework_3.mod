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
	int id;
};

tuple Link {
	string name;
	Node input_node;
	Node ouput_node;
	int cost;
};

main{

	write("Preparing model for shortest path...");
	var shortest_path_model_source = new IloOplModelSource("shortest_path_model.mod");
	var shortest_path_definition = new IloOplModelDefinition(shortest_path_model_source);
	var opl_shortest_path_model = new IloOplModel(shortest_path_definition, new IloCplex());
	write("\tDone!\n");
	
	write("Preparing model for spanning tree...");
	var spanning_tree_model_source = new IloOplModelSource("spanning_tree_model.mod");
	var spanning_tree_definition = new IloOplModelDefinition(spanning_tree_model_source);
	var opl_spanning_tree_model = new IloOplModel(spanning_tree_definition, new IloCplex());
	write("\tDone!\n");
	
	var model_input_data_source = new IloOplDataSource("homework_3.dat");

	opl_shortest_path_model.addDataSource(model_input_data_source);
	opl_spanning_tree_model.addDataSource(model_input_data_source);
	
	opl_shortest_path_model.generate();
	opl_spanning_tree_model.generate();
	
	{Node} Nodes = opl_shortest_path_model.Nodes;
//	{Link} Links = opl_shortest_path_model.Links;

	for( var node in Nodes){
//		var data_for_iteration = generateDataFor(raw_data, node);
//		opl_shortest_path_model.addDataSource(data_for_iteration);
//		opl_spanning_tree_model.addDataSource(data_for_iteration);
		
		if(opl_shortest_path_model.solve() && opl_spanning_tree_model.solve()){
			writeln("Both models were solved! for node ", node);		
		}
		
	}
}



