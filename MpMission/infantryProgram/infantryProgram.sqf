/**
 * InfantryProgram.sqf
 *
 * TNA-Community
 * https://discord.gg/Zs23URtjwF
 * © 2021 {|||TNA|||}WAKeupneo
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
private [];
params [
	"_callerObject"
];

WMS_IP_addActionRadio = {
	params [
		"_IPplayer"
	];
//BUILD THE COMPUTER
	_IPplayer addAction
	[
		"<t size='0.9' color='#068604'>Build InfantryProgram computer</t>",
		"
			_target = _this select 0; _caller = _this select 1; _theAction = _this select 2;
			['Building Computer', 5, {true}, 
				{
					[(_this select 0 select 1)] call WMS_IP_buildComputer;
					(_this select 0 select 0) removeaction (_this select 0 select 2);
				}, 
				{hint 'aborted'},
				[_target,_caller,_theAction]
			] call CBA_fnc_progressBar;
		", 
		[],
		1,
		true,
		true,
		"",
		"
			(alive _target) &&
			{stance player == 'CROUCH'} &&
			{('rhs_radio_R187P1' in (assigneditems _this)) || ('rhsusf_radio_anprc152' in (assigneditems _this))} &&
			{localNamespace getVariable ['WMS_Loc_CanBuildComputer',true]} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(vehicle _this == _this)};
		",
		5
	];
};

[player] call WMS_IP_addActionRadio;

WMS_IP_buildComputer = {
	params [
		"_IPplayer"
	];
	private _IPantenna = "SatelliteAntenna_01_Small_Black_F" createvehicle [0,0,0];
	private _IPcomputer = "Land_MultiScreenComputer_01_black_F" createvehicle [0,0,0];
	private _mkr = createMarkerLocal [format ['MKRSB_%1', (round time)], position _IPplayer]; 
  	_mkr setMarkerTypeLocal 'respawn_unknown'; 
  	_mkr setMarkerColorLocal 'colorIndependent';
	if (surfaceIsWater (position _IPplayer))then{
		_IPcomputer setPos (_IPplayer modeltoworldworld [0,2,0]); //FUCK YOU ARMA!!!!!!!!!!!
	}else{
		_IPcomputer setPos (_IPplayer modeltoworld [0,1,0.2]);
	};
	_IPcomputer setdir (direction _IPplayer);
	_IPantenna attachTo [_IPcomputer, [0,0.4,0.27]];
	_IPcomputer setVariable ['IPcomputerAllActionsID',[]];
	_IPcomputer setVariable ['WMS_Loc_SpawnBeacon_Mkr',_mkr,true];
	localNamespace setVariable ['WMS_Loc_CanBuildComputer',false];
	private _allActionsID = [];
//PACK THE COMPUTER //respawn_unknown
	private _IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Pack the Computer</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			_allActionsID = _target getVariable ['IPcomputerAllActionsID',[]];
			_myRespawn = _target getVariable ['WMS_Loc_SpawnBeacon',[]];
			_mkr = _target getVariable 'WMS_Loc_SpawnBeacon_Mkr';
			deleteMarkerLocal _mkr;
			diag_log format['[WMS_IP DEBUG] removeRespawnPosition variable %1',_myRespawn];
			_myRespawn call BIS_fnc_removeRespawnPosition;
			detach (_this select 3 select 0);
			deleteVehicle (_this select 3 select 0);
			deleteVehicle _target;
			localNamespace setVariable ['WMS_Loc_CanBuildComputer',true];
			{_target removeaction _x} foreach _allActionsID;
			[_caller] call WMS_IP_addActionRadio;

		", 
		[_IPantenna],
		1,
		true,
		true,
		"",
		"
			(alive _target) &&
			{stance player == 'CROUCH'} &&
			{('rhs_radio_R187P1' in (assigneditems _this)) || ('rhsusf_radio_anprc152' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;

//SOUND TEST //playSound3D ['A3\Sounds_F\sfx\blip1.wss', _caller]
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>GetToTheChoppa</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			playSound3D [getMissionPath 'Custom\Ogg\GetToTheChoppa.ogg', _caller, false, position _caller, 5]
		", 
		[_IPantenna],
		1,
		true,
		true,
		"",
		"
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Rolling</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			playSound3D [getMissionPath 'Custom\Ogg\Vietnam.ogg', _caller, false, position _caller, 5]
		", 
		[_IPantenna],
		1,
		true,
		true,
		"",
		"
			(alive _target) &&
			{('rhsusf_radio_anprc152' in (assigneditems _this))} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//LOADOUT	
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Equipement Scorpion 2.5k$</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			[_caller, [], (position _caller), WMS_Loadout_Scorpion, 2500] remoteExec ['WMS_fnc_InfantryProgram_loadouts',2];
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Equipement AOR2 3.5k$</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			[_caller, [], (position _caller), WMS_Loadout_AOR2, 3500] remoteExec ['WMS_fnc_InfantryProgram_loadouts',2];
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((getplayerUID player) in WMS_InfantryProgram_list)} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{!((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//REQUEST C130	
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Request C130, Need Parachute</t>",
		"
			[] call WMS_fnc_IP_c130_Request;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_MoveInCargo_C130_LastTime + WMS_InfantryProgram_C130CoolDown))} && 
			{(time > (WMS_Loc_InfProg_C130_Last + WMS_Loc_InfProg_C130_CoolDown))} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//EXTRACTION CHOPPER
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Request Extraction Chopper</t>",
		"
			[] call WMS_fnc_IP_ExtractionRequest;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_IP_ExtractChop_LastT + WMS_IP_ExtractChop_CoolD))} && 
			{(time > (WMS_Loc_InfProg_Extraction_Last + WMS_Loc_InfProg_Extraction_CoolDown))} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//EXTRACTION CHOPPER optional radio, no IP
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Request Extraction Chopper</t>",
		"
			[] call WMS_fnc_IP_ExtractionRequest;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhsusf_radio_anprc152' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_IP_ExtractChop_LastT + WMS_IP_ExtractChop_CoolD))} && 
			{(time > (WMS_Loc_InfProg_Extraction_Last + WMS_Loc_InfProg_Extraction_CoolDown))} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//GROUND EXTRACTION
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Request Ground Extraction</t>",
		"
			[] call WMS_fnc_IP_GNDextractionRequest;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_Extraction_GND_LastTime + WMS_Extraction_GND_CoolDown))} && 
			{(time > (WMS_Loc_InfProg_GNDextraction_Last + WMS_Loc_InfProg_GNDextraction_CoolDown))} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//ARTILLERY HE
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Artillery HE, 10k$ </t>",
		"
			[_this select 1,'HE',10000] spawn WMS_fnc_IP_ArtySupport;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_IP_ArtySup_LastT + WMS_IP_ArtySup_CoolD))} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//BLACKFISH SUPPORT
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>BlackFish Support 30k$ </t>",
		"
			[(_this select 1)] spawn WMS_fnc_IP_BlackFishSupport;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_IP_BlackFishSup_LastT + WMS_IP_BlackFishSup_CoolD))} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//AMMO SUPPLY DROP
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Ammo SupplyDrop 3500$ </t>",
		"
			[(position (_this select 1)), (_this select 1), 3500, 0, 'IP_ammo'] remoteexec ['WMS_fnc_InfantryProgram_buy',2];
			WMS_Loc_InfProg_Supply_Last = time;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_Loc_InfProg_Supply_Last + WMS_Loc_InfProg_Supply_CoolDown))} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//TOOL KIT
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Tool Kit 12k$ </t>",
		"
			[(position (_this select 1)), (_this select 1), 12000, 0, 'IP_toolKit'] remoteexec ['WMS_fnc_InfantryProgram_buy',2];
			WMS_Loc_InfProg_Supply_Last = time;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_Loc_InfProg_Supply_Last + WMS_Loc_InfProg_Supply_CoolDown))} &&
			{((getPlayerUID _this) in WMS_InfantryProgram_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//RPG7 CRATE
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>RPG7 Crate 10k$ </t>",
		"
			[(position (_this select 1)), (_this select 1), 10000, 0, 'IP_launcher'] remoteexec ['WMS_fnc_InfantryProgram_buy',2];
			WMS_Loc_InfProg_Supply_Last = time;
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(time > (WMS_Loc_InfProg_Supply_Last + WMS_Loc_InfProg_Supply_CoolDown))} &&
			{((getPlayerUID _this) in WMS_IP_Active_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//QUANTUM RADAR
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Quantum Radar</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			systemChat 'calling';
			[300, 'chest', _caller] spawn WMS_fnc_IP_OpforVHL_Radar; 
			_caller removeMagazine 'FilesSecret'; 
			_caller removeMagazine 'FileNetworkStructure'; 
			_caller removeMagazine 'FileTopSecret';
			systemChat 'called';
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(magazines _this find 'FilesSecret' >= 0)} && 
			{(magazines _this find 'FileNetworkStructure' >= 0)} && 
			{(magazines _this find 'FileTopSecret' >= 0)} && 
			{(backpack _this == 'B_RadioBag_01_wdl_F')} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
//INFANTRY RADAR
	/*_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Infantry Radar</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			systemChat 'calling';
			[300, 'chest', _caller] spawn WMS_fnc_IP_OpforVHL_Radar; 
			_caller removeMagazine 'FlashDisk';
			systemChat 'Action called';
		", 
		[],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(magazines _this find 'FlashDisk' >= 0)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;*/
