_Lamp1 = "Land_LampStadium_F" createVehicle [7181,985,1];
_Lamp1 setPosASL [7181,985,1];
_Lamp1 setDir 45;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_Lamp1];

_Lamp2 = "Land_LampStadium_F" createVehicle [7180,1305,1];
_Lamp2 setPosASL [7180,1305,1];
_Lamp2 setDir -45;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_Lamp2];

private ["_vehicle1","_vehicle2","_vehicle3","_vehicle4","_vehicle5","_vehicle6"];
_vehicle1 = "I_G_Offroad_01_armed_F" createVehicle [7056,1014,1];
_vehicle1 setPosASL [7059,1018,1];
_vehicle1 setDir 180;

_vehicle2 = "I_MRAP_03_F" createVehicle [7203-70,919+70,1];
_vehicle2 setPosASL [7203-70,919+70,1];
_vehicle2 setDir 180;

private ["_BaseCastle1","_BaseCastle2","_BaseCastle3","_BaseCastle4","_BaseCastle5","_BaseCastle6"];
_BaseCastle1 = "Land_Castle_01_wall_01_F" createVehicle [6967,1290,12];
_BaseCastle1 setPosASL [6967,1290,12];
_BaseCastle1 setDir 270;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_BaseCastle1];

_BaseCastle2 = "Land_Castle_01_wall_01_F" createVehicle [7100,1290,12];
_BaseCastle2 setPosASL [7100,1290,12];
_BaseCastle2 setDir 270;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_BaseCastle2];

_BaseCastle3 = "Land_Castle_01_wall_01_F" createVehicle [7163,1160,12];  
_BaseCastle3 setPosASL [7163,1160,12];  
_BaseCastle3 setDir 0;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_BaseCastle3];

_BaseCastle4 = "Land_Castle_01_wall_01_F" createVehicle [7126,999,12];  
_BaseCastle4 setPosASL [7126,999,12];  
_BaseCastle4 setDir 90;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_BaseCastle4];

_BaseCastle5 = "Land_Castle_01_wall_01_F" createVehicle [6970,999,12];  
_BaseCastle5 setPosASL [6970,999,12];  
_BaseCastle5 setDir 90;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_BaseCastle5];

_BaseCastle6 = "Land_Castle_01_wall_01_F" createVehicle [6940,1142,12];  
_BaseCastle6 setPosASL [6940,1142,12];  
_BaseCastle6 setDir 180;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_BaseCastle6];

private ["_CastleWall1"];
_CastleWall1 = "Land_Castle_01_wall_10_F" createVehicle [6954,1029,3];  
_CastleWall1 setPosASL [6954,1029,3];  
_CastleWall1 setDir 0;
pvar_EventArenaBaseParts = pvar_EventArenaBaseParts + [_CastleWall1];
