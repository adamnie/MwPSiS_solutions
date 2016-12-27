/*********************************************
 * OPL 12.5 Model
 * Author: cholda
 * Creation Date: 10 Dec 2014 at 17:26:38
 *********************************************/
 
 main {
   
	var source_master = new IloOplModelSource("initial_master_problem.mod");
	var cplex_master = new IloCplex();
	var def_master = new IloOplModelDefinition(source_master);
	var opl_master = new IloOplModel(def_master,cplex_master);
	var data_master = new IloOplDataSource("master_problem.dat");
	opl_master.addDataSource(data_master);
	opl_master.generate();

	writeln();
    writeln("---------------------------------------------");
    writeln("---------------PROBLEM DATA------------------");
    writeln("---------------------------------------------");
    writeln();
    writeln("Nodes:",opl_master.Nodes,".");
    writeln();
   	writeln("Arcs:",opl_master.Arcs,".");
	writeln();
	for(var a in opl_master.Arcs)
		writeln("Capacity of arc",a," equals ",opl_master.Capacity[a],".");
	writeln();
    for(var d in opl_master.Demands)
    	writeln("Demand's",d," volume equals ",opl_master.Volume[d],".");
	writeln();
	writeln("We assume no more than ",opl_master.Path," iterations.");
	writeln();
    writeln("---------------------------------------------");
    writeln("---------START OF PATH GENERATION------------");
    writeln("---------------------------------------------");
    writeln();
    
	var stop_condition = 1;
	var failure_condition = 1;
	var index = 0;
    var check_dual_values = new Array(opl_master.Arcs);
    for(var a in opl_master.Arcs)
    	check_dual_values[a] = 0;

	while(stop_condition){
   								
		if (cplex_master.solve()) {
			writeln("OBJ Master Problem = ",cplex_master.getObjValue(),", iteration: ",index+1,".");
			for(var d in opl_master.Demands)
				for(var p in opl_master.Paths)
					if(opl_master.flow[d][p]>0)
					{
						write("Demand",d," uses path no. ",p," containing links:");
						for(var a in opl_master.Arcs)
							if(opl_master.delta[a][d][p]>0)
							write(a," - ");
						writeln(".");
    				}						
			for(var a in opl_master.Arcs)
			{
				write("Load on arc",a," equals: ",opl_master.flow_summarized[a],". ");
				if(opl_master.flow_summarized[a] > opl_master.Capacity[a])
					write("This load value exceeds the available capacity!");
				writeln();
  			}
  			for(var a in opl_master.Arcs)
				writeln("Dual variable related to arc",a," equals ",opl_master.pi[a].dual,".");				
		}
		else {
			writeln("No solution for master problem!");
		}
	
		var source_newpath = new IloOplModelSource("new_path.mod");
		var cplex_newpath = new IloCplex();
		var def_newpath = new IloOplModelDefinition(source_newpath);
		var opl_newpath = new IloOplModel(def_newpath,cplex_newpath);
		var data_newpath = new IloOplDataElements();
		data_newpath.Nodes = opl_master.Nodes;
		data_newpath.Arcs = opl_master.Arcs;
		data_newpath.Demands = opl_master.Demands;
		data_newpath.Cost = opl_master.Cost;
		for(var a in opl_master.Arcs)
			data_newpath.Cost[a] = opl_master.pi[a].dual;
		opl_newpath.addDataSource(data_newpath);
		opl_newpath.generate();
		
		if (!cplex_newpath.solve())
			writeln("No solution for pricing problem!");
		//The pricing problem would be infeasible only if the network is disconnected (invalid input data)

		var data_master_new = new IloOplDataElements();
		data_master_new.Nodes = opl_master.Nodes;
		data_master_new.Arcs = opl_master.Arcs;	
		data_master_new.Demands = opl_master.Demands;
		data_master_new.Capacity = opl_master.Capacity;
		data_master_new.Volume = opl_master.Volume;	
		data_master_new.Path = opl_master.Path;
		data_master_new.delta = opl_master.delta;
		
		index = index + 1;

		if(cplex_master.getObjValue() >=0)
		{
			stop_condition=0;
			failure_condition=0;	
		} 

		if(index == opl_master.Path)
			stop_condition=0;
		//We reached the assumed number of iterations
		
		var dual_values_not_changed = 1;
		for(var a in opl_master.Arcs)
		{
			if(opl_master.pi[a].dual != check_dual_values[a])
				dual_values_not_changed = 0;
			
			check_dual_values[a] = opl_master.pi[a].dual;
  		}				
		
		if(dual_values_not_changed)
		{
			stop_condition=0;
			writeln("Lack of improvement in dual variables.");
 		}				
		//The set of dual variables is not changed in comparison to the previous step: no improvement possible
		
		for(var a in opl_master.Arcs)			
			 for(var d in opl_master.Demands)
			 	if(opl_newpath.x[a][d] > 0) data_master_new.delta[a][d][index] = 1;
			 		else data_master_new.delta[a][d][index] = 0;
		//Addition of new paths found as the shortest paths in the pricing problem
		//In fact, we replace the dummy all-link-paths by the ones obtained in the pricing problem
		
		if(stop_condition)
		{
			writeln("New candidate paths found:");
			for(var d in opl_master.Demands)
			{
				write("For demand",d,": ");					
				for(var a in opl_master.Arcs)			
					if(data_master_new.delta[a][d][index] > 0)
						write(a," - ");
		    	writeln(".");
			}
		}		
		
		opl_master.end();
		opl_newpath.end();
		
		var source_master1 = new IloOplModelSource("master_problem.mod");
		var cplex_master = new IloCplex();
		var def_master1 = new IloOplModelDefinition(source_master1);
		opl_master = new IloOplModel(def_master1,cplex_master);
		
		opl_master.addDataSource(data_master_new);
		opl_master.generate();
		
		writeln();
    	writeln("---------------------------------------------");
    	writeln();
		
}	
	
	opl_master.end();
	data_master.end(); 
	data_master_new.end();
	def_master.end(); 
	cplex_master.end(); 
	source_master.end(); 
		
	data_newpath.end(); 
	def_newpath.end(); 
	cplex_newpath.end(); 
	source_newpath.end(); 
	
	if (failure_condition)
		writeln("FEASIBLE SOLUTION CANNOT BE FOUND!");	
	else
		writeln("FEASIBLE SOLUTION HAS BEEN FOUND DURING ITERATION NO. ",index,"!");	
   
 } 