//Medical Drop
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#068604'>Meds Emergency Drop 3000$</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			systemChat 'calling Office Trader';
			if ((_this select 1) getVariable ['ExileMoney', 0] >= (_this select 3) select 1) then {
				if ((_this select 1) getVariable ['ExileScore', 0] >= (_this select 3) select 2) then {
					hint ((_this select 3) select 4);
					systemChat 'Choose the DZ on the map';
					[(_this select 3) select 0,(_this select 3) select 1,(_this select 1),(_this select 3) select 3] remoteExec ['WMS_fnc_BuyFromOffice'];
				} else {
					hint 'Bro! your respect is too low';
					execVM 'Custom\Intro\levels.sqf';
				};
			} else {
				hint 'You are too poor Dude';
			};
		", 
		['EmergencySupplyMeds',3000,0,'EmergencySupplyMeds','Choose the DZ on the map'],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
	
//Halo Jump
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#ff5324'>Halo Jump 3500$</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			systemChat 'calling Office Trader';
			if ((_this select 1) getVariable ['ExileMoney', 0] >= (_this select 3) select 1) then {
				if ((_this select 1) getVariable ['ExileScore', 0] >= (_this select 3) select 2) then {
					hint ((_this select 3) select 4);
					systemChat 'Choose the DZ on the map';
					[(_this select 3) select 0,(_this select 3) select 1,(_this select 1),(_this select 3) select 3] remoteExec ['WMS_fnc_BuyFromOffice'];
				} else {
					hint 'Bro! your respect is too low';
					execVM 'Custom\Intro\levels.sqf';
				};
			} else {
				hint 'You are too poor Dude';
			};
		", 
		['HaloJump',3500,0,'HaloJump','Choose the DZ on the map'],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
	
