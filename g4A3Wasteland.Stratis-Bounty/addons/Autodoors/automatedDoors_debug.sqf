scriptName "automatedDoors_debug";
/*
	File:			automatedDoors_debug.sqf
	Author:			Heeeere's Johnny!	<<< Please do not edit or remove this line. Thanks. >>>
	Version:		2.1
	Description:	For each player, it creates and removes triggers on nearby buildings which open the door if a player is close to it.
					Must be executed server side.
					If locations of type "Name" and with name prefix "doors" exist, door triggers will only be managed in these locations.
					addActions to enable/disable this script's functionality solely for the player executing the action.
	Execution:		Any
	
	Parameters:
		0 ARRAY		objects			(optional, default: ["arma3"]) no use yet, intended to enable ArmA 2 and Tanao object compatibility
		1 BOOLEAN	doorsStayOpen	(optional, default: false)
									if true, doors will never close automatically
									if false, they will close automatically if player doesn't disable it for himself
	
	Return:
		nothing
*/
#define DOOR_RADIUS		3	//meters, radius of the trigger area
#define SCAN_RADIUS		50	//meters, radius of the area around a player to be scanned for buildings on each loop
#define SCAN_SLEEP		10	//seconds, time between each scan
#define DOOR_TRIGGERS	"doorTriggers"	//used to setVariable on buildings, alter if in conflict with other scripts
#define DOOR_SPHERES	"spheres"		//used to setVariable on buildings, alter if in conflict with other scripts
#define USES_AUTO_DOORS	"usesAutomatedDoors"		//used to setVariable on player, alter if in conflict with other scripts
#define DOORS_STAY_OPEN	"doorsStayOpen"				//used to setVariable on player, alter if in conflict with other scripts
#define ID_ACTIONS		"automatedDoors_actions"	//used to setVariable on player, alter if in conflict with other scripts

if(!isServer) exitWith {hintSilent "automatedDoors: This script may only run server side or in Singleplayer!";};
if(!isNil "scriptHandle_automatedDoors" && {!isNull scriptHandle_automatedDoors}) exitWith {
	hintSilent "automatedDoors: Script invoked even though it's already running."
};

params [["_objects", ["arma3"], [[]]], ["_doorsStayOpen", false, [true]]];

_objects = ["arma3"];	//limited to ArmA3 until ArmA2 object positions are available
if(1 isEqualTo ({if !(toLower _x in ["arma3", "tanao", "chernarus", "takistan"]) exitWith {1};} count _objects)) exitWith {
	hintSilent format ["automatedDoors: incorrect value(s) in ""%1""", _objects];
};

//debug
fnc_getModelPos =
{
	_model = nearestObject [player, "House"];
	_modelPosition = _model worldToModel getPosATL player;
	createVehicle ["Sign_Sphere10cm_F", _model modelToWorld _modelPosition, [], 0, "CAN_COLLIDE"];
	copyToClipboard format ["[%1, ""Door_%2_rot""]", _modelPosition, _this];
};

_fnc_addDoorActions =
{
	// _doorsStayOpen = _this select 0;
	_doorsStayOpen = param [0, player getVariable [DOORS_STAY_OPEN, false], [true]];
	
	_actionIds = [];
	_actionIds pushBack (player addAction ["Enable Automated doors", {player setVariable [USES_AUTO_DOORS, true, true];}, [], 0, false, true, "", format ["!(player getVariable ['%1', true])", USES_AUTO_DOORS]]);
	_actionIds pushBack (player addAction ["Disable Automated doors", {player setVariable [USES_AUTO_DOORS, false, true];}, [], 0, false, true, "", format ["player getVariable ['%1', true]", USES_AUTO_DOORS]]);
	
	if(!_doorsStayOpen) then	//only add these actions if doors are not already server side (globally) kept open
	{
		player setVariable [DOORS_STAY_OPEN, false, true];
		_actionIds pushBack (player addAction ["Keep doors open", {player setVariable [DOORS_STAY_OPEN, true, true];}, [], 0, false, true, "", format ["player getVariable ['%1', true] && {!(player getVariable '%2')}", USES_AUTO_DOORS, DOORS_STAY_OPEN]]);
		_actionIds pushBack (player addAction ["Don't keep doors open", {player setVariable [DOORS_STAY_OPEN, false, true];}, [], 0, false, true, "", format ["player getVariable ['%1', true] && {player getVariable '%2'}", USES_AUTO_DOORS, DOORS_STAY_OPEN]]);
	}
	else
	{
		player setVariable [DOORS_STAY_OPEN, true, true];
	};
	
	_fnc_removeAllActions =
	{
		{
			player removeAction _x;
		} forEach (player getVariable [ID_ACTIONS, []]);
	};
	
	_actionIds pushBack (player addAction ["Perm. remove 'Automated Doors' actions", _fnc_removeAllActions, [], 0, false, true]);
	
	player setVariable [ID_ACTIONS, _actionIds];
	
	_fnc_removeAllActions spawn
	{
		while {isNil "scriptHandle_automatedDoors" || {isNull scriptHandle_automatedDoors}} do {sleep 10;};
		while {!isNull scriptHandle_automatedDoors} do {sleep 10;};
		[] call _this;
	};
};

