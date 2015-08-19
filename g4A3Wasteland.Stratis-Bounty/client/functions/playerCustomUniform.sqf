// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2015 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: playerCustomUniform.sqf
//	@file Author: Lodac
//	@file Created: 2/23/2015


if (isDedicated) exitWith {};

private ["_player", "_side", "_customUniformEnabled", "_uniformNumber"];

_player = getPlayerUID player;
_side = playerSide;
_uniformNumber = 0;
_customUniformEnabled = ["A3W_customUniformEnabled"] call isConfigOn;
_uniformNumber = player getVariable ["uniform", 0];

if (!(_customUniformEnabled) || _uniformNumber < 1) exitWith {};


switch (_side) do
{

	case BLUFOR:
	{
		[] spawn
		{
			while {true} do
			{
					_uniformNumber = player getVariable ["uniform", 0];
					waitUntil {uniform player == "U_B_CombatUniform_mcam", "U_B_Protagonist_VR"};
					if (_uniformNumber < 11) then 
					{
						player setObjectTextureGlobal [0, format["client\images\uniformTextures\%1_I.jpg", _uniformNumber]];
						if (_uniformNumber == 9) then
						{
							player setObjectTextureGlobal [1,"client\images\uniformTextures\pinkgut1.jpg"];
							sleep 1;
							waitUntil {uniform player != "U_B_CombatUniform_mcam", "U_B_Protagonist_VR"};
						} 
						else 
						{
						sleep 1;
						waitUntil {uniform player != "U_B_CombatUniform_mcam", "U_B_Protagonist_VR"};
						};
					};
					if (_uniformNumber > 10) then
					{
						player setObjectTextureGlobal [0, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						player setObjectTextureGlobal [1, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						player setObjectTextureGlobal [2, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						backpackContainer player setObjectTextureGlobal [0, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						sleep 1;
						waitUntil {uniform player != "U_B_CombatUniform_mcam", "U_B_Protagonist_VR"};
					};  
			};
		};
	};
	
	case OPFOR:
	{
		[] spawn
		{	
			while {true} do
			{
					_uniformNumber = player getVariable ["uniform", 0];
					waitUntil {uniform player == "U_O_CombatUniform_ocamo", "U_B_Protagonist_VR"};
					if (_uniformNumber < 11) then 
					{
						player setObjectTextureGlobal [0, format["client\images\uniformTextures\%1_I.jpg", _uniformNumber]];
						if (_uniformNumber == 9) then
						{
							player setObjectTextureGlobal [1,"client\images\uniformTextures\pinkgut1.jpg"];
							sleep 1;
							waitUntil {uniform player != "U_O_CombatUniform_ocamo", "U_B_Protagonist_VR"};
						} 
						else 
						{
						sleep 1;
						waitUntil {uniform player != "U_O_CombatUniform_ocamo", "U_B_Protagonist_VR"};
						};
					};
					if (_uniformNumber > 10) then
					{
						player setObjectTextureGlobal [0, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						player setObjectTextureGlobal [1, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						player setObjectTextureGlobal [2, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						backpackContainer player setObjectTextureGlobal [0, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
						sleep 1;
						waitUntil {uniform player != "U_O_CombatUniform_ocamo", "U_B_Protagonist_VR"};
					};  
			};
			
			
		};	
	};

	case INDEPENDENT:
	{
		[] spawn
		{
			while {true} do
            {
                _uniformNumber = player getVariable ["uniform", 0];
                waitUntil {uniform player == "U_I_CombatUniform", "U_B_Protagonist_VR"};
				if (_uniformNumber < 11) then 
				{
					player setObjectTextureGlobal [0, format["client\images\uniformTextures\%1_I.jpg", _uniformNumber]];
					if (_uniformNumber == 9) then
					{
						player setObjectTextureGlobal [1,"client\images\uniformTextures\pinkgut1.jpg"];
						sleep 1;
						waitUntil {uniform player != "U_I_CombatUniform", "U_B_Protagonist_VR"};
					} 
					else 
					{
					sleep 1;
                    waitUntil {uniform player != "U_I_CombatUniform", "U_B_Protagonist_VR"};
					};
				};
				if (_uniformNumber > 10) then
				{
					player setObjectTextureGlobal [0, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
					player setObjectTextureGlobal [1, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
					player setObjectTextureGlobal [2, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
					backpackContainer player setObjectTextureGlobal [0, format["client\images\vehicleTextures\%1_P.paa", _uniformNumber]];
					sleep 1;
                    waitUntil {uniform player != "U_I_CombatUniform", "U_B_Protagonist_VR"};
				};    
            };
		};

	};
};