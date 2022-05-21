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

private _servFPS = round diag_fps;
//private _servUnits = (count allUnits - count allPlayers);
private _servUnits = (EAST countside allUnits);
private _servDeads = count allDeadMen;
if (WMS_IP_LOGs) then {diag_log format ["[SERVER MARKERS Update]|WAK|TNA|WMS| Server fps: %1, OPFOR Units: %2, %3 Deads", _servFPS,_servUnits,_servDeads]};

WMS_markerFPS setMarkerText (format ["%1 fps", _servFPS]);
WMS_markerUnits setMarkerText (format ["%1 NPC", _servUnits]);
WMS_markerDeads setMarkerText (format ["%1 Deads", _servDeads]);

if (_servFPS > 35) then {
	WMS_markerFPS setMarkerColor "ColorGreen";
} else {
	if (_servFPS <= 35 && _servFPS >= 15) then {
		WMS_markerFPS setMarkerColor "ColorYellow";
	} else {
		WMS_markerFPS setMarkerColor "ColorRed"; //_servFPS < 15
	};
};
if (_servUnits < WMS_AI_MaxUnits_A) then {
	WMS_markerUnits setMarkerColor "ColorGreen";
} else {
	if (_servUnits >= WMS_AI_MaxUnits_A && _servUnits <= WMS_AI_MaxUnits_C) then {
		WMS_markerUnits setMarkerColor "ColorYellow";
	} else {
		WMS_markerUnits setMarkerColor "ColorRed"; //_servUnits > WMS_AI_MaxUnits_C;
	};
};
if (_servDeads < 30) then {
	WMS_markerDeads setMarkerColor "ColorGreen";
} else {
	if (_servDeads >= 30 && _servDeads <= 50) then {
		WMS_markerDeads setMarkerColor "ColorYellow";
	} else {
		WMS_markerDeads setMarkerColor "ColorRed"; //_servDeads > 40;
		{ deleteVehicle _x } forEach allDeadMen;
	};
};