[[[_doorsStayOpen], _fnc_addDoorActions], "BIS_fnc_call", true, true, true] call BIS_fnc_MP;
player addEventHandler ["Respawn", _fnc_addDoorActions];

scriptHandle_automatedDoors = [_objects, _doorsStayOpen] spawn
{
	params [["_objects", ["arma3"], [[]]], ["_doorsStayOpen", false, [true]]];
	
	_fnc_transformArray =	//Source: https://spideroak.com/browse/share/see/sqf/sqf/fn_transformArray/
	{
		params [["_thisArray", [], [[]]], ["_xLength", 0, [0]], ["_defaultValue", false]];
		
		// _thisArray		= _this select 0;
		if(_thisArray isEqualTo []) exitWith {["transformArray", "fnc_transformArray: Passed array has no elements."] call fnc_error;};
		// _xLength		= [_this, 1, 0, [0]] call BIS_fnc_param;
		// _defaultValue	= [_this, 2, false] call BIS_fnc_param;

		_transformedArray	= [];

		if(_xLength isEqualTo 0) then	//get size of largest sub array
		{
			{
				_xLengthNew = count _x;
				if(_xLengthNew > _xLength) then {_xLength = _xLengthNew;};
			} count _thisArray;
		};
		
		if(_xLength isEqualTo 0) exitWith {};	//empty sub array(s), nothing to transform here
		_xLength = _xLength - 1;
		
		for "_i" from 0 to _xLength do
		{
			_transformedArray pushBack [];
		};

		{
			_subArrayCount = 0;
			_subArrayCount =
			{
				(_transformedArray select _subArrayCount) pushBack (if(isNil "_x") then {_defaultValue} else {_x});
				_subArrayCount = _subArrayCount + 1;
				true
			} count _x;	//transform sub array as far as possible
			
			for "_i" from _subArrayCount to _xLength do	//fill up with default values if needed
			{
				0 = (_transformedArray select _i) pushBack _defaultValue;
			};
		} count _thisArray;

		_transformedArray
	};
	
	/*
		One array per class name:
		(e.g. "Land_i_House_Big_01_V1_F" and "Land_i_House_Big_01_V2_F" are two different class names!)
		[
			"object_className",
			[
				[doorPosition, "doorName1"],	//one door
				OR
				[doorPosition, ["doorName1", "doorName2"]],	//multiple doors, e.g. slider doors
				...
			]
		]
	*/
	_allBuildingDoorsArma3 =
	[
		[
			"Land_Offices_01_V1_F",
			[
				[[10.4929,-7.65356,-7.05899], ["Door_1_rot", "Door_2_rot"]],
				[[11.2625,0.230713,-7.05899], "Door_3_rot"],
				[[7.92407,6.08911,-7.05899], "Door_4_rot"],
				[[-14.842,8.42163,-7.05899], "Door_5_rot"],
				[[6.05762,-0.0559082,4.66484], "Door_6_rot"],
				[[7.82715,-5.61768,4.66477], "Door_7_rot"]
			]
		],
		[
			"Land_Hospital_main_F",
			[
				[[12.1914,19.8083,-8.00933], "Door_1_rot"],
				[[2.77881,15.8291,-8.01416], ["Door_2A_move", "Door_2B_move"]],
				[[2.89697,7.51416,-8.01557], ["Door_3A_move", "Door_3B_move"]],
				[[-4.16626,-7.84277,-8.01557], ["Door_4A_move", "Door_4B_move"]],
				[[-11.3657,-18.49,-8.01557], "Door_5_rot"]
			]
		],
		["Land_Hospital_side1_F",	[[[4.08276,3.30518,-7.89348], "Door_1_rot"]]],
		["Land_Hospital_side2_F",	[[[-8.84106,-7.20435,-8.10451], "Door_1_rot"]]],
		["Land_LightHouse_F",		[[[-0.0231934,-0.757324,-11.0989], "Door_1_rot"]]],
		["Land_i_Addon_02_V1_F",	[[[2.5481,-0.521973,0.112265], "Door_1_rot"]]],
		
		#define LAND_I_GARAGE [[[5.37183,1.53638,-0.0974813], "Door_1_rot"]]
		["Land_i_Garage_V1_F",		LAND_I_GARAGE],
		["Land_i_Garage_V1_dam_F",	LAND_I_GARAGE],
		["Land_i_Garage_V2_F",		LAND_I_GARAGE],
		["Land_i_Garage_V2_dam_F",	LAND_I_GARAGE],
		
		#define LAND_I_HOUSE_BIG_01 [ \
			[[-1.90527,-6.00586,-2.54993], "Door_1_rot"], \
			[[4.86328,5.58179,-2.56493], "Door_2_rot"], \
			[[-1.31348,2.95703,0.855067], "Door_3_rot"]]
		["Land_i_House_Big_01_V1_F",		LAND_I_HOUSE_BIG_01],
		["Land_i_House_Big_01_V1_dam_F",	LAND_I_HOUSE_BIG_01],
		["Land_i_House_Big_01_V2_F",		LAND_I_HOUSE_BIG_01],
		["Land_i_House_Big_01_V2_dam_F",	LAND_I_HOUSE_BIG_01],
		["Land_i_House_Big_01_V3_F",		LAND_I_HOUSE_BIG_01],
		["Land_i_House_Big_01_V3_dam_F",	LAND_I_HOUSE_BIG_01],
		
		#define LAND_I_HOUSE_BIG_02 [ \
			[[-2.89819,-4.43188,-2.62094], "Door_1_rot"], \
			[[-1.39063,-0.484131,-2.56094], "Door_2_rot"], \
			[[0.14624,5.36157,-2.51594], "Door_3_rot"], \
			[[-2.92188,-4.29346,0.866564], "Door_4_rot"], \
			[[-1.38965,-0.560303,0.866564], "Door_5_rot"], \
			[[-2.85498,5.31714,0.881564], "Door_6_rot"]]
		["Land_i_House_Big_02_V1_F",		LAND_I_HOUSE_BIG_02],
		["Land_i_House_Big_02_V1_dam_F",	LAND_I_HOUSE_BIG_02],
		["Land_i_House_Big_02_V2_F",		LAND_I_HOUSE_BIG_02],
		["Land_i_House_Big_02_V2_dam_F",	LAND_I_HOUSE_BIG_02],
		["Land_i_House_Big_02_V3_F",		LAND_I_HOUSE_BIG_02],
		["Land_i_House_Big_02_V3_dam_F",	LAND_I_HOUSE_BIG_02],
		
		#define LAND_I_SHOP_01 [ \
			[[1.24316,-2.60669,-2.73571], "Door_1_rot"], \
			[[3.11353,-2.49414,-2.73571], "Door_2_rot"], \
			[[2.31201,7.25073,-2.71734], "Door_3_rot"], \
			[[-0.627441,5.03613,1.10916], "Door_4_rot"], \
			[[-0.587402,-2.53345,1.14653], "Door_5_rot"]]
		["Land_i_Shop_01_V1_F",		LAND_I_SHOP_01],
		["Land_i_Shop_01_V1_dam_F",	LAND_I_SHOP_01],
		["Land_i_Shop_01_V2_F",		LAND_I_SHOP_01],
		["Land_i_Shop_01_V2_dam_F",	LAND_I_SHOP_01],
		["Land_i_Shop_01_V3_F",		LAND_I_SHOP_01],
		["Land_i_Shop_01_V3_dam_F",	LAND_I_SHOP_01],
		
		#define LAND_I_SHOP_02 [ \
			[[-5.83984,-3.22119,-2.7151], "Door_1_rot"], \
			[[-2.44092,1.23584,-2.66855], "Door_2_rot"], \
			[[3.78369,0.0187988,1.27873], "Door_3_rot"], \
			[[-5.87939,-0.00195313,1.27032], "Door_4_rot"]]
		["Land_i_Shop_02_V1_F",		LAND_I_SHOP_02],
		["Land_i_Shop_02_V1_dam_F",	LAND_I_SHOP_02],
		["Land_i_Shop_02_V2_F",		LAND_I_SHOP_02],
		["Land_i_Shop_02_V2_dam_F",	LAND_I_SHOP_02],
		["Land_i_Shop_02_V3_F",		LAND_I_SHOP_02],
		["Land_i_Shop_02_V3_dam_F",	LAND_I_SHOP_02],
		
		#define LAND_I_HOUSE_SMALL_01 [ \
			[[3.07397,-4.56152,-1.03963], "Door_1_rot"], \
			[[1.68066,0.251465,-1.04106], "Door_2_rot"], \
			[[1.68311,3.03198,-1.0419], "Door_3_rot"], \
			[[-3.36792,4.9624,-1.03037], "Door_4_rot"]]
		["Land_i_House_Small_01_V1_F",		LAND_I_HOUSE_SMALL_01],
		["Land_i_House_Small_01_V1_dam_F",	LAND_I_HOUSE_SMALL_01],
		["Land_i_House_Small_01_V2_F",		LAND_I_HOUSE_SMALL_01],
		["Land_i_House_Small_01_V2_dam_F",	LAND_I_HOUSE_SMALL_01],
		["Land_i_House_Small_01_V3_F",		LAND_I_HOUSE_SMALL_01],
		["Land_i_House_Small_01_V3_dam_F",	LAND_I_HOUSE_SMALL_01],
		
		#define LAND_I_HOUSE_SMALL_02 [ \
			[[-3.79077,-2.15088,-0.712922], "Door_1_rot"], \
			[[0.910156,1.71558,-0.702502], "Door_2_rot"]]
		["Land_i_House_Small_02_V1_F",		LAND_I_HOUSE_SMALL_02],
		["Land_i_House_Small_02_V1_dam_F",	LAND_I_HOUSE_SMALL_02],
		["Land_i_House_Small_02_V2_F",		LAND_I_HOUSE_SMALL_02],
		["Land_i_House_Small_02_V2_dam_F",	LAND_I_HOUSE_SMALL_02],
		["Land_i_House_Small_02_V3_F",		LAND_I_HOUSE_SMALL_02],
		["Land_i_House_Small_02_V3_dam_F",	LAND_I_HOUSE_SMALL_02],
		
		#define LAND_I_HOUSE_SMALL_03 [ \
			[[0.439941,-2.56812,-0.338685], "Door_1_rot"], \
			[[3.85205,5.07227,-0.32163], "Door_2_rot"], \
			[[1.97925,-0.444824,-0.371629], "Door_3_rot"], \
			[[-1.06128,2.43042,-0.371629], "Door_4_rot"]]
		["Land_i_House_Small_03_V1_F",		LAND_I_HOUSE_SMALL_03],
		["Land_i_House_Small_03_V1_dam_F",	LAND_I_HOUSE_SMALL_03],
		
		["Land_Slum_House01_F", [[[1.28857,-1.17969,-0.852837], "Door_1_rot"]]],
		[
			"Land_Slum_House02_F",
			[
				[[-0.00439453,-1.68872,-0.798102], "Door_1_rot"],
				[[-0.727051,2.77686,-0.805723], "Door_2_rot"]
			]
		],
		["Land_Slum_House03_F", [[[2.82397,-0.945557,-0.901089], "Door_1_rot"]]],
		
		#define LAND_I_STONE_SHED [[[2.25366,-0.860107,-0.0762148], "Door_1_rot"]]
		["Land_i_Stone_Shed_V1_F",	LAND_I_STONE_SHED],
		["Land_i_Stone_Shed_V2_F",	LAND_I_STONE_SHED],
		["Land_i_Stone_Shed_V3_F",	LAND_I_STONE_SHED],
		
		#define LAND_I_STONE_HOUSESMALL [ \
			[[6.87354,-1.26782,-0.595454], "Door_1_rot"], \
			[[-7.8418,-1.24561,-0.601124], "Door_2_rot"], \
			[[0.891113,1.81787,-0.622117], "Door_3_rot"]]
		["Land_i_Stone_HouseSmall_V1_F",		LAND_I_STONE_HOUSESMALL],
		["Land_i_Stone_HouseSmall_V1_dam_F",	LAND_I_STONE_HOUSESMALL],
		["Land_i_Stone_HouseSmall_V2_F",		LAND_I_STONE_HOUSESMALL],
		["Land_i_Stone_HouseSmall_V2_dam_F",	LAND_I_STONE_HOUSESMALL],
		["Land_i_Stone_HouseSmall_V3_F",		LAND_I_STONE_HOUSESMALL],
		["Land_i_Stone_HouseSmall_V3_dam_F",	LAND_I_STONE_HOUSESMALL],
		
		[
			"Land_Airport_left_F",
			[
				[[25.2932,-4.73755,-6.73733], "Door_1_rot"],
				[[14.6909,-4.79712,-6.73733], "Door_2_rot"],
				[[14.7954,11.5122,-6.73733], "Door_3_rot"],
				[[5,-3.72559,-6.73733], "Door_4_rot"],
				[[2.95825,-1.79639,-1.73733], "Door_5_rot"],
				[[-5.98804,-0.515381,-1.73733], "Door_6_rot"],
				[[-0.601807,-15.106,-6.73733], ["Door_7A_move", "Door_7B_move"]],
				[[-0.591797,15.1272,-6.73733], ["Door_8A_move", "Door_8B_move"]]
			]
		],
		[
			"Land_Airport_right_F",
			[
				[[-25.2656,-4.8042,-6.73733], "Door_1_rot"],
				[[-14.6499,-4.80078,-6.73733], "Door_2_rot"],
				[[-14.762,11.5735,-6.73733], "Door_3_rot"],
				[[-5.1748,-3.68457,-6.73733], "Door_4_rot"],
				[[-2.96436,-1.81738,-1.73733], "Door_5_rot"],
				[[5.98535,-0.398682,-1.73733], "Door_6_rot"],
				[[0.570068,-15.1599,-6.73733], ["Door_7A_move", "Door_7B_move"]],
				[[0.610596,15.3569,-6.73733], ["Door_8A_move", "Door_8B_move"]]
			]
		],
		[
			"Land_Airport_Tower_F",
			[
				[[1.32935,2.26733,-10.4415], "Door_1_rot"],
				[[-0.605469,0.817383,-1.44081], "Door_2_rot"]
			]
		],
		["Land_Airport_Tower_dam_F", [[[2.31616,3.75049,-8.17514], "Door_1_rot"]]],
		
		#define LAND_CARGO20 [[[-2.96436,-0.0351563,-1.17787], ["Door_1_rot", "Door_2_rot"]]]
		["Land_Cargo20_blue_F",			LAND_CARGO20],
		["Land_Cargo20_brick_red_F",	LAND_CARGO20],
		["Land_Cargo20_cyan_F",			LAND_CARGO20],
		["Land_Cargo20_grey_F",			LAND_CARGO20],
		["Land_Cargo20_light_blue_F",	LAND_CARGO20],
		["Land_Cargo20_light_green_F",	LAND_CARGO20],
		["Land_Cargo20_military_green_F",	LAND_CARGO20],
		["Land_Cargo20_orange_F",		LAND_CARGO20],
		["Land_Cargo20_red_F",			LAND_CARGO20],
		["Land_Cargo20_sand_F",			LAND_CARGO20],
		["Land_Cargo20_white_F",		LAND_CARGO20],
		["Land_Cargo20_yellow_F",		LAND_CARGO20],
		
		#define LAND_CARGO40 [[[-6.00146,-0.034668,-1.18187], ["Door_1_rot", "Door_2_rot"]]]
		["Land_Cargo40_blue_F",			LAND_CARGO40],
		["Land_Cargo40_brick_red_F",	LAND_CARGO40],
		["Land_Cargo40_cyan_F",			LAND_CARGO40],
		["Land_Cargo40_grey_F",			LAND_CARGO40],
		["Land_Cargo40_light_blue_F",	LAND_CARGO40],
		["Land_Cargo40_light_green_F",	LAND_CARGO40],
		["Land_Cargo40_military_green_F",	LAND_CARGO40],
		["Land_Cargo40_orange_F",		LAND_CARGO40],
		["Land_Cargo40_red_F",			LAND_CARGO40],
		["Land_Cargo40_sand_F",			LAND_CARGO40],
		["Land_Cargo40_white_F",		LAND_CARGO40],
		["Land_Cargo40_yellow_F",		LAND_CARGO40],
		
		[
			"Land_CarService_F",
			[
				[[1.01733,-1.88135,-1.25606], "Door_1_rot"],
				[[-0.0632324,6.27026,-1.25606], "Door_2_rot"],
				[[3.3811,8.60718,-1.25606], "Door_3_rot"]
			]
		],
		[
			"Land_Factory_Main_F",
			[
				[[-10.9998,11.0737,-6.24667], "Door_1_rot"],
				[[-6.22217,8.29834,-6.27167], "Door_2_rot"]
			]
		],
		[
			"Land_FuelStation_Build_F",
			[
				[[0.00634766,-1.70264,-1.33598], "Door_1_rot"],
				[[1.52466,1.99561,-1.33611], "Door_2_rot"]
			]
		],
		[
			"Land_i_Shed_Ind_F",
			[
				[[-9.09351,5.95923,-1.40978], ["Door_1_rot", "Door_2_rot"]],
				[[-7.83813,-2.00854,-1.40978], "Door_3_rot"],
				[[-8.33643,2.46899,-1.40978], "Door_4_rot"],
				[[13.7107,-2.05518,-1.40978], ["Door_5_rot", "Door_6_rot"]]
			]
		],
		
		#define LAND_I_BARRACKS	[ \
			[[-5.51221,-6.75781,0.591874], "Door_1_rot"], \
			[[14.8027,0.0830078,0.605519], "Door_2_rot"], \
			[[9.50024,4.83301,0.589749], "Door_3_rot"], \
			[[-2.53955,4.82568,0.602982], "Door_4_rot"], \
			[[-5.65137,4.85205,3.9395], "Door_5_rot"], \
			[[3.44189,4.83057,3.9395], "Door_6_rot"], \
			[[9.48315,4.83667,3.9395], "Door_7_rot"], \
			[[14.9141,0.171143,3.9395], "Door_8_rot"], \
			[[-11.104,-0.907227,0.60552], "Door_9_rot"], \
			[[-8.74707,1.06201,0.60552], "Door_10_rot"], \
			[[-0.400879,1.05518,0.60552], "Door_11_rot"], \
			[[3.57227,-0.93335,0.60552], "Door_12_rot"], \
			[[6.35474,1.09619,0.60552], "Door_13_rot"], \
			[[10.3669,1.06982,0.60552], "Door_14_rot"], \
			[[13.2195,-0.918701,0.60552], "Door_15_rot"], \
			[[-11.1819,-0.935547,3.9395], "Door_16_rot"], \
			[[-8.76489,1.08472,3.9395], "Door_17_rot"], \
			[[-0.413574,1.04199,3.9395], "Door_18_rot"], \
			[[3.58984,-0.92334,3.9395], "Door_19_rot"], \
			[[6.35059,1.04834,3.9395], "Door_20_rot"], \
			[[10.3633,1.11963,3.9395], "Door_21_rot"], \
			[[13.2368,-0.935303,3.9395], "Door_22_rot"]]
		["Land_i_Barracks_V1_F",		LAND_I_BARRACKS],
		["Land_i_Barracks_V1_dam_F",	LAND_I_BARRACKS],
		["Land_i_Barracks_V2_F",		LAND_I_BARRACKS],
		["Land_i_Barracks_V2_dam_F",	LAND_I_BARRACKS],
		
		[
			"Land_u_Barracks_V2_F",
			[
				[[-9.01221,-5.75781,-1.891874], "Door_1_rot"],
				[[11.3027,1.1530078,-1.905519], "Door_2_rot"],
				[[6.00024,5.83301,-1.889749], "Door_3_rot"],
				[[-6.03955,5.82568,-1.902982], "Door_4_rot"],
				[[-9.15137,5.85205,1.4395], "Door_5_rot"],
				[[0.06189,5.83057,1.4395], "Door_6_rot"],
				[[5.98315,5.83667,1.4395], "Door_7_rot"],
				[[11.4141,1.171143,1.4395], "Door_8_rot"],
				[[-14.604,0.107227,-1.90552], "Door_9_rot"],
				[[-12.24707,2.06201,-1.90552], "Door_10_rot"],
				[[-3.900879,2.05518,-1.90552], "Door_11_rot"],
				[[0.07227,0.13335,-1.90552], "Door_12_rot"],
				[[2.85474,2.09619,-1.90552], "Door_13_rot"],
				[[6.8669,2.06982,-1.90552], "Door_14_rot"],
				[[9.7195,0.118701,-1.90552], "Door_15_rot"],
				[[-14.6819,0.135547,1.4395], "Door_16_rot"],
				[[-12.26489,2.08472,1.4395], "Door_17_rot"],
				[[-3.913574,2.04199,1.4395], "Door_18_rot"],
				[[0.08984,0.12334,1.4395], "Door_19_rot"],
				[[2.85059,2.04834,1.4395], "Door_20_rot"],
				[[6.8633,2.11963,1.4395], "Door_21_rot"],
				[[9.7368,0.135303,1.4395], "Door_22_rot"]
			]
		],
		
		#define LAND_CARGO_HOUSE [[[0.730957,-0.200195,-0.0957494], "Door_1_rot"]]
		["Land_Cargo_House_V1_F",	LAND_CARGO_HOUSE],
		["Land_Cargo_House_V2_F",	LAND_CARGO_HOUSE],
		["Land_Cargo_House_V3_F",	LAND_CARGO_HOUSE],
		
		#define LAND_CARGO_HQ [ \
			[[-4.37964,-2.2937,-3.27229], "Door_1_rot"], \
			[[2.41895,-3.01953,-0.672286], "Door_2_rot"]]
		["Land_Cargo_HQ_V1_F",	LAND_CARGO_HQ],
		["Land_Cargo_HQ_V2_F",	LAND_CARGO_HQ],
		["Land_Cargo_HQ_V3_F",	LAND_CARGO_HQ],
		
		#define LAND_CARGO_TOWER [ \
			[[-0.821289,-1.93799,5.07987], "Door_1_rot"], \
			[[3.87866,0.433105,-0.120125], "Door_2_rot"], \
			[[0.132813,4.23706,-0.120125], "Door_3_rot"]]
		["Land_Cargo_Tower_V1_F",		LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V1_No1_F",	LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V1_No2_F",	LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V1_No3_F",	LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V1_No4_F",	LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V1_No5_F",	LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V1_No6_F",	LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V1_No7_F",	LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V2_F",		LAND_CARGO_TOWER],
		["Land_Cargo_Tower_V3_F",		LAND_CARGO_TOWER],
		["Land_Medevac_house_V1_F",		LAND_CARGO_HOUSE],
		["Land_Medevac_HQ_V1_F",		LAND_CARGO_HQ],
		
		[
			"Land_MilOffices_V1_F",
			[
				[[-12.0823,11.6567,-2.86676], "Door_1_rot"],
				[[4.13403,-6.05859,-2.86676], "Door_2_rot"],
				[[13.8674,-5.98828,-2.86676], "Door_3_rot"],
				[[7.88184,4.12891,-2.86676], "Door_4_rot"],
				[[-12.8137,-1.5249,-2.86676], "Door_5_rot"],
				[[-10.9253,-2.80322,-2.86676], "Door_6_rot"],
				[[10.5718,-4.19482,-2.86676], "Door_7_rot"],
				[[10.5447,-2,-2.86676], "Door_8_rot"]
			]
		],
		[
			"Land_Dome_Big_F",
			[
				[[23.2537,-0.234375,-10.1811], ["Door_1A_move", "Door_1B_move"]],
				[[-0.617188,-24.4429,-10.1811], "Door_2_rot"],
				[[-0.540771,24.0342,-10.1811], "Door_3_rot"]
			]
		],
		[
			"Land_Dome_Small_F",
			[
				[[0.00561523,14.1118,-6.93302], ["Door_1A_rot", "Door_1B_rot"]],
				[[-0.0483398,-14.0713,-6.93302], ["Door_2A_rot", "Door_2B_rot"]]
			]
		],
		["Land_Research_house_V1_F",LAND_CARGO_HOUSE],
		["Land_Research_HQ_F",		LAND_CARGO_HQ],
		["Land_BarGate_F",			[[[-0.271729,-0.0668945,-4.04884], "Door_1_rot"]]],
		["Land_City_Gate_F",		[[[-0.0090332,-0.165283,-0.500221], ["Door_1_rot", "Door_2_rot"]]]],
		["Land_Net_Fence_Gate_F",	[[[0.0195313,0.0183105,-1.03606], ["Door_1_rot", "Door_2_rot"]]]],
		["Land_Stone_Gate_F",		[[[-0.0373535,0.165771,-0.506733], ["Door_1_rot", "Door_2_rot"]]]],
		["Land_Kiosk_blueking_F",	[[[-0.0341797,1.87793,-1.76589], "Door_1_rot"]]],
		["Land_Kiosk_gyros_F",		[[[-0.00195313,1.88965,-1.97606], "Door_1_rot"]]],
		["Land_Kiosk_papers_F",		[[[-0.00488281,1.88574,-1.97606], "Door_1_rot"]]],
		["Land_Kiosk_redburger_F",	[[[-0.0217285,1.8623,-2.87051], "Door_1_rot"]]]
	];
	
	_allBuildingDoorsChernarus =
	[
		[
			"Test_Chernarus_Building_ClassName",
			[
				["Che_pos", "Che_door"]
			]
		]
	];
	
	_allBuildingDoorsTakistan =
	[
		[
			"Test_Takistan_Building_ClassName",
			[
				["Tak_pos", "Tak_door"]
			]
		]
	];
	
	_allBuildingDoorsTanao =
	[
		[
			"Test_Tanao_Building_ClassName",
			[
				["Tan_pos", "Tan_door"]
			]
		]
	];
	
	_allBuildingDoors = [];
	_createBuildingDoorsString = "";
	{
		_createBuildingDoorsString = format ["%1_allBuildingDoors append _allBuildingDoors%2;", _createBuildingDoorsString, _x];
	} count _objects;
	
	call compile _createBuildingDoorsString;
	
	_allBuildingDoors = [_allBuildingDoors, 2] call _fnc_transformArray;	//debug
	
	//debug
	// copyToClipboard str _allBuildingDoors;
	// systemChat "copied";
	
	_mapRadius = (getNumber (configFile >> "CfgWorlds" >> worldName >> "mapSize")) / 2;
	_mapCenter = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");
	
	/*
		It's more efficient to compile this function once,
		taking into account the _doorsStayOpen parameter,
		rather than performing that if-statement for each door trigger that's being created
		on each _fnc_createDoorTriggers invocation
		
		DON'T TOUCH THIS "COMPILE" STATEMENT!!!
		It is a true masterpiece of dynamic and - at the same time - efficient code.
		Because ... let's face it as what it is - a big "fuckup" that does its job. xD
	*/
	_fnc_createTriggerStatements = compile
	("
		_statementActivation = '';
		_statementDeactivation = '';
		
		if(typeName _doorName isEqualTo 'ARRAY') then
		{
			_statementActivation	= '_building = thisTrigger getVariable ""building"";';" +
		(if(!_doorsStayOpen) then
		{
			format ["_statementDeactivation	= '			
				_nearUnit = nearestObject [thisTrigger, ""Man""];
				_doorsStayOpenCustom = (isPlayer _nearUnit && _nearUnit getVariable [""%1"", false]);
				
				if(!_doorsStayOpenCustom) then
				{
					_building = thisTrigger getVariable ""building"";
			';", DOORS_STAY_OPEN]
		}
		else {""}) +
			"{
				_statementActivation	= format ['%1_building animate [""%2"", 1];', _statementActivation, _x];" +
		(if(!_doorsStayOpen) then
		{		/*
					This string extends the _statementDeactivation from the first if-statement.
					This string itself is inside the count _doorName loop,
					but NOT inside the if(!_doorsStayOpenCustom) statement.
					The formatted sub string inside it, however, is
				*/
				"_statementDeactivation	= format ['
					%1_building animate [""%2"", 0];
				', _statementDeactivation, _x];"
		}
		else {""}) +
			"} count _doorName;
			_statementDeactivation = _statementDeactivation +
				'};';
		}
		else
		{
			_statementActivation	= format ['(thisTrigger getVariable ""building"") animate [""%1"", 1];', _doorName];" +
		(if(!_doorsStayOpen) then
		{
			format ["_statementDeactivation	= format ['
				_nearUnit = nearestObject [thisTrigger, ""Man""];
				_doorsStayOpenCustom = (isPlayer _nearUnit && _nearUnit getVariable [""%1"", false]);
				
				if(!_doorsStayOpenCustom) then
				{
					(thisTrigger getVariable ""building"") animate [""%2"", 0];
				};
			', _doorName];
			", DOORS_STAY_OPEN, "%1"]
		} else {""}) +
		"};
		[_statementActivation, _statementDeactivation]
	");
	
	_fnc_createDoorTriggers =
	{
		private ["_building", "_buildingDoors", "_allDoorTriggers", "_allSpheres"];
		_building		= _this select 0;
		_buildingDoors	= _this select 1;
		
		//debug
		if(isNil "_buildingDoors" || {typeName _buildingDoors != "ARRAY" || _buildingDoors isEqualTo []}) exitWith
		{
			_hintString = format ["%1No doors found for building type ""%2""\n", _hintString, typeOf _building];
		};
		
		_allDoorTriggers = [];
		_allSpheres = [];	//debug
		
		systemChat "Creating door triggers";	//debug
		
		{
			//_x == door(s)
			_doorName	= _x select 1;
			
			_triggerStatements = [] call _fnc_createTriggerStatements;
			
			_position = _building modelToWorld (_x select 0);
			
			_doorTrigger = createTrigger ["EmptyDetector", _position];
			_doorTrigger setTriggerArea [DOOR_RADIUS, DOOR_RADIUS, 0, false];
			_doorTrigger setTriggerActivation ["ANY", "PRESENT", true];
			_doorTrigger setVariable ["building", _building];
			_doorTrigger setVariable ["position", _position];
			_doorTrigger setTriggerStatements
			[
				format
				["
					isServer &&
					{
						if(isNull scriptHandle_automatedDoors) then
						{
							{	comment 'debug';
								deleteVehicle _x;
							} count ((thisTrigger getVariable 'building') getVariable ['%2', []]);
							deleteVehicle thisTrigger;
						}
						else {true}
					} &&
					{
						(if
						(
							{
								if
								(
									isPlayer _x && {_x getVariable ['%1', true]} &&
									{
										comment 'Height difference between player position and original trigger position is less than 1 meter';
										(abs (((getPosATL _x) select 2) - ((thisTrigger getVariable 'position') select 2))) < 1
									}
								) exitWith {1}
							} count thisList isEqualTo 1
						)
						then {true} else {false}) &&
						this
					}",
					USES_AUTO_DOORS, DOOR_SPHERES
				],
				_triggerStatements select 0,
				_triggerStatements select 1
			];
			
			_allDoorTriggers pushBack _doorTrigger;
			
			//debug
			_sphere = createVehicle ["Sign_Sphere100cm_F", _position, [], 0, "CAN_COLLIDE"];
			_sphere enableSimulation false;
			_allSpheres pushBack _sphere;
		} forEach _buildingDoors;
		
		_building setVariable [DOOR_TRIGGERS, _allDoorTriggers];
		_building setVariable [DOOR_SPHERES, _allSpheres];	//debug
	};

	_fnc_removeDoorTriggers =
	{
		systemChat "Removing door triggers";	//debug
		// _building	= _this;
		
		{
			deleteVehicle _x;
		} count (_this getVariable [DOOR_TRIGGERS, []]);
		
		{	//debug
			deleteVehicle _x;
		} count (_this getVariable [DOOR_SPHERES, []]);
		
		_this setVariable [DOOR_TRIGGERS, nil];
		_this setVariable [DOOR_SPHERES, nil];	//debug
	};
	
	_allBuildingClassNames	= _allBuildingDoors select 0;
	_allDoorPositions		= _allBuildingDoors select 1;
	_allNearestBuildingsOld = [];
	_allNearestBuildingsNew = [];
	
	while {true} do
	{
		_allLocations = [];
		_hintString = "";	//debug
		
		{
			if(0 isEqualTo ((name _x) find "doors")) then
			{
				_hintString = format ["%1location %2 added\n", _hintString, name _x];	//debug
				0 = _allLocations pushBack _x;
			};
		} count (nearestLocations [_mapCenter, ["Name"], _mapRadius]);
		
		if([] isEqualTo _allLocations) then	//take into account all buildings
		{
			{
				//_x == player
				0 = {
					//_x == object
					if !(_x in _allNearestBuildingsNew) then
					{
						0 = _allNearestBuildingsNew pushBack _x;
					};
				} count (nearestObjects [_x, ["House", "Cargo_base_F", "Wall_F"], SCAN_RADIUS]);
			} count allPlayers;
		}
		else
		{
			{
				//_x == player
				0 = {
					//_x == object
					if !(_x in _allNearestBuildingsNew) then
					{
						_object = _x;
						0 = {
							//_x == location
							if(getPosATL _object in _x) exitWith	//take into account only buildings which are in respective locations
							{
								0 = _allNearestBuildingsNew pushBack _object;
							};
						} count _allLocations;
					};
				} count (nearestObjects [_x, ["House", "Cargo_base_F", "Wall_F"], SCAN_RADIUS]);
			} count allPlayers;
		};
		
		_hintString = format ["%1cleared objects: %2\n", _hintString,	//debug
			{
				_x call _fnc_removeDoorTriggers;
				true
			} count (_allNearestBuildingsOld - _allNearestBuildingsNew)
		];
		
		_hintString = format ["%1filled objects: %2\n", _hintString,	//debug
			{
				_buildingIndex	= _allBuildingClassNames find (typeOf _x);
				if(-1 != _buildingIndex) then
				{
					[_x, _allDoorPositions select _buildingIndex] call _fnc_createDoorTriggers;
					true
				}
				else	//debug
				{
					// if (0 != (typeOf _x find "Land_u_")) then
					if !(((typeOf _x) select [0, 7]) in ["Land_u_", "Land_d_"]) then
					{
						_hintString = format ["%1Type ""%2"" not found\n", _hintString, typeOf _x];
					};
					false
				};
			} count (_allNearestBuildingsNew - _allNearestBuildingsOld)
		];
		
		hintSilent _hintString;	//debug
		
		_allNearestBuildingsOld = _allNearestBuildingsNew;
		_allNearestBuildingsNew = [];
		
		sleep SCAN_SLEEP;
	};
};
publicVariable "scriptHandle_automatedDoors";
