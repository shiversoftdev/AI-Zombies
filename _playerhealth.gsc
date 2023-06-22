_playerhealth_init()
{
	if ( !isDefined( level.script ) )
	{
		level.script = tolower( getDvar( "mapname" ) );
	}
	precacheshader( "overlay_low_health" );
	level.global_damage_func_ads = ::empty_kill_func;
	level.global_damage_func = ::empty_kill_func;
	level.difficultytype[ 0 ] = "easy";
	level.difficultytype[ 1 ] = "normal";
	level.difficultytype[ 2 ] = "hardened";
	level.difficultytype[ 3 ] = "veteran";
	level.difficultystring[ "easy" ] = &"GAMESKILL_EASY";
	level.difficultystring[ "normal" ] = &"GAMESKILL_NORMAL";
	level.difficultystring[ "hardened" ] = &"GAMESKILL_HARDENED";
	level.difficultystring[ "veteran" ] = &"GAMESKILL_VETERAN";
	level.gameskill = 1;
	switch( level.gameskill )
	{
		case 0:
			setdvar( "currentDifficulty", "easy" );
			break;
		case 1:
			setdvar( "currentDifficulty", "normal" );
			break;
		case 2:
			setdvar( "currentDifficulty", "hardened" );
			break;
		case 3:
			setdvar( "currentDifficulty", "veteran" );
			break;
	}
	level.player_deathinvulnerabletime = 1700;
	level.longregentime = 5000;
	level.healthoverlaycutoff = 0.2;
	level.invultime_preshield = 0.35;
	level.invultime_onshield = 0.5;
	level.invultime_postshield = 0.3;
	level.playerhealth_regularregendelay = 2400;
	level.worthydamageratio = 0.1;
	setdvar( "player_meleeDamageMultiplier", 0.4 );
}

empty_kill_func( type, loc, point, attacker, amount )
{
}

playerhealthregen()
{
	self notify( "playerHealthRegen" );
	self endon( "playerHealthRegen" );
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( self.flag ) )
	{
		self.flag = [];
		self.flags_lock = [];
	}
	if ( !isDefined( self.flag[ "player_has_red_flashing_overlay" ] ) )
	{
		self.flag[ "player_has_red_flashing_overlay" ] = 0;
		self.flag[ "player_is_invulnerable" ] = 0;
	}
	self thread healthoverlay();
	oldratio = 1;
	health_add = 0;
	regenrate = 0.1;
	veryhurt = 0;
	playerjustgotredflashing = 0;
	invultime = 0;
	hurttime = 0;
	newhealth = 0;
	lastinvulratio = 1;
	self thread playerhurtcheck();
	self thread realRegen();
	if ( !isDefined( self.veryhurt ) )
	{
		self.veryhurt = 0;
	}
	self.bolthit = 0;
	if ( getDvar( "scr_playerInvulTimeScale" ) == "" )
	{
		setdvar( "scr_playerInvulTimeScale", 1 );
	}
	playerinvultimescale = getDvarFloat( "scr_playerInvulTimeScale" );
	for ( ;; )
	{
		wait 0.05;
		waittillframeend;
		if ( self.health == self.maxhealth )
		{
			if ( self player_flag( "player_has_red_flashing_overlay" ) )
			{
				player_flag_clear( "player_has_red_flashing_overlay" );
			}
			lastinvulratio = 1;
			playerjustgotredflashing = 0;
			veryhurt = 0;
			continue;
		}
		else if ( self.health <= 0 )
		{
			return;
		}
		wasveryhurt = veryhurt;
		health_ratio = self.health / self.maxhealth;
		if ( health_ratio <= level.healthoverlaycutoff )
		{
			veryhurt = 1;
			if ( !wasveryhurt )
			{
				hurttime = getTime();
				self startfadingblur( 3.6, 2 );
				self player_flag_set( "player_has_red_flashing_overlay" );
				playerjustgotredflashing = 1;
			}
		}
	}
}

playerinvul( timer )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( timer > 0 )
	{
		wait timer;
	}
	self player_flag_clear( "player_is_invulnerable" );
}

player_flag_set( flag )
{
	self.flag[ flag ] = 1;
}

healthoverlay()
{
	self endon( "disconnect" );
	self endon( "noHealthOverlay" );
	if ( !isDefined( self._health_overlay ) )
	{
		self._health_overlay = newclienthudelem( self );
		self._health_overlay.x = 0;
		self._health_overlay.y = 0;
		self._health_overlay setshader( "overlay_low_health", 640, 480 );
		self._health_overlay.alignx = "left";
		self._health_overlay.aligny = "top";
		self._health_overlay.horzalign = "fullscreen";
		self._health_overlay.vertalign = "fullscreen";
		self._health_overlay.alpha = 0;
	}
	overlay = self._health_overlay;
	self thread healthoverlay_remove( overlay );
	self thread watchhideredflashingoverlay( overlay );
	pulsetime = 0.8;
	for ( ;; )
	{
		if ( overlay.alpha > 0 )
		{
			overlay fadeovertime( 0.5 );
		}
		overlay.alpha = 0;
		self player_flag_wait( "player_has_red_flashing_overlay" );
		self redflashingoverlay( overlay );
	}
}

