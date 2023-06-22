MapInit()
{
	level.wallweapons = [];
	level.boxlocations = [];
	level.perkmachines = [];
	level.zcinematics = [];
	if( level.script == "mp_nuketown_2020" )
	{
		mp_nuketown_2020();
	}
	if( level.script == "mp_downhill" )
	{
		mp_downhill();
	}
	if( level.script == "mp_uplink")
	{
		mp_uplink();
	}
	if( level.script == "mp_paintball" )
		mp_paintball();
}

ClearModelNear( origin )
{
	model = GetClosest( origin, GetEntArray("script_model", "classname"));
	model connectpaths();
	model delete();
}

CreateBarrier( location, angles, size )
{
	barrier = spawn("script_model", location);
	if( size == 128 )
	{
		barrier setmodel( "collision_clip_wall_128x128x10" );
	}
	else if( size == 256 )
	{
		barrier setmodel( "collision_clip_wall_256x256x10" );
	}
	else if( size == 512 )
	{
		barrier setmodel( "collision_clip_wall_512x512x10" );
	}
	else if( size == 64 )
	{
		barrier setmodel( "collision_clip_wall_64x64x10" );
	}
	else if( size == 32 )
	{
		barrier setmodel("t6_wpn_supply_drop_ally");
		barrier hide();
	}
	barrier.angles = angles;
}

mp_nuketown_2020()
{
	ClearModelNear( (-59,804,-66) );
	ClearModelNear( (-690,8.7,-56) );
	ClearModelNear( (32,-472,-56) );
	CreateBarrier( (28.9,-407,-20), (0,0,0), 128 );
	CreateBarrier( (26.26,-522,-20), (0,0,0), 128 );
	CreateBarrier( (-61,-474,20), (0,90,0), 64 );
	CreateBarrier( (119,-473,20), (0,90,0), 64 );
	CreateBarrier( (-61,-464,20), (0,90,0), 64 );
	CreateBarrier( (119,-464,20), (0,90,0), 64 );
	CreateBarrier( (555,69,115), (0,120,0), 128 );
	CreateBarrier( (582,5,27), (0,195,0), 64 );
	CreateBarrier( (-522,297,152), (0,70,0), 128 );
	CreateBarrier( (-513,233,38), (0,160,0), 64 );
	CreateBarrier( (1321,520,48), (0,-75,90), 32 );
	CreateBarrier( (1321,520,116), (0,-75,90), 32 );
	CreateBarrier( (1321,520,185), (0,-75,90), 32 );
	CreateBarrier( (1350,530,48), (0,-75,90), 32 );
	CreateBarrier( (1350,530,116), (0,-75,90), 32 );
	CreateBarrier( (1350,530,185), (0,-75,90), 32 );
	CreateBarrier( (1380,540,48), (0,-75,90), 32 );
	CreateBarrier( (1380,540,116), (0,-75,90), 32 );
	CreateBarrier( (1380,540,185), (0,-75,90), 32 );
	CreateBarrier( (1410,550,48), (0,-75,90), 32 );
	CreateBarrier( (1410,550,116), (0,-75,90), 32 );
	CreateBarrier( (1410,550,185), (0,-75,90), 32 );
	CreateBarrier( (1442,558,40), (0,-75,90), 32 );
	CreateBarrier( (1472,568,40), (0,-75,90), 32 );
	CreateBarrier( (1442,558,90), (0,-75,90), 32 );
	CreateBarrier( (1472,568,90), (0,-75,90), 32 );
	CreateBarrier( (664,300,179), (0,15,0), 32 );
	CreateBarrier( (1422,90,180), (0,0,0), 256 );
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "srm1216_mp", (-1654.48, 781.92, -1.248), (0,-20,0), 2000, 1000, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "sig556_mp", (-1460.33, 162.902, -10.3654), (0,-20,0), 1000, 500, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "beretta93r_mp", (-705.881, 452.791, 139.976), (0,65,0), 900, 450, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "an94_mp", (144.951, 478.388, 26.3585), (0,105,0), 3100, 1100, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "870mcs_mp", (916.352,147.671,2.991), (0,105,0), 1200, 600, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "svu_mp", (1292.15, 986.646, -2.974), (0,105,0), 5000, 2500, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "insas_mp", (-168.634, 1072.16, -7.811), (0,30,0), 1100, 650, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "mp7_mp", (-972.985, 228.155, -0.824), (0,70,0), 2000, 1000, 4000 ), 0);
	AddBoxLocation( (0,15,0), (1736,765,-64) );
	AddBoxLocation( (0,115,0), (-277,989,-64) );
	AddBoxLocation( (0,105,0), (589,425,-59) );
	AddBoxLocation( (0,70,0), (-1567,1179,-64) );
	AddBoxLocation( (0,70,0), (-918,58,-57) );
	AddBoxLocation( (0,0,0), (330,-276,-61) );
	RandomLocation = level.boxlocations[ randomintrange(0, level.boxlocations.size) ];
	CreateMysteryBox( RandomLocation.location, RandomLocation.angles );
	CreatePAP( (1422,60,-60), (0,195,0) );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (1117,446,78), (0,15,0), "Quick Revive", ::QuickRevive, 1500, "perk_ghost"  );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (512,1010,-62), (0,250,0), "Juggernog", ::Juggernog, 2500, "perk_warrior" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (-801,734,-63), (0,70,0), "Speed Cola", ::SpeedCola, 3000, "perk_fast_hands" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (-1650,639,-64), (0,-20,0), "Mulekick", ::MuleKick, 4000, "perk_flak_jacket" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (-541,596,79), (0,250,0), "Staminup", ::Staminup, 2000, "perk_marathon" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (724, 65, 79), (0,195,0), "Double Tap", ::DoubleTap, 2000, "perk_dexterity" );
	AddCinematicPoint( (-350,-681,494), (-757,-163,494), (-100,-49,62), 5 );
	AddCinematicPoint( (-1820,173,376), (-1863,1157,376), (-1101,695,76), 5 );
	AddCinematicPoint( (483,-917,473), (-483,-917,473), (58,-1595,462), 5 );
}