//Spawn Beacon
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#ff5324'>Activate Spawn Beacon</t>",
		"
			_target = _this select 0; _caller = _this select 1;
			if ((_this select 1) getVariable ['ExileScore', 0] >= (_this select 3) select 2) then {
				hint ((_this select 3) select 4);
				_myRespawn = [_caller,(position _target),'Spawn Beacon'] call BIS_fnc_addRespawnPosition;
				diag_log format['[WMS_IP DEBUG] addRespawnPosition variable %1',_myRespawn];
				_mkr = _target getVariable 'WMS_Loc_SpawnBeacon_Mkr';
				_target setVariable ['WMS_Loc_canSpawnBeacon',false,true];
				_target setVariable ['WMS_Loc_SpawnBeacon',_myRespawn,true]; 
  				_mkr setMarkerTypeLocal 'respawn_para'; 
  				_mkr setMarkerColorLocal 'colorIndependent';
			} else {
				hint 'Bro! your respect is too low';
				execVM 'Custom\Intro\levels.sqf';
			};
		", 
		['SpawnBeacon',2500,6000,'SpawnBeacon','Spawn Beacon Activated'],
		1,
		true,
		true,
		"",
		"	
			(alive _target) &&
			{('rhs_radio_R187P1' in (assigneditems _this))} &&
			{_target getVariable ['WMS_Loc_canSpawnBeacon',true]} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;

	///////////////////TEST//////////////////////
	//['Spawn Beacon Timed', 5, {true}, {hint 'done'}, {hint 'aborted'}] call CBA_fnc_progressBar;
	
