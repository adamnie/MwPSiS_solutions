/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 10, 2016 at 1:49:14 PM
 *********************************************/

main {

	writeln("BBBB");
    var source = new IloOplModelSource("graph_partition_model.mod");
	var model_definition = new IloOplModelDefinition(source);
	var cplex_object = new IloCplex();
	var model = new IloOplModel(model_definition, cplex_object);
	var data_source = new IloOplDataSource("data.dat");
	model.addDataSource(data_source);
	model.generate();
	
	var tenants = model.Tenants;

	if (cplex_object.solve()){
		writeln(model.x);
		for (var arc in model.x){
			writeln("wspolna krawedz", arc, model.x[arc]);		
//			if (model.x[arc][0] && model.x[arc][1]){
//				writeln("wspolna krawedz", arc);
//			}
		}		
	}
	
	writeln("CCCC");

}