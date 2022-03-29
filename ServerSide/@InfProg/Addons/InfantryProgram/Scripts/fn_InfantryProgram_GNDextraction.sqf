/**
* InfantryProgram
*
* TNA-Community
* https://discord.gg/Zs23URtjwF
* © 2021 {|||TNA|||}WAKeupneo
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
* Do Not Re-Upload
*/


// action = "openMap true; onMapSingleClick { onMapSingleClick {}; [player,_pos,'sab_C130_J',1] remoteExec ['TNA_fnc_ParadropMissionRequest']; openMap false; true };";
// [player,_pos,"UK3CB_BAF_Merlin_HC4_CSAR",0,_vehicVarName] remoteExec ["TNA_fnc_ParadropMissionRequest"];
// _pos is generated by onMapSingleClick
//[player,_pos,"",_vehicVarName] remoteExec ["WMS_fnc_infantryProgram_GNDextraction"];

diag_log format ["[EXTRACTION GND]|TNA|TNA|TNA|TNA|TNA| VEHICLE Transport _this check, _this = %1 ", _this];
private ["_taxi","_backupPos","_RandomPosSpawn","_footPath"];
params [
  "_target",
  "_pos"
];
/*
private _target = (_this select 0);
private _pos = (_this select 1);*/
if !(typeName _pos == "ARRAY") exitWith {
  diag_log format ["[EXTRACTION GND]|TNA|TNA|TNA|TNA|TNA| Transport _pos fuckedup %1", _pos];
};
_taxi = selectRandom WMS_ExtractionVehicle_Type;
_backupPos = [864.194,4699.85,0]; //flug airport //WTF ?????
_RandomPosSpawn = [_target, 700, 1200] call BIS_fnc_findSafePos;
_footPath = []; 	 
if (worldName == "Tanoa") then {
  _RandomPosSpawn = [_target, 300, 800] call BIS_fnc_findSafePos;
	{
    if (!isOnRoad getPos _x) then { 
      _nul = _footPath pushBack _x; 
    }; 
  }forEach (_RandomPosSpawn nearRoads 500);
};
private _nearestRoad = [_RandomPosSpawn, 500,_footPath] call BIS_fnc_nearestRoad;
private _nearestRoadPos = position _nearestRoad;
if (isnull _nearestRoad) then {_nearestRoadPos = _RandomPosSpawn};
_roadConnectedTo = roadsConnectedTo _nearestRoad; 
_connectedRoad = _roadConnectedTo select 0; 
_directionRoad = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
private _nearestRoad2 = [_pos, 500] call BIS_fnc_nearestRoad;
private _nearestRoadPos2 = position _nearestRoad2;
if (isnull _nearestRoad2) then {_nearestRoadPos2 = _pos};
//private _randomPosDest = selectrandom [[],[],[]];
private _randomPosDest = _nearestRoadPos2;
private _drvGrp = creategroup [west, true];
private _vehic = _taxi createvehicle _nearestRoadPos;
_vehic setdir _directionRoad;
_drvGrp addVehicle _vehic;
_vehic allowCrewInImmobile true;
private _drvUnit = _drvGrp createUnit ["B_crew_F", position _vehic, [], 0, "NONE"];
_drvUnit setSkill 1;
_drvUnit allowFleeing 0;
_drvUnit assignAsDriver _vehic;
_drvUnit moveinDriver _vehic;
_drvUnit disableAI "AUTOTARGET";
_drvUnit disableAI "TARGET";
_drvUnit disableAI "AUTOCOMBAT";
private _gunUnit = _drvGrp createUnit ["B_crew_F", position _vehic, [], 0, "NONE"];
_gunUnit setSkill 0.5;
_gunUnit allowFleeing 0;
_gunUnit moveInGunner _vehic;
{
  removeAllItems _x;
  removeAllWeapons _x;
  removeBackpackGlobal _x;
  _x additem "FirstAidKit";
  //_x forceAddUniform "AOR2_Camo_Cyre"; //NEED A VANILLA SHIT HERE
  //_x addVest "AOR2_Vest_1"; //NEED A VANILLA SHIT HERE
  _x addGoggles "G_Balaclava_oli";
  _x allowfleeing 0;
} forEach units _drvGrp ;

clearMagazineCargoGlobal _vehic;
clearWeaponCargoGlobal _vehic;
clearItemCargoGlobal _vehic;
clearBackpackCargoGlobal _vehic;

_vehic lockDriver true; 
_vehic lockTurret [[-1], true]; 
_vehic lockTurret [[0], true]; 
_vehic lockTurret [[1], true];
_vehic limitspeed 50;

WMS_Extraction_GND_LastTime = time;
publicVariable "WMS_Extraction_GND_LastTime";

private _markerPos = position _vehic;    
private _markerName = "GNDex" + (str _markerPos);    
private _CASMarker1 = createMarker [_markerName, _markerPos];      
_CASMarker1 setMarkerShape "ICON";     
_CASMarker1 setMarkerType "n_support";      
_CASMarker1 setMarkercolor "ColorBlack";
_CASMarker1 setMarkerText "Extraction";

if (WMS_exileToastMsg) then {["toastRequest", ["InfoTitleAndText", [format ["%1 Extraction vehicle ready",(typeof _vehic)]]]] call ExileServer_system_network_send_broadcast};
waitUntil {!(vehicle _target == _target) || !(alive _target)};
uisleep 5;
deleteMarker _markerName;

private _WPT_1 = _drvGrp addWaypoint [_RandomPosDest, 10];
_WPT_1 setWaypointType "TR UNLOAD";
_WPT_1 setWaypointCombatMode "BLUE";
_WPT_1 setWaypointbehaviour  "SAFE";

uisleep 8;
if (((position _vehic) distance2D _nearestRoadPos) < 5 ) then {
	private _vhlPos = getpos _vehic;
	_vehic setpos [(_vhlPos select 0),(_vhlPos select 1),((_vhlPos select 2)+1)];
	leader _drvGrp domove _RandomPosDest;
};

private _WPT_2 = _drvGrp addWaypoint [_nearestRoadPos, 150];
_WPT_2 setWaypointType "MOVE";
_WPT_2 setWaypointCombatMode "RED";
_WPT_2 setWaypointbehaviour  "AWARE";

0 = [_vehic, _pos, _drvGrp] spawn {
uisleep (round(1200+(random 300)));
if (alive (_this select 0)) then {
(_this select 0) setfuel 0;
(_this select 0) setdamage 0.9;
{deletevehicle _x} foreach units(_this select 2);
uisleep 15;
(_this select 0) setdamage 1;
};};

1 = [_vehic, _pos, _drvGrp, _RandomPosDest, _target] spawn {
 waituntil  {(_this select 0) distance2d (_this select 3) <= 50};
 uisleep 5;
 playSound3D ["a3\dubbing_f\modules\supports\transport_accomplished.ogg", (_this select 4), false, getPosATL (_this select 4), 1,1,0];
if (WMS_exileToastMsg) then {["toastRequest", ["InfoTitleAndText", [format ["%1 Extraction Done",(typeof (_this select 0))]]]] call ExileServer_system_network_send_broadcast};
 uisleep (60+random 60);
 (_this select 0) setfuel 0;
 (_this select 0) setdamage 0.9;
 {deletevehicle _x} foreach units(_this select 2);
 uisleep 10;
 (_this select 0) setdamage 1;
};

2 = [_vehic, _drvGrp, _WPT_1, _WPT_2] spawn {
 waituntil  {!(alive (_this select 0))};
 [(_this select 1),[],[],[(_this select 2),(_this select 3)]] call WMS_fnc_lvl2_cleanup;
};