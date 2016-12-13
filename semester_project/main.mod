/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 10, 2016 at 1:49:14 PM
 *********************************************/

main {
/*
	1) Wczytaj nasze dane
	2) Uruchom model graph_partition_model
		- Jakich danych potrzebuje?
		- Co powinien zwrócić?
	3) Uruchom model flow_allotion_model
		- Jakich danych potrzebuje?
		- Co powinien zwrócić?
	4)  Uruchom model qos_provisioning_model
		- Jakich danych potrzebuje?
		- Co powinien zwrócić
	5) Wyświetl wynik
	

*/

	var data_source = new IloOplDataSource("data.dat");
	var current_first_stage_solution = 0;
	var source = new IloOplModelSource("graph_partition_model.mod");
	var model_definition = new IloOplModelDefinition(source);
	var cplex_object = new IloCplex();
	var model = new IloOplModel(model_definition, cplex_object);
	
	function firstStage(){		
		model.addDataSource(data_source);
		model.generate();
		
		if (cplex_object.solve()){	
			writeln('Rozwiazanie optymalne');		
			for (var arc in model.x){
				writeln("krawedz ", arc, model.x[arc]);		
			}
			return model.x;
		} else {
			return false;		
		}
	}
    

	function secondStage(){
		// TODO: get data from first stage	
		var flow_alloc_source = new IloOplModelSource("flow_allocation_model.mod");
		var flow_alloc_model_definition = new IloOplModelDefinition(flow_alloc_source);
		var flow_alloc_cplex_object = new IloCplex();
		var flow_alloc_model = new IloOplModel(flow_alloc_model_definition, flow_alloc_cplex_object);
		flow_alloc_model.addDataSource(data_source);
		flow_alloc_model.generate();
		
		if (flow_alloc_cplex_object.solve()){
			return flow_alloc_model.lambda;
		} else {
			if (current_first_stage_solution < cplex_object.getSolnPoolNsolns()){
				writeln('Nie mozna rozwiazac dla rozwiazania ', current_first_stage_solution)
				current_first_stage_solution = current_first_stage_solution + 1;
				writeln('Rozwiazanie nr', current_first_stage_solution);		
				for (var arc in model.x){
					writeln("krawedz ", arc, model.x[arc]);		
				}	
				model.setPoolSolution(current_first_stage_solution);
				secondStage();		
			} else {
				writeln('Nie mozna rozwiazac dla zadnego z rozwiazan');			
				return false;		
			}
		}
	}
	
   	var first_model = firstStage();
   	var second_model = secondStage();
   	writeln(second_model);
   	
   	
	
	
	

}