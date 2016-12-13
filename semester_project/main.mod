/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 10, 2016 at 1:49:14 PM
 *********************************************/

main {

	var data_source = new IloOplDataSource("data.dat");


    var source = new IloOplModelSource("graph_partition_model.mod");
	var model_definition = new IloOplModelDefinition(source);
	var cplex_object = new IloCplex();
	var model = new IloOplModel(model_definition, cplex_object);
	model.addDataSource(data_source);
	model.generate();
	
	if (cplex_object.solve()){
		for (var arc in model.x){
			writeln("krawedz", arc, model.x[arc]);		
		}		
	}
	

	
    var flow_alloc_source = new IloOplModelSource("flow_allocation_model.mod");
	var flow_alloc_model_definition = new IloOplModelDefinition(flow_alloc_source);
	var flow_alloc_cplex_object = new IloCplex();
	var flow_alloc_model = new IloOplModel(flow_alloc_model_definition, flow_alloc_cplex_object);
	flow_alloc_model.addDataSource(data_source);
	flow_alloc_model.generate();
	
	if (flow_alloc_cplex_object.solve()){
		writeln(flow_alloc_model.lambda);	
	}

}