/*********************************************
 * OPL 12.5 Model
 * Author: cholda
 * Creation Date: 17 Dec 2013 at 15:20:50
 *********************************************/

 {string} Nodes = ...;
 
 tuple arc
 {
   string source;
   string destination;
 }   
 
 {arc} Arcs with source in Nodes, destination in Nodes = ...;

 float Capacity[Arcs] = ...;
 
 float Cost[a in Arcs] = 0;
 
 /*execute{
   	for(var a in Arcs)
 		Cost[a] = 0;  
  }*/	
 
 tuple demand
 {
   string source;
   string destination;
 }   
 
 {demand} Demands with source in Nodes, destination in Nodes = ...;
 
 float Volume[Demands] = ...;
 
 int Path = 100;
 
 range Paths = 1..Path;
 
 //int delta[Arcs][Demands][Paths] = ...;

 int delta[a in Arcs][d in Demands][p in Paths] = 1;

 dvar float+ flow[Demands][Paths];
 
 dvar float+ flow_summarized[Arcs];
 
 dvar float z;
 
 maximize z;
  
 subject to{
   	
   forall(d in Demands)
     lambda:
     sum(p in Paths) flow[d][p] == Volume[d];
   
   forall(a in Arcs)
   	 sum(d in Demands, p in Paths) delta[a][d][p]*flow[d][p] == flow_summarized[a];  
     
   forall(a in Arcs)
     pi:
   	 flow_summarized[a] <= Capacity[a] - z;
   	 //Note that now we would like z to be as large as possible, if z<0 then we have not found the flows not exceeding the capacities    
    
 } 