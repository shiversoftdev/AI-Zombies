AddCinematicPoint( cameraorigin, camerapanorigin, cameralookatorigin, duration )
{
	cinematic = spawnstruct();
	cinematic.cameraorigin = cameraorigin;
	cinematic.camerapanorigin = camerapanorigin;
	cinematic.cameralookatorigin = cameralookatorigin;
	cinematic.duration = duration;
	level.zcinematics[ level.zcinematics.size ] = cinematic;
}

PlayCinematicOutro()
{
	if( level.zcinematics.size < 1 )
		return;
	foreach( zombie in level.zombie_team )
		zombie dodamage( zombie.health + 1, zombie getorigin() );
	level.zcinematiccamera = spawn("script_model", (0,0,0), 1);
	level.zcinematiccamera SetModel("script_origin");
	level.outroscreen fadeovertime(.5);
	level.outroscreen.alpha = 1;
	foreach( client in level.players )
	{
		client CameraActivate(true);
		client.AmmoCounter_Weaponname destroy();
		client.AmmoCounter_SuperUpgrade destroy();
		client.AmmoCounter_Stockammo destroy();
		client.AmmoCounter_Magammo destroy();
		client.score_hud destroy();
		client ClearPerkHud();
	}
	level.round_hud destroy();
	foreach( hud in level.poweruphuds )
		hud destroy();
	for( i = 0; i < level.zcinematics.size; i++ )
	{
		cinematic = level.zcinematics[ i ];
		cinematic_origin = spawn("script_model", cinematic.cameralookatorigin, 1);
		cinematic_origin SetModel( "script_origin" );
		level.zcinematiccamera moveto( cinematic.cameraorigin, .01 );
		wait .02;
		foreach( client in level.players )
		{
			client CameraSetPosition(level.zcinematiccamera);
			client CameraSetLookAt(cinematic_origin);
		}
		level.zcinematiccamera moveto( (cinematic.camerapanorigin - cinematic.cameraorigin) , cinematic.duration );
		level.outroscreen fadeovertime(.5);
		level.outroscreen.alpha = 0;
		wait (cinematic.duration - .5);
		level.outroscreen fadeovertime(.5);
		level.outroscreen.alpha = 1;
		wait .6;
		cinematic_origin delete();
	}
}
