/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Dec 10, 2016 at 1:49:14 PM
 *********************************************/

main {	
	function calculateVariance(array){
		var sum = 0;
		for (var i = 0; i<array.length; i++){
			sum = sum + array[i];		
		}
		var mean = sum/array.length;
		
		var sum_variance = 0;
		for (var i = 0; i<array.length; i++){
			sum_variance = sum_variance + (array[i] - mean)*(array[i] - mean);		
		}
		
		writeln("Sum: ", sum);
		writeln("Mean: ", mean);
		writeln("Sum variance: ", sum_variance);
		writeln("Sum variance/array.length: ", sum_variance/array.length);
		writeln("================");
				
		return sum_variance/array.length;
	}

	function checkQoSRequirements(model){
   		writeln("Checking QoS requirements");
   		var sum_lambda = 0;
   		for (var tenant in model.Tenants){
   			for (var flow in model.Flows){
   				sum_lambda = sum_lambda + model.lambda[tenant][flow];		
   			}   		
   		}
   		
   		if (sum_lambda == 0){
   			writeln("Lamda = 0 !");
   			return false;   		
   		}
   
   		return  (checkDelayRequirement(model) && 
   				checkJitterRequirement(model) &&
   				checkPacketLossRequirement(model))
   	}
   	
   	function checkDataRateRequirement(model){
   	   	for(var arc in model.Arcs){
		  	for(var tenant in model.Tenants){
		  		for(var flow in model.Flows){
		  			if (model.X[arc][tenant][flow] > 0){
		  				if (model.lambda[tenant][flow] > model.X[arc][tenant][flow]){		  				
		  					writeln("Check data rate: False");
		  					return false;		  				
		  				}		  			
		  			}	
		  		}  	
			}  	
  		}
  		
  		writeln("Check data rate: True");	
  		return true;
   	}
   	
   	function checkDelayRequirement(model){
   		for(var tenant in model.Tenants){
		  	for(var flow in model.Flows){
		  		var sum_delay = 0;
		  		for (var arc in model.Arcs){
		  			if (model.X[arc][tenant][flow] > 0.001){		  			
		  				sum_delay = sum_delay + (1.0/model.X[arc][tenant][flow]) + model.QueuingDelay;	  			
		  			}		  		
		  		}		  	
		  		
		  		if (sum_delay > flow.max_delay){
		  			writeln("Check delay: False");
		  			writeln("Delay value: ", sum_delay);		  	
		  			return false;		  		
		  		}
		 	}  		  
		}
   	   	
   		writeln("Check delay: True");	
   	   	return true;
   	}
   	
   	function checkJitterRequirement(model){
   	   	for(var tenant in model.Tenants){
		  	for(var flow in model.Flows){
		  		if(flow.tenant_id == tenant){
		  			var array = new Array();	  
			  		var i = 0;	
			  		for (var arc in model.Arcs){
			  			if (model.X[arc][tenant][flow] > 0.001){
			  				array[i] = 1.0/model.X[arc][tenant][flow] + model.QueuingDelay;
			  				writeln("Adding: ", array[i], " i=", i);
			  				i = i+1;
			  			}	  		  		
			  		}
			  		writeln("Array length:", array.length);
			  		
			  		var jitter = calculateVariance(array);
			  		
			  		if (jitter > flow.max_jitter) {
	  					writeln("Check jitter: False");
			  			writeln("Jitter value: ", jitter);		  	
			  			return false;
	  				}		  		
		  		}		  			  			
		  	}  
  		}
  		
  		writeln("Check jitter: True");	
		writeln("Jitter value: ", jitter);		
   	   	return true;
   	}
   	
   	function checkPacketLossRequirement(model){
   	   	
   	
   		for (var tenant in model.Tenants) {
		  for (var flow in model.Flows) { 
		  	var prod_packet_loss = 1;	  
		  
		    for (var arc in model.Arcs){	    
		    
		    	if (model.X[arc][tenant][flow] > 0.001){	   	
		    		prod_packet_loss = prod_packet_loss * arc.packet_loss;	
		    	}  
		    			    
		    }
		    
		    		    
		    if (Opl.sqrt(prod_packet_loss) < flow.max_packet_loss) {
		   		writeln("Check packetloss: False");		
		   		writeln("packet loss value: ", Opl.sqrt(prod_packet_loss), " for tenant ", tenant.id);	    	
		   		writeln("flow packet loss: ", flow.max_packet_loss);	    
		    	return false;		    
		    }
		  }   
		}	
			
		writeln("Check packetloss: True");		
   	   	return true;
  }   	

	var data_source = new IloOplDataSource("graph_partition_data2.dat");
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
	
	function thirdStage(flow_alloc_model, flow_alloc_stage_solution, flow_alloc_cplex_object){
		writeln("Lambda: ");
		writeln(flow_alloc_model.lambda);
		writeln();
	
		writeln("X: ");
		writeln(flow_alloc_model.X);
		writeln("----------");	
	
		if (checkQoSRequirements(flow_alloc_model)){
			var tab = "  "; 
 
			for(var tenant in flow_alloc_model.Tenants){
				writeln("Tenant: ", tenant.id);
				for(var flow in flow_alloc_model.Flows){
					if(flow.tenant_id == tenant){
						writeln(tab, "Flow: ", flow.id);			
						writeln(tab, tab, "Lambda: ", flow_alloc_model.lambda[tenant][flow]);
						write(tab, tab, "Arcs: ");
						for(var arc in flow_alloc_model.Arcs){
							if(flow_alloc_model.X[arc][tenant][flow] > 0 ){
								write(arc.name, " ");		
		   					}					
						}
						writeln();
					}
				}	
			}
			return true;
		} else {
			if (flow_alloc_stage_solution < flow_alloc_cplex_object.getSolnPoolNsolns()){
				writeln('Nie mozna rozwiazac dla przeplywow ', flow_alloc_stage_solution)
				flow_alloc_stage_solution = flow_alloc_stage_solution + 1;
				writeln('Rozwiazanie przeplywu nr: ', flow_alloc_stage_solution);		
				flow_alloc_model.setPoolSolution(flow_alloc_stage_solution);
				thirdStage(flow_alloc_model, flow_alloc_stage_solution, flow_alloc_cplex_object);
			} else {
				writeln("Brak rozwi�za� dla przep�yw�w: ", flow_alloc_stage_solution);	
			}
		 	return false;
		}
	}
    
	function secondStage(){
		var flow_alloc_source = new IloOplModelSource("flow_allocation_model.mod");
		var flow_alloc_model_definition = new IloOplModelDefinition(flow_alloc_source);
		var flow_alloc_cplex_object = new IloCplex();
		var flow_alloc_model = new IloOplModel(flow_alloc_model_definition, flow_alloc_cplex_object);
		var data_source = new IloOplDataSource("flow_allocation_data.dat");
		
		flow_alloc_model.addDataSource(data_source);
		flow_alloc_model.generate();
		
		var dataElements = new IloOplDataElements();
		dataElements.Nodes = flow_alloc_model.Nodes;
		dataElements.Arcs = flow_alloc_model.Arcs;
		dataElements.Flows = flow_alloc_model.Flows;
		dataElements.Tenants = flow_alloc_model.Tenants;
		dataElements.QueuingDelay = flow_alloc_model.QueuingDelay;
		dataElements.x = model.result;
		
		writeln("x: ");
		writeln(dataElements.x);
		
		var flow_alloc_cplex_object = new IloCplex();
		var flow_alloc_model = new IloOplModel(flow_alloc_model_definition, flow_alloc_cplex_object);
		flow_alloc_model.addDataSource(dataElements);
		flow_alloc_model.generate();
				
		var flow_alloc_stage_solution = 0;
		
		if (flow_alloc_cplex_object.solve() && thirdStage(flow_alloc_model, flow_alloc_stage_solution, flow_alloc_cplex_object)){
			writeln("Jest rozwi�zanie!");
		} else {
			if (current_first_stage_solution < cplex_object.getSolnPoolNsolns()){
				writeln('Nie mozna rozwiazac dla topologi ', current_first_stage_solution)
				current_first_stage_solution = current_first_stage_solution + 1;
				writeln('Rozwiazanie nr', current_first_stage_solution);		
				for (var arc in model.x){
					writeln("krawedz ", arc, model.x[arc]);		
				}	
				model.setPoolSolution(current_first_stage_solution);
				secondStage();
			} else {
				writeln('Nie mozna rozwiazac dla zadnej topologii');			
				return false;		
			}
		}
	}
	
   	var first_model = firstStage();
   	var second_model = secondStage();
}