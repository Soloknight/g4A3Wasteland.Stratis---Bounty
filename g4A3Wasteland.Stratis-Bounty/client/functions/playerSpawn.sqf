// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: playerSpawn.sqf
//	@file Author: [404] Deadbeat, AgentRev
//	@file Created: 20/11/2012 05:19
//	@file Args:
private ["_tkAutoSwitchEnabled","_teamKiller","_teamKillerSwitch"];

_tkAutoSwitchEnabled = ["A3W_tkAutoSwitchEnabled"] call isConfigOn;
_teamKiller = player getVariable ["TeamKiller", 0];

playerSpawning = true;
_donatorEnabled = ["A3W_donatorEnabled"] call isConfigOn;
_donatorLevel = player getVariable ["supporter", 0];
_teamKillerSwitch = false;

switch (true) do
{
	case (!isNil "pvar_teamKillList" && {playerSide in [BLUFOR,OPFOR]} && {[pvar_teamKillList, getPlayerUID player, 0] call fn_getFromPairs >= 2}): { _teamKillerSwitch = true; };
	case (_tkAutoSwitchEnabled && _teamKiller > 0 && {playerSide in [BLUFOR,OPFOR]}): { _teamKillerSwitch = true; };
};

if (_teamKillerSwitch) exitWith
{
	player allowDamage false;
	[player, "AinjPpneMstpSnonWrflDnon"] call switchMoveGlobal;
	9999 cutText ["", "BLACK", 0.01];
	0 fadeSound 0;

	uiNamespace setVariable ["BIS_fnc_guiMessage_status", false];
	_msgBox = [localize "STR_WL_Loading_Teamkiller"] spawn BIS_fnc_guiMessage;
	_time = diag_tickTime;

	waitUntil {scriptDone _msgBox || diag_tickTime - _time >= 20};
	endMission "LOSER";
	waitUntil {uiNamespace setVariable ["BIS_fnc_guiMessage_status", false]; closeDialog 0; false};
};

//Teamswitcher Kick
if (!isNil "pvar_teamSwitchList" && playerSide in [BLUFOR,OPFOR]) then
{
	_prevSide = [pvar_teamSwitchList, getPlayerUID player, playerSide] call fn_getFromPairs;

	if (_prevSide != playerSide) exitWith
	{
		player allowDamage false;
		[player, "AinjPpneMstpSnonWrflDnon"] call switchMoveGlobal;
		9999 cutText ["", "BLACK", 0.01];
		0 fadeSound 0;

		uiNamespace setVariable ["BIS_fnc_guiMessage_status", false];

		_sideName = switch (_prevSide) do
		{
			case BLUFOR: { "BLUFOR" };
			case OPFOR:  { "OPFOR" };
		};

		_msgBox = [format [localize "STR_WL_Loading_Teamswitched", _sideName]] spawn BIS_fnc_guiMessage;
		_time = diag_tickTime;

		waitUntil {scriptDone _msgBox || diag_tickTime - _time >= 20};
		endMission "LOSER";
		waitUntil {uiNamespace setVariable ["BIS_fnc_guiMessage_status", false]; closeDialog 0; false};
	};
};

// Only go through respawn dialog if no data from the player save system
if (isNil "playerData_alive" || !isNil "playerData_resetPos") then
{
	[player, "AmovPknlMstpSnonWnonDnon"] call switchMoveGlobal;

	9999 cutText ["Loading...", "BLACK", 0.01];

// supporters load here

	true spawn client_respawnDialog;

	waitUntil {respawnDialogActive};
	9999 cutText ["", "BLACK", 0.01];
	waitUntil {player setOxygenRemaining 1; !respawnDialogActive};

	if (["A3W_playerSaving"] call isConfigOn) then
	{
		[] spawn fn_savePlayerData;
	};
};

playerData_alive = nil;
playerData_resetPos = nil;

player enableSimulation true;

if (!isNil "playerData_spawnPos") then
{
	player setPosATL playerData_spawnPos;
	playerData_spawnPos = nil;
};

if (!isNil "playerData_spawnDir") then
{
	player setDir playerData_spawnDir;
	playerData_spawnDir = nil;
};

player setVelocity [0,0,0];
[player, false] call fn_hideObjectGlobal;
player allowDamage true;

9999 cutText ["", "BLACK IN"];

playerSpawning = false;
player setVariable ["playerSpawning", false, true];
