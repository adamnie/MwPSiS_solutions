/*********************************************
 * OPL 12.6.3.0 Model
 * Author: adam
 * Creation Date: Jan 2, 2017 at 12:11:19 PM
 *********************************************/


int ClientNum = ...;
range Clients = 1..ClientNum;

int LocationNum = ...;
range Locations = 1..LocationNum;

int DeviceNum = ...;
range Devices = 1..DeviceNum;

int devicesAtLocations[Locations][Devices] = ...;
int locationIsAvailableToClient[Clients][Locations] = ...;

int maxClientsForDeviceAtLocation[Locations][Devices] = ...;
int cost[Locations][Devices] = ...;
 
dvar int+ isClientAtLocation[Clients][Locations];
dvar int+ isDeviceAtLocation[Locations][Devices];

minimize
	sum(location in Locations, device in Devices)
	  	(cost[location][device]*isDeviceAtLocation[location][device]);
 
subject to {
 	forall(client in Clients){
 		single_location_for_client: 	
		sum(location in Locations: locationIsAvailableToClient[client][location] == 1)
		  (isClientAtLocation[client][location]) == 1;
 	} 
 	
 	forall(location in Locations){
 		no_client_overload: 	
		( sum(client in Clients : locationIsAvailableToClient[client][location] == 1)
		  isClientAtLocation[client][location] )
			<=
		( sum(device in Devices : devicesAtLocations[location][device] == 1)
		  maxClientsForDeviceAtLocation[location][device] * isDeviceAtLocation[location][device]);
 	}
 	
 	forall(location in Locations){
		one_device_for_location:
 	 	sum(device in Devices, location in Locations: devicesAtLocations[location][device] == 1)
	 	  isDeviceAtLocation[location][device] <= 1;
	}
}		
 		
 		
execute {
	writeln("Działa?");
	// wypisac ktorzy clienci, do kotrych lokalizacji
	// i jaki był calkowity koszt
}