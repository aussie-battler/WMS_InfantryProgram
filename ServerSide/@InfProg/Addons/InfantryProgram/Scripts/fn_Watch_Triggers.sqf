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

//Triggers campers activity check
private ["_trigTime","_targetList","_target","_triggCheck","_triggCheckChance","_triggCheckDist"];
{
	if (WMS_Watch_Triggers_Logs) then {diag_log format ["[TRIGGERS WATCH]|WAK|TNA|WMS| %1 trigger(s) activated", (count WMS_activatedTriggs)]};
	/*_triggCheck = WMS_triggCheck;
	_triggCheckDist = WMS_triggCheckDist;
	_triggCheckChance = WMS_triggCheckChance;
	if (WMS_FastCombat) then {
		_triggCheck = WMS_triggCheckFC;
		_triggCheckChance = WMS_triggCheckChanceFC;
		};*/
	_triggCheck = WMS_triggCheck_T;
	_triggCheckChance = WMS_triggCheck_Ch_T;
	_triggCheckDist = WMS_triggCheckDist;
	if (time > ((_x select 1) + _triggCheck)) then {
		_trigTime = round time;
		_targetList = nearestObjects [_x select 0, [WMS_PlayerEntity], WMS_triggCheckDist]; //doesnt count players in vehicles so players could hide in vehicles, but they do not know that! :D
		if (count _targetList == 0) then {
			if (WMS_Watch_Triggers_Logs) then {diag_log format ["[TRIGGERS WATCH]|WAK|TNA|WMS| no target, reset trigger Time = %1 ", _trigTime]};
			(_x select 0) setVariable ['WMS_triggRef',[(_x select 0), _trigTime],true];
			_x set [1, _trigTime];
		} else {
			_target = selectRandom _targetList;
			if (WMS_Watch_Triggers_Logs) then {diag_log format ["[TRIGGERS WATCH]|WAK|TNA|WMS| %1 spotted", (name _target)]};
			if ((random 100 < _triggCheckChance) && {((OPFOR countSide allUnits) < WMS_AI_MaxUnits_B)} && {((_target distance2D (_target findNearestEnemy _target)) > WMS_triggCheckDist)}) then {
				[_target, position _target, "reinforcement"] call WMS_fnc_DynAI_selScen;
			};
			(_x select 0) setVariable ['WMS_triggRef',[(_x select 0), _trigTime],true];
			_x set [1, _trigTime];
		};
	};
}forEach WMS_activatedTriggs;