mp_downhill()
{
	models = getEntArray("script_model", "classname" );
	CreateBarrier( (1046,1705,1161), (0,45,0), 32 );
	CreateBarrier( (974,1735,1168), (0,-45,90), 32 );
	CreateBarrier( (956,1704,1164), (0,50,90), 32 );
	CreateBarrier( (1047,1705,1192), (0,45,0), 32 );
	CreateBarrier( (937,1672,1163), (0,-85,90), 32 );
	CreateBarrier( (940,1638,1163), (0,-75,90), 32 );
	CreateBarrier( (1655,1652,1109), (0,0,90), 32 );
	CreateBarrier( (1692,1662,1105), (0,0,90), 32 );
	CreateBarrier( (1671,1629,1123), (0,0,0), 32 );
	CreateBarrier( (1038,2815,1481), (0,30,0), 256 );
	CreateBarrier( (866,2496,1333), (0,-15,0), 32 );
	CreateBarrier( (960,2314,1312), (0,0,90), 32 );
	CreateBarrier( (960,2316,1253), (0,0,90), 32 );
	CreateBarrier( (957,2292,1256), (0,0,90), 32 );
	CreateBarrier( (348,1489,1055), (0,105,0), 128 );
	CreateBarrier( (417,1508,1102), (0,90,0), 128 );
	CreateBarrier( (-558,469,1159), (0,160,0), 256 );
	CreateBarrier( (-121,1026,1143), (0,0,90), 32 );
	CreateBarrier( (-153,1005,1144), (0,0,90), 32 );
	CreateBarrier( (-154,1022,1141), (0,0,90), 32 );
	CreateBarrier( (809,-1629,1014), (0,0,90), 32 );
	CreateBarrier( (365,-2028,1065), (0,90,0), 256 );
	CreateBarrier( (277,-1986,1067), (0,85,0), 256 );
	CreateBarrier( (314,-2048,1065), (0,165,0), 128 );
	CreateBarrier( (2691,-327,946), (0,90,0), 256 );
	CreateBarrier( (2694,-187,948), (0,90,0), 256 );
	CreateBarrier( (2695,-32,948), (0,90,0), 256 );
	CreateBarrier( (2067,1182,1030), (0,0,90), 32 );
	CreateBarrier( (1373,147,931), (0,0,90), 32 );
	CreateBarrier( (1347,183,930), (0,0,90), 32 );
	CreateBarrier( (1169,-955,940), (0,0,90), 32 );
	CreateBarrier( (1374,-506,929), (0,0,90), 32 );
	CreateBarrier( (1333,-539,923), (0,0,90), 32 );
	CreateBarrier( (1337,-503,923), (0,0,90), 32 );
	CreateBarrier( (1013,-175,948), (0,90,0), 128 );
	CreateBarrier( (954,-145,923), (0,185,0), 128 );
	CreateBarrier( (934,-221,934), (0,180,0), 128 );
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "sig556_mp", (1006,2394,1312), (0,70,0), 1000, 500, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "beretta93r_mp", (1315,2212,1181), (0,-10,0), 900, 450, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "an94_mp", (1552,413,978), (0,-90,0), 3100, 1100, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "xm8_mp", (6.8,-1532,1058), (0,-20,0), 4000, 1600, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "saritch_mp", (2157,-173,1009), (0,90,0), 1200, 600, 9000 ), 0);
	AddBoxLocation( (0,90,0), (590,-83,864) );
	AddBoxLocation( (0,0,0), (2023,-177,948) );
	AddBoxLocation( (0,5,0), (1834,2280,1094) );
	AddBoxLocation( (0,0,0), (1397,-179,893) );
	AddBoxLocation( (0,90,0), (1048,-2586,1070) );
	AddBoxLocation( (0,25,0), (-78,-2362,1066) );
	RandomLocation = level.boxlocations[ randomintrange(0, level.boxlocations.size) ];
	CreateMysteryBox( RandomLocation.location, RandomLocation.angles );
	CreatePAP( (1320,2356,1121), (0,163,0) );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (265,681,1065), (0,45,0), "Quick Revive", ::QuickRevive, 1500, "perk_ghost"  );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (1201,2621,1253), (0,70,0), "Juggernog", ::Juggernog, 2500, "perk_warrior" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (1904,660,980), (0,0,0), "Speed Cola", ::SpeedCola, 3000, "perk_fast_hands" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (2143,-1783,952), (0,0,0), "Mulekick", ::MuleKick, 4000, "perk_flak_jacket" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (531,-1202,1001), (0,160,0), "Staminup", ::Staminup, 2000, "perk_marathon" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (-548,491,1062), (0,75,0), "Double Tap", ::DoubleTap, 2000, "perk_dexterity" );
	AddCinematicPoint( (3196,1515,1526), (3590,650,1526), (2478,401,953), 5 );
	AddCinematicPoint( (1125,-59,1022), (1172,-360,1022), (1609,-181,1049), 3 );
	AddCinematicPoint( (279,2231,1820), (814,1588,1741), (999,2414,1398), 5 );
	AddCinematicPoint( (20,-3999,1704), (41,-5478,1952), (57,-6233,2136), 5 );
}

