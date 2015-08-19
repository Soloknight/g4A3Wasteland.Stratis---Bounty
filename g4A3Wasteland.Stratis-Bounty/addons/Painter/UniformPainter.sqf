// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: UniformPainter.sqf
//	@file Author: LouD
//	@file Created: 14-02-2015

_texDir = "client\images\vehicleTextures\";
_paint = _this select 0;

_price = 500;
_playerMoney = player getVariable "cmoney";

if (_price > _playerMoney) exitWith
	{
		_text = format ["Not enough money! You need $%1 to paint your clothes.",_price];
		[_text, 10] call mf_notify_client;
		playSound "FD_CP_Not_Clear_F";
	};

if (_price < _playerMoney) then	
	{
		player setVariable["cmoney",(player getVariable "cmoney")-_price,true];
		_text = format ["You paid $%1 to paint your clothes.",_price];
		[_text, 10] call mf_notify_client;		
		player spawn fn_savePlayerData;
	};

if (_paint == 0) then {
player setObjectTextureGlobal  [0, _texDir+"17_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"17_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"17_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"17_P.paa"];
};

if (_paint == 1) then {
player setObjectTextureGlobal  [0, _texDir+"18_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"18_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"18_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"18_P.paa"];
};

if (_paint == 2) then {
player setObjectTextureGlobal  [0, _texDir+"33_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"33_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"33_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"33_P.paa"];
};

if (_paint == 3) then {
player setObjectTextureGlobal  [0, _texDir+"34_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"34_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"34_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"34_P.paa"];
};

if (_paint == 4) then {
player setObjectTextureGlobal  [0, _texDir+"22_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"22_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"22_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"22_P.paa"];
};

if (_paint == 5) then {
player setObjectTextureGlobal  [0, _texDir+"23_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"23_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"23_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"23_P.paa"];
};

if (_paint == 6) then {
player setObjectTextureGlobal  [0, _texDir+"24_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"24_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"24_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"24_P.paa"];
};

if (_paint == 7) then {
player setObjectTextureGlobal  [0, _texDir+"25_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"25_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"25_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"25_P.paa"];
};

if (_paint == 8) then {
player setObjectTextureGlobal  [0, _texDir+"27_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"27_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"27_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"27_P.paa"];
};

if (_paint == 9) then {
player setObjectTextureGlobal  [0, _texDir+"29_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"29_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"29_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"29_P.paa"];
};

if (_paint == 10) then {
player setObjectTextureGlobal  [0, _texDir+"38_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"38_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"38_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"38_P.paa"];
};

if (_paint == 11) then {
player setObjectTextureGlobal  [0, _texDir+"43_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"43_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"43_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"43_P.paa"];
};

if (_paint == 12) then {
player setObjectTextureGlobal  [0, _texDir+"47_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"47_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"47_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"47_P.paa"];
};

if (_paint == 13) then {
player setObjectTextureGlobal  [0, _texDir+"49_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"49_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"49_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"49_P.paa"];
};

if (_paint == 14) then {
player setObjectTextureGlobal  [0, _texDir+"50_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"50_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"50_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"50_P.paa"];
};

if (_paint == 15) then {
player setObjectTextureGlobal  [0, _texDir+"51_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"51_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"51_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"51_P.paa"];
};

if (_paint == 16) then {
player setObjectTextureGlobal  [0, _texDir+"28_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"28_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"28_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"28_P.paa"];
};

if (_paint == 17) then {
player setObjectTextureGlobal  [0, _texDir+"32_P.paa"];
player setObjectTextureGlobal  [1, _texDir+"32_P.paa"];
player setObjectTextureGlobal  [2, _texDir+"32_P.paa"];
backpackContainer player setObjectTextureGlobal  [0, _texDir+"32_P.paa"];
};