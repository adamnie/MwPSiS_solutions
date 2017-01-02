/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Jan 2, 2017 at 12:11:19 PM
 *********************************************/

 tuple Client{
  int id;
 };
 
 tuple Location {
  int id; 
  {Client} available_clients;
 };
 
 tuple Device {
  int id;
  Location location;
 };
 
 {Client} Clients = ...;
 {Location} Locations = ...;
 Device Devices[Locations] = ...;
 int cost[Locations][Devices] = ...;
 int clientCountForDevice[Locations][Devices] = ...;
 
 dvar int+ is_device_used[Locations][Devices];
 dvar int+ is_client_at_location[Clients][Locations];
 
 minimize
 	sum(location in Locations)
 	  sum(device in Devices[location])
 		cost[location][device] * is_device_used[location][device];
 
 subject to {
 	forall(client in Clients){
 	single_location_for_client: 	
 	 	sum(location in Locations : location.available_clients.contains(client))
 	 	  is_client_at_location == 1;
 	} 
 	
 	forall(location in Locations){
 	no_client_overload: 	
 		sum(client in Clients: location.available_clients.contains(client))
 		  is_client_at_location[client][location] <=
 		sum(device in Devices[location])
 		  is_device_used[location][device] * clientCountForDevice[location][device]; 	
 	}
 	
 	forall(location in Locations){
	one_device_for_location:
 	 	sum(device in Devices[location])
 	 	  y[location][device] <= 1;
 	}
 }		
 		
 		
 execute {
 	writeln("Działa?");
 }