mp_uplink()
{
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "870mcs_mp", (3042,-1224,508), (0,0,0), 1200, 600, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "beretta93r_mp", (2503,144,381), (0,-175,0), 900, 450, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "sig556_mp", (1941,-357,157), (0,30,0), 1000, 500, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "an94_mp", (2261,1733,343), (0,0,0), 3100, 1100, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "srm1216_mp", (3195,-53,369), (0,90,0), 2000, 1000, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "dsr50_mp", (2864,-1992,494), (0,15,0), 7500, 1000, 10000 ), 0);
	AddBoxLocation( (0,0,0), (3592,-2190,367) );
	AddBoxLocation( (0,90,0), (2312,-1698,392) );
	AddBoxLocation( (0,0,0), (1444,-871,125) );
	AddBoxLocation( (0,90,0), (2943,2055,288) );
	AddBoxLocation( (0,0,0), (3180,487,320) );
	AddBoxLocation( (0,0,0), (3309,-663,320) );
	RandomLocation = level.boxlocations[ randomintrange(0, level.boxlocations.size) ];
	CreateMysteryBox( RandomLocation.location, RandomLocation.angles );
	CreatePAP( (4061,-1234,317.217), (0,270,0) );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (3643,-3404,352), (0,145,0), "Quick Revive", ::QuickRevive, 1500, "perk_ghost"  );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (2367,-1273,320), (0,180,0), "Juggernog", ::Juggernog, 2500, "perk_warrior" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (3411,-1604,320), (0,0,0), "Speed Cola", ::SpeedCola, 3000, "perk_fast_hands" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (3854,-1005,320), (0,90,0), "Mulekick", ::MuleKick, 4000, "perk_flak_jacket" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (2758,1311,352), (0,90,0), "Staminup", ::Staminup, 2000, "perk_marathon" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (2449,-2880,352), (0,90,0), "Double Tap", ::DoubleTap, 2000, "perk_dexterity" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (3310,-2105,456), (0,180,0), "PHD Flopper", ::PHDFlopper, 4000, "hud_ks_m32" );
	AddCinematicPoint( (3404,-2481,863), (3833,-1683,863), (2938,-1989,590), 5 );
	AddCinematicPoint( (2262,2405,835), (3562,2202,835), (2903,3201,331), 5 );
	AddCinematicPoint( (-3744,-5806,3967), (-3331,-1408,3967), (-6318,-3758,4003), 5 );
	AddCinematicPoint( (1402,-4180,3603), (5546,-4111,3603), (3499,-6481,2501), 5 );
}

