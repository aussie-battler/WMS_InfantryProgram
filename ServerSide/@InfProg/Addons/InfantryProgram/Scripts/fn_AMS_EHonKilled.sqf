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

//[_killed,_killer,_unitFunction,_info] call WMS_fnc_DynAI_RwdMsgOnKill
if (WMS_IP_LOGs) then {diag_log format ["[AMS REWARDS]|WAK|TNA|WMS| _this = %1", _this]};
private ["_unit","_msgx","_sessionID","_unitName","_payload","_bonus","_distanceKill","_playerRep","_bonusDist","_malusDist","_diffCoeff","_adjustedSkills"];
params[
	"_killed",
	"_killer",
	["_unitFunction","Assault"], //not used yet
	["_difficulty", "Hardcore"]
];
WMS_AllDeadsMgr pushBack [_killed,(serverTime+WMS_AMS_AllDeads)];
_distanceKill = (round(_killer distance _killed));
_bonus = WMS_DynAI_respectBonus;
_difficulty = _killed getVariable "WMS_Difficulty";
//_adjustedSkills = _killed getVariable "AMS_AdjustedSkills"; //Not Used Yet, includ VCOM functions
if (_distanceKill > WMS_AMS_distBonusMax) then {_bonus = 0};
_bonusDist = round (_distanceKill * WMS_AMS_distBonusCoef);
_malusDist = 0;
_payload = [[format ["KILLED %1",toUpper(name _killed)],_bonus]];//[_scoreName, _scoreString]
_diffCoeff = 1;
switch (toLower _difficulty) do {
	case  "easy" 		: {_diffCoeff = 0.5};
	case  "moderate" 	: {_diffCoeff = 0.67};
	case  "difficult" 	: {_diffCoeff = 0.83};
	case  "hardcore" 	: {_diffCoeff = 1};
	case  "static" 		: {_diffCoeff = 1};
};
if (isplayer _killer) then {
	//if (WMS_AI_forceInfKillCount) then {_killer addPlayerScores [1,0,0,0,0]}; //not used anymore
	_killerName = name _killer;
	_killerUID = getPlayerUID _killer;
	_playerRepUpdated = 0;
	_playerUID_ExileKills = "ExileKills_"+_killerUID;
	_playerUID_ExileScore = "ExileScore_"+_killerUID;
  	_playerRep = profileNamespace getVariable [_playerUID_ExileScore,0];
  	_playerKills = profileNamespace getVariable [_playerUID_ExileKills,0];
	_playerKills = _playerKills + 1;
	_killer setVariable ["ExileKills", _playerKills, true];

	if (WMS_exileFireAndForget) then { //FireAndForget is ONLY for Exile DB means Exile mod is running
		format["addAccountKill:%1", getPlayerUID _killer] call ExileServer_system_database_query_fireAndForget;
		ExileClientPlayerKills = _playerKills;
		(owner _killer) publicVariableClient "ExileClientPlayerKills";
		ExileClientPlayerKills = nil;
	} else {
  		profileNamespace setVariable [_playerUID_ExileKills,_playerKills];
	};

	//if (WMS_AMS_DestroyStatics && {(vehicle _killed) isKindOf "StaticWeapon"}) then {vehicle _killed setDamage 1}; //works but not 100% with ACE
	//_unit setVariable ["WMS_Static", true, false];
	//_unit setVariable ["WMS_StaticObj", _vehicle, false];
	if (WMS_AMS_DestroyStatics && {
		_killed getVariable ["WMS_Static", false];
		}) then {
			_static = _killed getVariable "WMS_StaticObj";
			if !(isNil "_static") then {_static setDamage 1};
		};
	if (_killed == leader _killed) then {
		if ((random 100) < WMS_AMS_DestroyVHL) then {vehicle _killed setDamage 1};
		if (WMS_AMS_Reinforce && {time > (WMS_AMS_LastReinforce+WMS_AMS_ReinforceCoolD)}) then {
			if (vehicle _killer isKindOf "tank"||vehicle _killer isKindOf "APC"||vehicle _killer isKindOf "Heli_Attack_01_base_F"||vehicle _killer isKindOf "Heli_Attack_02_base_F") then {
				[_killed,_killer,_playerRep,_distanceKill,_difficulty]call WMS_fnc_AMS_Reinforce;
			}  else {	
				if (_distanceKill>(WMS_AMS_RangeList select 0) && {(OPFOR countSide allUnits) < WMS_AI_MaxUnits_B}) then {
				[_killed,_killer,_playerRep,_distanceKill,_difficulty]call WMS_fnc_AMS_Reinforce;
			};
		};
	};
		
		
	};
	//if (WMS_AMS_remRPG) then {_killed removeWeapon (secondaryWeapon _killed)};
	if ((random 100) < WMS_AMS_remRPG) then {_killed removeWeapon (secondaryWeapon _killed)};

	if (WMS_AMS_RespectRwdOnKill && {(typeOf vehicle _killer) == WMS_PlayerEntity}) then {
		if (_distanceKill < WMS_AMS_distBonusMax) then {
			_malusDist = _bonusDist -(_bonusDist*2);
			_payload pushBack [format ["%1m RANGE MALUS",_distanceKill], _malusDist];//[_scoreName, _scoreString]
			_bonus = floor ((WMS_AMS_respectBonus + _malusDist)*_diffCoeff);
			_payload pushBack [format ["Coeff %1",_difficulty], (_bonus-(WMS_AMS_respectBonus + _malusDist))];//[_scoreName, _scoreString]
		};
		_killer setVariable ["ExileScore",(_playerRep+_bonus), true];
		_playerRepUpdated = _killer getVariable ["ExileScore", 0];
		if (WMS_exileFireAndForget) then {
			format["setAccountScore:%1:%2", _playerRepUpdated, _killerUID] call ExileServer_system_database_query_fireAndForget;
			ExileClientPlayerScore = _playerRepUpdated;
			(owner _killer) publicVariableClient "ExileClientPlayerScore";
			ExileClientPlayerScore = nil;
		} else {
  			_serverSide_ExileScore = profileNamespace setVariable [_playerUID_ExileScore,_playerRepUpdated];
		};
	} else {
		_bonus = 0;
		_payload = [[format ["KILLED %1",toUpper(name _killed)],_bonus]];//[_scoreName, _scoreString]
	};
	if (WMS_AMS_sysChatMsg == 1) then { // general
		_msgx = format ['%2 killed %1, %3m away and received %4 respect.', (name _killed), _killerName,_distanceKill,_bonus];
		[_msgx] remoteexec ['SystemChat',0];
	} else {
		if (WMS_AMS_sysChatMsg == 2) then { // group
			_msgx = format["%1 killed %2 from %3 meters away and received %4 respect.",_killerName,(name _killed),_distanceKill,_bonus];
			{_msgx remoteExecCall ["systemChat", _x]} forEach units (group _killer);
		} else {
			if (WMS_AMS_sysChatMsg == 3) then { // player
				_msgx = format ['%2 killed %1, %3m away and received %4 respect.', (name _killed), _killerName,_distanceKill,_bonus];
				[_msgx] remoteExecCall ['SystemChat',_killer];
			};
		};
	};

	if (WMS_exileToastMsg) then {
		_sessionID = _killer getVariable ['ExileSessionID',''];
		[_sessionID, 'toastRequest', ['SuccessTitleAndText', ['Mission AI', 'Target down']]] call ExileServer_system_network_send_to;
	};
	if (WMS_AMS_ShowFragMsg) then {
		if (WMS_exileFireAndForget) then {
			[_killer, "showFragRequest", [_payload]] call ExileServer_system_network_send_to;
		} else {
			if (WMS_IP_LOGs) then {diag_log format ["[AMS_AI_KILLED_MESSAGE]|WAK|TNA|WMS|Killer:%1, Payload: %2",_killer, _payload]};
			//_payload remoteExecCall ['WMS_fnc_gui_hud_showKillDetails',(owner _killer)];
			[_payload,"AMS"] remoteExec ['WMS_fnc_displayKillStats',(owner _killer)];
		};
	};
	if (WMS_AMS_ejectDeads) then {moveout _killed};
	if !((vehicle _killer) isKindOf "man")then{
		if (WMS_IP_LOGs) then {diag_log format ["[AMS KILLER IN VEHICLE]|WAK|TNA|WMS| Killer: %1 is in a Vehicle!",(name _killer), (typeOf (vehicle _killer))]};
		if (vehicle _killer isKindOf "tank" || vehicle _killer isKindOf "Wheeled_Apc_F" || (typeOf (vehicle _killer)) in WMS_RCWS_Vhls) then {
			if (WMS_IP_LOGs) then {diag_log format ["[AMS KILLER IN VEHICLE]|WAK|TNA|WMS| Killer: %1, vehicle is a tank/APC",(name _killer)]};
			if (WMS_AMS_StripOnArmoredK)then {
				if (WMS_IP_LOGs) then {diag_log format ["[AMS KILLER IN VEHICLE]|WAK|TNA|WMS| Victime %1 is losing all is stuff",(name _killed)]};
				_killed removeWeapon (primaryWeapon _killed);
				_killed removeWeapon (secondaryWeapon _killed);
				removeAllItems _killed;
				removeAllWeapons _killed;
				removeBackpackGlobal _killed;
				removeVest _killed;
			};
			if (WMS_AMS_TrappOnArmoredK)then {
				_mineType = selectRandom [WMS_ATMines,"APERSBoundingMine"];
				_mine = createMine [_mineType, [((position _killed) select 0),((position _killed) select 1),0], [], 1 ];
				_mine allowDamage false;
				EAST revealMine _mine;
				if (WMS_IP_LOGs) then {diag_log format ["[AMS KILLER IN VEHICLE]|WAK|TNA|WMS| Victime %1 is Boobytrapped, %2",(name _killed),_mineType]};
			};
		}else {
			if (vehicle _killer isKindOf "Heli_Attack_01_base_F"||vehicle _killer isKindOf "Heli_Attack_02_base_F"||vehicle _killer isKindOf "Heli_Light_01_armed_base_F") then {
				if (WMS_IP_LOGs) then {diag_log format ["[AMS KILLER IN VEHICLE]|WAK|TNA|WMS| Killer: %1, vehicle is an Attack Helicopter",(name _killer)]};
				if (WMS_AMS_StripOnArmoredK)then {
					if (WMS_IP_LOGs) then {diag_log format ["[AMS KILLER IN VEHICLE]|WAK|TNA|WMS| Victime %1 is losing all is stuff",(name _killed)]};
					_killed removeWeapon (primaryWeapon _killed);
					_killed removeWeapon (secondaryWeapon _killed);
					removeAllItems _killed;
					removeAllWeapons _killed;
					removeBackpackGlobal _killed;
					removeVest _killed;
				};
			};
		};
	}else {
		if (WMS_IP_LOGs) then {diag_log format ["[AMS KILLER IN VEHICLE]|WAK|TNA|WMS| Killer: %1 seems to not be in a vehicle",(name _killer), (typeOf (vehicle _killer))]};
	};
	//saveProfileNamespace;
	if (WMS_IP_LOGs) then {diag_log format ["[AMS PROFILENAMESPACE]|WAK|TNA|WMS| _killer VARs: %1 | %2 %3 | %4 %5", _killer, ("ExileKills_"+_killerUID), _playerKills, ("ExileScore_"+_killerUID), _playerRepUpdated]};
	//Add hideBody addaction here
	[_killed,
		[
			"Hide Body",	// title
			{
				params ["_target", "_caller", "_actionId", "_arguments"]; // script
				hideBody _target;
				_caller removeAction _actionId;
				[_target]spawn{uisleep 5; deleteVehicle (_this select 0)};
			},
			nil,		// arguments
			1.5,		// priority
			true,		// showWindow
			true,		// hideOnUse
			"",			// shortcut
			"!(alive _target)", 	// condition
			1.5			// radius
		]
	] remoteExec [
		"addAction",
		0, //0 for all players
		false //JIP
	];
} else {
	if ((_killed == leader _killed) && {(random 100) < WMS_AMS_DestroyVHL}) then {vehicle _killed setDamage 1};
	_killed removeWeapon (secondaryWeapon _killed);
};