fadefunc( overlay, severity, mult, hud_scaleonly )
{
	pulsetime = 0.8;
	scalemin = 0.5;
	fadeintime = pulsetime * 0.1;
	stayfulltime = pulsetime * ( 0.1 + ( severity * 0.2 ) );
	fadeouthalftime = pulsetime * ( 0.1 + ( severity * 0.1 ) );
	fadeoutfulltime = pulsetime * 0.3;
	remainingtime = pulsetime - fadeintime - stayfulltime - fadeouthalftime - fadeoutfulltime;
	if ( remainingtime < 0 )
	{
		remainingtime = 0;
	}
	halfalpha = 0.8 + ( severity * 0.1 );
	leastalpha = 0.5 + ( severity * 0.3 );
	overlay fadeovertime( fadeintime );
	overlay.alpha = mult * 1;
	wait ( fadeintime + stayfulltime );
	overlay fadeovertime( fadeouthalftime );
	overlay.alpha = mult * halfalpha;
	wait fadeouthalftime;
	overlay fadeovertime( fadeoutfulltime );
	overlay.alpha = mult * leastalpha;
	wait fadeoutfulltime;
	wait remainingtime;
}

redflashingoverlay( overlay )
{
	self endon( "hit_again" );
	self endon( "damage" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "clear_red_flashing_overlay" );
	self.stopflashingbadlytime = getTime() + level.longregentime;
	if ( isDefined( self.is_in_process_of_zombify ) && !self.is_in_process_of_zombify && isDefined( self.is_zombie ) && !self.is_zombie )
	{
		fadefunc( overlay, 1, 1, 0 );
		while ( getTime() < self.stopflashingbadlytime && isalive( self ) && isDefined( self.is_in_process_of_zombify ) && !self.is_in_process_of_zombify && isDefined( self.is_zombie ) && !self.is_zombie )
		{
			fadefunc( overlay, 0.9, 1, 0 );
		}
		if ( isDefined( self.is_in_process_of_zombify ) && !self.is_in_process_of_zombify && isDefined( self.is_zombie ) && !self.is_zombie )
		{
			if ( isalive( self ) )
			{
				fadefunc( overlay, 0.65, 0.8, 0 );
			}
			fadefunc( overlay, 0, 0.6, 1 );
		}
	}
	overlay fadeovertime( 0.5 );
	overlay.alpha = 0;
	self player_flag_clear( "player_has_red_flashing_overlay" );
	setclientsysstate( "levelNotify", "rfo3", self );
	wait 0.5;
	self notify( "hit_again" );
}

player_flag_wait(flag)
{
	while( !self player_flag(flag) )
		wait .05;
}

healthoverlay_remove( overlay )
{
	self endon( "disconnect" );
	self waittill_any( "noHealthOverlay", "death" );
	overlay fadeovertime( 3.5 );
	overlay.alpha = 0;
}

player_flag_clear( flag )
{
	self.flag[ flag ] = 0;
}

player_flag( flag )
{
	if( isDefined( self.flag[ flag ] ) && self.flag[ flag ] )
		return true;
	return false;
}

watchhideredflashingoverlay( overlay )
{
	self endon( "death_or_disconnect" );
	while ( isDefined( overlay ) )
	{
		self waittill( "clear_red_flashing_overlay" );
		self player_flag_clear( "player_has_red_flashing_overlay" );
		overlay fadeovertime( 0.05 );
		overlay.alpha = 0;
		setclientsysstate( "levelNotify", "rfo3", self );
		self notify( "hit_again" );
	}
}

playerhurtcheck()
{
	self endon( "noHealthOverlay" );
	self.hurtagain = 0;
	for ( ;; )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		if ( isDefined( attacker ) && isplayer( attacker ) && attacker.team == self.team )
		{
			continue;
		}
		else
		{
			self.hurtagain = 1;
			self.damagepoint = point;
			self.damageattacker = attacker;
		}
	}
}

realRegen()
{
	while(isAlive( self ))
	{
		if( self.health == self.maxhealth )
			self waittill( "damage", amount, attacker, dir, point, mod );
		while( self player_is_in_laststand() )
			wait .25;
		if(self.hurtagain)
		{
			wait 5;
			self.hurtagain = false;
		}
		self.health += 25;
		if(self.health > self.maxhealth )
			self.health = self.maxhealth;
		self setnormalhealth( self.health );
		wait .5;
	}

}

spectators_respawn()
{
	level endon( "between_round_over" );
	while ( 1 )
	{
		players = get_players();
		i = 0;
		level notify("hotjoinallowed");
		while ( i < players.size )
		{
			if ( players[ i ].sessionstate == "spectator" )
			{
				players[ i ] [[ level.spawnplayer ]]();
				if ( isDefined( level.script ) && level.round_number > 6 && players[ i ].score < 1500 )
				{
					players[ i ].old_score = players[ i ].score;
					if ( isDefined( level.spectator_respawn_custom_score ) )
					{
						players[ i ] [[ level.spectator_respawn_custom_score ]]();
					}
					players[ i ].score = 1500;
				}
			}
			i++;
		}
		wait 1;
	}
}