/*	Mapname

	Perk 0:	(origin,origin,origin) (angles,angles,angles)
	Perk 1: (), ()
	Perk 2: (), ()
	Perk 3: (), ()
	Perk 4: (), ()
	Perk 5: (), ()
	Perk 6: (), ()

	Box 0: (angles,angles,angles) (origin,origin,origin)
	Box 1: (), ()
	Box 2: (), ()
	Box 3: (), ()
	Box 4: (), ()
	Box 5: (), ()
	Box 6: (), ()
	
	Pack a Punch: (origin,origin,origin) (angles,angles,angles)
	Pack a Punch: (), ()
	
	Cinematic 0: (start,start,start) (end,end,end) (look,look,look) duration
	Cinematic 1: (), (), (),
	Cinematic 2: (), (), (),
	Cinematic 3: (), (), (),
	Cinematic 4: (), (), (),
	Cinematic 5: (), (), (),
	
	
	AddBoxLocation( );
	AddBoxLocation( );
	AddBoxLocation( );
	AddBoxLocation( );
	AddBoxLocation( );
	AddBoxLocation( );
	RandomLocation = level.boxlocations[ randomintrange(0, level.boxlocations.size) ];
	CreateMysteryBox( RandomLocation.location, RandomLocation.angles );
	CreatePAP( );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( , "Quick Revive", ::QuickRevive, 1500, "perk_ghost"  );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( , "Juggernog", ::Juggernog, 2500, "perk_warrior" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( , "Speed Cola", ::SpeedCola, 3000, "perk_fast_hands" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( , "Mulekick", ::MuleKick, 4000, "perk_flak_jacket" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( , "Staminup", ::Staminup, 2000, "perk_marathon" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( , "Double Tap", ::DoubleTap, 2000, "perk_dexterity" );
	AddCinematicPoint( );
	AddCinematicPoint( );
	AddCinematicPoint( );
	AddCinematicPoint( );
	AddCinematicPoint( );
*/

mp_paintball()
{
	AddBoxLocation( (0,0,0), (946,-1014,136) );
	AddBoxLocation( (0,90,0), (-139,-1753,0) );
	AddBoxLocation( (0,90,0), (-1160,-909,0) );
	AddBoxLocation( (0,0,0), (-495,446,6) );
	AddBoxLocation( (0,0,0), (378,1825,6) );
	AddBoxLocation( (0,0,0), (635,-201,4) );
	RandomLocation = level.boxlocations[ randomintrange(0, level.boxlocations.size) ];
	CreateMysteryBox( RandomLocation.location, RandomLocation.angles );
	CreatePAP( (-522,-2440,5), (0,90,0) );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (365,-1244,3), (0,180,0), "Quick Revive", ::QuickRevive, 1500, "perk_ghost"  );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (-612,-1833,0), (0,0,0), "Juggernog", ::Juggernog, 2500, "perk_warrior" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (750,-1556,0), (0,-90,0), "Speed Cola", ::SpeedCola, 3000, "perk_fast_hands" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (1007,-147,136), (0,90,0), "Mulekick", ::MuleKick, 4000, "perk_flak_jacket" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (24,1878,6), (0,0,0), "Staminup", ::Staminup, 2000, "perk_marathon" );
	level.perkmachines[ level.perkmachines.size ] = CreatePerk( (-1003, 604, 0), (0,90,0), "Double Tap", ::DoubleTap, 2000, "perk_dexterity" );
	AddCinematicPoint( (13,-2651,704), (593,-2612,704), (-144,-1495,273), 5);
	AddCinematicPoint( (-337,2210,883), (-1196,2033,883), (-513,1522,253), 5);
	AddCinematicPoint( (-1235,161,89), (-1063,-140,119), (-1058,-310,43), 5);
	AddCinematicPoint( (448,1361,319), (484,943,319), (1025,1331,366), 5);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "870mcs_mp", (493,-642,198), (0,0,0), 1200, 600, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "beretta93r_mp", (807,1663,110), (0,0,0), 900, 450, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "lsat_mp", (0,-1593,63), (0,90,0), 7500, 3000, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "kard_mp", (-556,-951,64), (0,0,0), 750, 350, 4500 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "saritch_mp", (-557,-14,57), (0,-175,0), 1200, 600, 9000 ), 0);
	level.wallweapons = add_to_array(level.wallweapons, CreateWallWeapon( "srm1216_mp", (-937,1254,61), (0,60,0), 2000, 1000, 9000 ), 0);
}


