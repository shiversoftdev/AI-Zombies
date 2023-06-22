powerups_init()
{
	level.powerups = [];
	level.poweruphuds = [];
	level.powerupsthisround = 0;
	deathmachinemodel = GetWeaponModel("minigun_mp");
	AddZombiePowerup( "Nuke", "t6_wpn_briefcase_bomb_view", ::Powerup_nuke, "hud_ks_emp_drop");
	AddZombiePowerup( "Max Ammo", "t6_wpn_briefcase_bomb_view", ::Powerup_maxammo, "hud_scavenger_pickup");
	AddZombiePowerup( "Double Points", "t6_wpn_briefcase_bomb_view", ::Powerup_Doublepoints, "perk_hardline");
	AddZombiePowerup( "Death Machine", deathmachinemodel, ::Powerup_DeathMachine, "none");
	AddZombiePowerup( "Insta Kill", "t6_wpn_briefcase_bomb_view", ::powerup_instakill, "headicon_dead" );
}

AddZombiePowerup( name, model, function, waypointicon)
{
	powerup = spawnstruct();
	powerup.name = name;
	powerup.model = model;
	powerup.function = function;
	powerup.waypointicon = waypointicon;
	level.powerups[ level.powerups.size ] = powerup;
}

powerup_round_start( number )
{
	if( level.round_number < 3 )
		return;
	level.powerupsthisround = 4;
}

TryPowerUpDrop( origin )
{
	if( level.powerupsthisround <= 0 )
		return;
	if( randomintrange(0, (level.round_number * level.round_number * 10) ) >= (level.round_number * 2 * level.powerupsthisround ) )
	{
		return;
	}
	level.powerupsthisround--;
	powerup = spawn( "script_model", origin + (0,0,35) );
	powerupnum = randomintrange( 0, level.powerups.size );
	powerup SetModel( level.powerups[ powerupnum ].model );
	powerup.function = level.powerups[ powerupnum ].function;
	if( powerup.wp != "none" )
		powerup.wp = powerup makewp( level.powerups[ powerupnum ].waypointicon );
	powerup thread powerup_monitor();
	powerup thread powerup_wobble();
	powerup thread timeout_powerup();
}

timeout_powerup()
{
	self endon("powerup_grabbed");
	wait 31;
	for( i = 7; i > 0; i--)
	{
		self hide();
		wait 1;
		self show();
		wait 1;
	}
	self hide();
	self notify("timeout");
	self.wp destroy();
	self delete();
}

powerup_wobble()
{
	self endon("timeout");
	while ( isDefined( self ) )
	{
		waittime = randomfloatrange( 2.5, 5 );
		yaw = randomint( 360 );
		if ( yaw > 300 )
		{
			yaw = 300;
		}
		else
		{
			if ( yaw < 60 )
			{
				yaw = 60;
			}
		}
		yaw = self.angles[ 1 ] + yaw;
		new_angles = ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) );
		self rotateto( new_angles, waittime, waittime * 0.5, waittime * 0.5 );
		wait randomfloat( waittime - 0.1 );
	}
}

powerup_monitor()
{
	self endon("timeout");
	while( isDefined(self) )
	{
		foreach( Human in level.players )
		{
			if( Distance2D( self GetOrigin(), Human GetOrigin() ) < 64 && isAlive( Human ))
			{
				self notify("powerup_grabbed");
				self thread [[ self.function ]]( Human );
				self.wp destroy();
				self delete();
				return;
			}
		}
		wait .05;
		waittillframeend;
	}
}

is_insta_kill_upgraded_and_active()
{
	return false;
}

Powerup_Doublepoints( useless )
{
	if(isDefined( level.doublepointsactive ) )
		return;
	level.doublepointsactive = true;
	foreach( player in level.players )
	{
		player setlowermessage("Double Points!");
		wait .01;
		player clearlowermessage( 1.5 );
	}
	hud = AddPowerUpHud( "Double Points" );
	wait 35;
	for( i = 0; i < 10; i++ )
	{
		hud.alpha = 0;
		hud fadeovertime( .75 );
		hud.alpha = 1;
		wait 1;
	}
	RemovePowerHud( "Double Points" );
	level.doublepointsactive = undefined;
}

Powerup_nuke( useless )
{
	foreach( human in level.players )
	{
		human playsound( "mpl_lightning_flyover_boom" );
		human AddToPlayerScore( 400 );
	}
	foreach( zombie in level.zombie_team )
	{
		zombie.thunderwall = true;
		zombie doDamage(zombie.health + 1, zombie.origin);
	}
	fadetowhite = newhudelem();
	fadetowhite.x = 0;
	fadetowhite.y = 0;
	fadetowhite.alpha = 0;
	fadetowhite.horzalign = "fullscreen";
	fadetowhite.vertalign = "fullscreen";
	fadetowhite.foreground = 1;
	fadetowhite setshader( "white", 640, 480 );
	fadetowhite fadeovertime( 0.2 );
	fadetowhite.alpha = 0.8;
	wait 0.5;
	fadetowhite fadeovertime( 1 );
	fadetowhite.alpha = 0;
	wait 1.1;
	fadetowhite destroy();
}

Powerup_maxammo( useless )
{
	foreach( player in level.players )
	{
		player setlowermessage("Max Ammo!");
		wait .01;
		player clearlowermessage( 1.5 );
		foreach( weapon in (player GetWeaponsList()) )
		{
			player GiveMaxAmmo( weapon );
			player notify("ammo_bought");
		}
	}
}

Powerup_DeathMachine( player )
{
	player notify("deathmachine");
	player endon("deathmachine");
	player endon("weapon_change");
	player giveweapon("minigun_mp");
	player switchtoweapon("minigun_mp");
	player givemaxammo("minigun_mp");
	wait 30;
	player setlowermessage("Death machine ammo low!");
	wait .01;
	player clearlowermessage( 3 );
	wait 5;
	player takeweapon("minigun_mp");
}

powerup_instakill( useless )
{
	if( isDefined( level.zombieinstakill ) )
		return;
	level.zombieinstakill = 1;
	foreach( player in level.players )
	{
		player setlowermessage("Insta Kill!");
		wait .01;
		player clearlowermessage( 1.5 );
	}
	hud = AddPowerUpHud( "Insta Kill" );
	wait 35;
	for( i = 0; i < 10; i++ )
	{
		hud.alpha = 0;
		hud fadeovertime( .75 );
		hud.alpha = 1;
		wait 1;
	}
	RemovePowerHud( "Insta Kill" );
	level.zombieinstakill = undefined;
}




