/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Nov 12, 2016 at 6:05:53 PM
 *********************************************/

{string} Products = ...;
int DailyProteinDemand = ...;

float Proteins[Products] = ...;
float Cost[Products] = ...;
float MaxIntake[Products] = ...;


dvar float+ Amount[Products];

minimize
	sum(p in Products)
	  Cost[p] * Amount[p];


subject to {

	overdose:
	forall(p in Products)
		Amount[p] <= MaxIntake[p];
	
  	hunger:
	sum(p in Products)
	  	Amount[p]*Proteins[p] >= DailyProteinDemand;
}

execute {
	function printAmount(product){
		write("    ");
		write(product); write(": "); write(100*Amount[product]);write("g")
		writeln();
	}
	
	writeln("Optimized for: ", DailyProteinDemand, " proteins [g]")
	
	writeln("Amounts: ");
  	for (var p in Products) {
    	printAmount(p);
  	}

	writeln("Total cost: ", cplex.getObjValue(), " zloty");
	
}