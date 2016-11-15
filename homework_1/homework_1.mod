/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Nov 12, 2016 at 6:05:53 PM
 *********************************************/

{string} Products = ...;
int DailyProteinDemand = ...;
int MaxDailyFatDemand = ...;

float Proteins[Products] = ...;
float Fats[Products] = ...;
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
	  	
	obesity:
	sum(p in Products)
	  	Amount[p]*Fats[p] <= MaxDailyFatDemand;
}

string UNIT = "g";
string CURRENCY = "zloty";

execute {

	function printAmount(product){
		write("    ");
		write(product, ": ", 100*Amount[product], UNIT);
		writeln();
	}
	
	writeln("Optimized for: ", DailyProteinDemand, " proteins [", UNIT, "]");
	
	writeln("Amounts: ");
  	for (var p in Products) {
    	printAmount(p);
  	}

	writeln("Total cost: ", cplex.getObjValue(), " ", CURRENCY);
	
}