//Spawn Beacon timed test
	/*_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#ff5324'>Spawn Beacon Timed</t>",
		"
			_target = (_this select 0); 
			_caller = (_this select 1);
			_theHint = ((_this select 3) select 4);
			if ((_this select 1) getVariable ['ExileScore', 0] >= (_this select 3) select 2) then {
				
				['Spawn Beacon Timed', 3, {true}, 
					{
						diag_log format ['[WMS|TNA|WAK] _this = %1', _this];
						_myRespawn = [(_this select 0 select 1),(position (_this select 0 select 0)),'Spawn Beacon'] call BIS_fnc_addRespawnPosition;
						(_this select 0 select 0) setVariable ['WMS_Loc_canSpawnBeacon',false,true];
						(_this select 0 select 0) setVariable ['WMS_Loc_SpawnBeacon',_myRespawn,true];
						hint (_this select 0 select 2);
					}, 
					{hint 'aborted'},
					[_target,_caller,_theHint]
				] call CBA_fnc_progressBar;

			} else {
				hint 'Bro! your respect is too low';
				execVM 'Custom\Intro\levels.sqf';
			};
		", 
		['SpawnBeacon',2500,6000,'SpawnBeacon','Spawn Beacon Activated'],
		1,
		true,
		true,
		"",
		"	
			(getPlayerUID _this == '76561197965501020') &&
			{_target getVariable ['WMS_Loc_canSpawnBeacon',true]} &&
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
*/
////////////////////////////////////////
//JOIN THE PROGRAM //KEEP AT THE BOTTOM
	_IDnumber = _IPcomputer addAction
	[
		"<t size='0.9' color='#d60000'>Join the Program</t>",
		"
			WMS_IP_Active_list pushBack (getplayerUID player);
			publicVariable 'WMS_IP_Active_list'; 
			systemchat 'Welcome Back Soldier, remember to not get in vehicles'
		", //client modifying server variable, thats a weird solution
		[_IPantenna],
		1,
		true,
		true,
		"",
		"
			(alive _target) &&
			{stance player == 'CROUCH'} &&
			{('rhs_radio_R187P1' in (assigneditems _this))} && 
			{((_this getVariable ['playerInRestrictionZone',-1]) == 0)} &&
			{!((getplayerUID player) in WMS_IP_Active_list)} &&
			{((getPlayerUID _this) in WMS_InfantryProgram_list)} &&
			{(vehicle _this == _this)};
		",
		5
	];
	_allActionsID pushBack _IDnumber;
	_IPcomputer setVariable ['IPcomputerAllActionsID',_allActionsID]; //after the last "AddAction"
};
				//_myRespawn = [_caller,(position _caller),'Spawn Beacon'] remoteExec ['BIS_fnc_addRespawnPosition'];
				//_myRespawn = [_caller,(position _caller),'Spawn Beacon'] call BIS_fnc_addRespawnPosition; //work on local mission test not dedicated
				//_myRespawn = [_target,_caller,'add'] remoteExec ['WMS_fnc_setSpawnBeacon']; //works, no marker
				//[_target,_caller,'remove'] remoteExec ['WMS_fnc_setSpawnBeacon']; //doesnt remove the spawn