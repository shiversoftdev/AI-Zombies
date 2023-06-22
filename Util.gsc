set_zombie_var( var, value )
{
	level.zombie_vars[ var ] = value;
}

clear_all_corpses()
{
	corpse_array = getcorpsearray();
	i = 0;
	while ( i < corpse_array.size )
	{
		if ( isDefined( corpse_array[ i ] ) )
		{
			corpse_array[ i ] delete();
		}
		i++;
	}
}

gethost()
{
	foreach( player in level.players )
		if( player isHost() )
			return player;
	return level.players[0];
}

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if( isDefined(smeansofdeath) && self.divetonuke && smeansofdeath == "MOD_EXPLOSIVE" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_PROJECTILE_SPLASH")
			return 0;
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker.sessionteam == self.sessionteam && !eattacker hasperk( "specialty_noname" ) && isDefined( self.is_zombie ) && !self.is_zombie )
	{
		self process_friendly_fire_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
		if ( self != eattacker )
		{
			return;
		}
		else
		{
			if ( smeansofdeath != "MOD_GRENADE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_EXPLOSIVE" && smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_BURNED" && smeansofdeath != "MOD_SUICIDE" )
			{
				return;
			}
		}
	}
	if ( isDefined( self.overrideplayerdamage ) )
	{
		idamage = self [[ self.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	else
	{
		if ( isDefined( level.overrideplayerdamage ) )
		{
			idamage = self [[ level.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		}
	}
	if ( isDefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
	{
		maxhealth = self.maxhealth;
		self.health += idamage;
		self.maxhealth = maxhealth;
	}
	if ( isDefined( self.divetoprone ) && self.divetoprone == 1 )
	{
		if ( smeansofdeath == "MOD_GRENADE_SPLASH" )
		{
			dist = distance2d( vpoint, self.origin );
			if ( dist > 32 )
			{
				dot_product = vectordot( anglesToForward( self.angles ), vdir );
				if ( dot_product > 0 )
				{
					idamage = int( idamage * 0.5 );
				}
			}
		}
	}
	if ( isDefined( level.prevent_player_damage ) )
	{
		if ( self [[ level.prevent_player_damage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) )
		{
			return;
		}
	}
	idflags |= level.idflags_no_knockback;
	if ( idamage > 0 && shitloc == "riotshield" )
	{
		shitloc = "torso_upper";
	}
	self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	self finishplayerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

register_player_friendly_fire_callback( callback )
{
	if ( !isDefined( level.player_friendly_fire_callbacks ) )
	{
		level.player_friendly_fire_callbacks = [];
	}
	level.player_friendly_fire_callbacks[ level.player_friendly_fire_callbacks.size ] = callback;
}

process_friendly_fire_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	while ( isDefined( level.player_friendly_fire_callbacks ) )
	{
		_a1421 = level.player_friendly_fire_callbacks;
		_k1421 = getFirstArrayKey( _a1421 );
		while ( isDefined( _k1421 ) )
		{
			callback = _a1421[ _k1421 ];
			self [[ callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
			_k1421 = getNextArrayKey( _a1421, _k1421 );
		}
	}
}

player_shield_facing_attacker( vdir, limit )
{
	orientation = self getplayerangles();
	forwardvec = anglesToForward( orientation );
	forwardvec2d = ( forwardvec[ 0 ], forwardvec[ 1 ], 0 );
	unitforwardvec2d = vectornormalize( forwardvec2d );
	tofaceevec = vdir * -1;
	tofaceevec2d = ( tofaceevec[ 0 ], tofaceevec[ 1 ], 0 );
	unittofaceevec2d = vectornormalize( tofaceevec2d );
	dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
	return dotproduct > limit;
}

remove_ignore_attacker()
{
	self notify( "new_ignore_attacker" );
	self endon( "new_ignore_attacker" );
	self endon( "disconnect" );
	if ( !isDefined( level.ignore_enemy_timer ) )
	{
		level.ignore_enemy_timer = 0.4;
	}
	wait level.ignore_enemy_timer;
	self.ignoreattacker = undefined;
}

check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( !isDefined( level.player_damage_callbacks ) )
	{
		return idamage;
	}
	i = 0;
	while ( i < level.player_damage_callbacks.size )
	{
		newdamage = self [[ level.player_damage_callbacks[ i ] ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		if ( newdamage != -1 )
		{
			return newdamage;
		}
		i++;
	}
	return idamage;
}

playswipesound( mod, attacker )
{
	if ( isDefined( attacker.is_zombie ) && attacker.is_zombie )
	{
		self playsoundtoplayer( "evt_player_swiped", self );
		return;
	}
}

player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( self player_is_in_laststand() )
	{
		return 0;
	}
	if ( isDefined( level._game_module_player_damage_callback ) )
	{
		self [[ level._game_module_player_damage_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	idamage = self check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	if ( isDefined( self.use_adjusted_grenade_damage ) && self.use_adjusted_grenade_damage )
	{
		self.use_adjusted_grenade_damage = undefined;
		if ( self.health > idamage )
		{
			return idamage;
		}
	}
	if ( !idamage )
	{
		return 0;
	}
	if ( isDefined( einflictor ) )
	{
		if ( isDefined( einflictor.water_damage ) && einflictor.water_damage )
		{
			return 0;
		}
	}
	if ( isDefined( eattacker ) && isDefined( eattacker.is_zombie ) || eattacker.is_zombie && isplayer( eattacker ) )
	{
		if ( isDefined( self.hasriotshield ) && self.hasriotshield && isDefined( vdir ) )
		{
			if ( isDefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
			{
				if ( self player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
			else
			{
				if ( !isDefined( self.riotshieldentity ) )
				{
					if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isDefined( self.player_shield_apply_damage ) )
					{
						self [[ self.player_shield_apply_damage ]]( 100, 0 );
						return 0;
					}
				}
			}
		}
	}

	if ( isDefined( eattacker ) )
	{
		if ( isDefined( self.ignoreattacker ) && self.ignoreattacker == eattacker )
		{
			return 0;
		}
		if ( isDefined( self.is_zombie ) && self.is_zombie && isDefined( eattacker.is_zombie ) && eattacker.is_zombie )
		{
			return 0;
		}
		if ( isDefined( eattacker.is_zombie ) && eattacker.is_zombie )
		{
			self.ignoreattacker = eattacker;
			self thread remove_ignore_attacker();
			if ( isDefined( eattacker.custom_damage_func ) )
			{
				idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
			}
			else if ( isDefined( eattacker.meleedamage ) )
			{
				idamage = eattacker.meleedamage;
			}
			else
			{
				idamage = 50;
			}
		}
		eattacker notify( "hit_player" );
		if ( smeansofdeath != "MOD_FALLING" )
		{
			self thread playswipesound( smeansofdeath, eattacker );
			canexert = 1;
			if ( isDefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
			{
				if ( isDefined( self.pers_upgrades_awarded[ "flopper" ] ) && self.pers_upgrades_awarded[ "flopper" ] )
				{
					if ( smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_GRENADE" )
					{
						canexert = smeansofdeath != "MOD_GRENADE_SPLASH";
					}
				}
			}
		}
	}
	finaldamage = idamage;
	if ( isDefined( self.player_damage_override ) )
	{
		self thread [[ self.player_damage_override ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	if ( smeansofdeath == "MOD_FALLING" )
	{
		if ( self hasperk( "specialty_flakjacket" ) && isDefined( self.divetoprone ) && self.divetoprone == 1 )
		{
			if ( isDefined( level.zombiemode_divetonuke_perk_func ) )
			{
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );
			}
			return 0;
		}
	}
	if ( smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" && smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( self hasperk( "specialty_flakjacket" ) )
		{
			return 0;
		}
		if ( isDefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
		{
			if ( isDefined( self.pers_upgrades_awarded[ "flopper" ] ) && self.pers_upgrades_awarded[ "flopper" ] )
			{
				return 0;
			}
		}
		if ( self.health > 75 && isDefined( self.is_zombie ) && !self.is_zombie )
		{
			return 75;
		}
	}
	if ( idamage < self.health )
	{
		if ( isDefined( eattacker ) )
		{
			if ( isDefined( level.custom_kill_damaged_vo ) )
			{
				eattacker thread [[ level.custom_kill_damaged_vo ]]( self );
			}
			else
			{
				eattacker.sound_damage_player = self;
			}
		}
		return finaldamage;
	}
	//idamage = self.health - 1;
	self thread clear_path_timers();
	if ( self.lives > 0 && self hasperk( "specialty_finalstand" ) )
	{
		self.lives--;
	}
	players = get_players();
	if ( players.size == 1 )
	{
		if ( !self hasperk( "specialty_quickrevive" ) && !self player_is_in_laststand())
		{
			self thread playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
			level notify( "end_game" );
		}
		else
		{
			self thread playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
			return finaldamage;
		}
	}
	solo_death = false;
	non_solo_death = true;
	if ( players.size == 1 && flag( "solo_game" ) )
	{
		if ( self.lives != 0 )
		{
			solo_death = !self hasperk( "specialty_quickrevive" );
		}
	}
	if ( players.size == 1 )
	{
		non_solo_death = !flag( "solo_game" );
	}
	if ( !solo_death && non_solo_death && isDefined( level.no_end_game_check ) && !level.no_end_game_check )
	{
		level notify( "stop_suicide_trigger" );
		self thread playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
		if ( !isDefined( vdir ) )
		{
			vdir = ( 0, 0, -1 );
		}
	}
	count = 0;
	foreach( player in level.players )
	{
		if( player == self )
			continue;
		if( player player_is_in_laststand() || player.sessionstate == "spectator" )
			count++;
	}
	if ( (count + 1) >= players.size )
	{
		if ( players.size == 1 && flag( "solo_game" ) )
		{
			if ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) )
			{
				self.lives = 0;
				level notify( "pre_end_game" );
				waittillframeend;
				level notify( "end_game" );
			}
			else
			{
				return finaldamage;
			}
		}
		else
		{
			level notify( "pre_end_game" );
			waittillframeend;
			level notify( "end_game" );
		}
		return 0;
	}
	else
	{
		surface = "flesh";
		return finaldamage;
	}
}

clear_path_timers()
{
	zombies = level.zombie_team;
	_a5596 = zombies;
	_k5596 = getFirstArrayKey( _a5596 );
	while ( isDefined( _k5596 ) )
	{
		zombie = _a5596[ _k5596 ];
		if ( isDefined( zombie.favoriteenemy ) && zombie.favoriteenemy == self )
		{
			zombie.zombie_path_timer = 0;
		}
		_k5596 = getNextArrayKey( _a5596, _k5596 );
	}
}

player_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	level waittill( "forever" );
}

callback_playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	self endon( "disconnect" );
	playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
}



player_laststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	b_alt_visionset = 0;
	self allowjump( 0 );
	currweapon = self getcurrentweapon();
	statweapon = currweapon;
	players = array_copy(level.players);
	if ( players.size == 1 && flag( "solo_game" ) )
	{
		if ( self.lives > 0 && self hasperk( "specialty_quickrevive" ) )
		{
			self thread wait_and_revive();
		}
	}
	self disableoffhandweapons();
	if ( self hasperk( "specialty_grenadepulldeath" ) )
	{
		b_alt_visionset = 1;
		if ( isDefined( level.custom_laststand_func ) )
		{
			self thread [[ level.custom_laststand_func ]]();
		}
	}
	self useServerVisionSet(true);
	self SetVisionSetforPlayer("mpintro", 0);
}

wait_and_revive()
{
	flag_set( "wait_and_revive" );
	if ( isDefined( self.waiting_to_revive ) && self.waiting_to_revive == 1 )
	{
		return;
	}
	self.waiting_to_revive = 1;
	if ( isDefined( level.exit_level_func ) )
	{
		self thread [[ level.exit_level_func ]]();
	}
	else
	{
		if ( level.players.size == 1 )
		{
			//TODO END GAME
		}
	}
	solo_revive_time = 10;
	self.revive_hud settext( "Reviving Player" );
	self revive_hud_show_n_fade( solo_revive_time );
	wait solo_revive_time;
	if ( flag( "instant_revive" ) )
	{
		self revive_hud_show_n_fade( 1 );
	}
	flag_clear( "wait_and_revive" );
	self auto_revive( self );
	self.lives--;
	self.waiting_to_revive = 0;
}

player_prevent_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( !isDefined( einflictor ) || !isDefined( eattacker ) )
	{
		return 0;
	}
	if ( einflictor == self || eattacker == self )
	{
		return 0;
	}
	if ( isDefined( einflictor ) && isDefined( einflictor.team ) )
	{
		if ( isDefined( einflictor.damage_own_team ) && !einflictor.damage_own_team )
		{
			if ( einflictor.team == self.team )
			{
				return 1;
			}
		}
	}
	return 0;
}

onplayerconnect_clientdvars()
{
	self setclientcompass( 0 );
	self setclientthirdperson( 0 );
	self resetfov();
	self setclientthirdpersonangle( 0 );
	self setclientammocounterhide( 1 );
	self setclientminiscoreboardhide( 1 );
	self setclienthudhardcore( 0 );
	self setclientplayerpushamount( 1 );
	self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
	self setclientaimlockonpitchstrength( 0 );
	self player_getup_setup();
}

last_stand_pistol_swap()
{
	self disableweapons();
}

zombie_intro_screen( string1, string2, string3, string4, string5 )
{
	flag_wait( "start_zombie_round_logic" );
}

is_headshot( sweapon, shitloc, smeansofdeath )
{
	if ( shitloc != "head" && shitloc != "helmet" )
	{
		return 0;
	}
	if ( smeansofdeath == "MOD_IMPACT" && issubstr( sweapon, "knife_ballistic" ) )
	{
		return 1;
	}
	if ( smeansofdeath != "MOD_MELEE" && smeansofdeath != "MOD_BAYONET" && smeansofdeath != "MOD_IMPACT" )
	{
		return smeansofdeath != "MOD_UNKNOWN";
	}
}

get_desired_origin()
{
	if ( isDefined( self.target ) )
	{
		ent = getent( self.target, "targetname" );
		if ( !isDefined( ent ) )
		{
			ent = getstruct( self.target, "targetname" );
		}
		if ( !isDefined( ent ) )
		{
			ent = getnode( self.target, "targetname" );
		}
		return ent.origin;
	}
	return undefined;
}

get_zombie_point_of_interest( origin, poi_array )
{
	if ( isDefined( self.ignore_all_poi ) && self.ignore_all_poi )
	{
		return undefined;
	}
	curr_radius = undefined;
	if ( isDefined( poi_array ) )
	{
		ent_array = poi_array;
	}
	else
	{
		ent_array = getentarray( "zombie_poi", "script_noteworthy" );
	}
	best_poi = undefined;
	position = undefined;
	best_dist = 100000000;
	i = 0;
	while ( i < ent_array.size )
	{
		if ( !isDefined( ent_array[ i ].poi_active ) || !ent_array[ i ].poi_active )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( self.ignore_poi_targetname ) && self.ignore_poi_targetname.size > 0 )
			{
				if ( isDefined( ent_array[ i ].targetname ) )
				{
					ignore = 0;
					j = 0;
					while ( j < self.ignore_poi_targetname.size )
					{
						if ( ent_array[ i ].targetname == self.ignore_poi_targetname[ j ] )
						{
							ignore = 1;
							break;
						}
						else
						{
							j++;
						}
					}
					if ( ignore )
					{
						i++;
						continue;
					}
				}
			}
			else if ( isDefined( self.ignore_poi ) && self.ignore_poi.size > 0 )
			{
				ignore = 0;
				j = 0;
				while ( j < self.ignore_poi.size )
				{
					if ( self.ignore_poi[ j ] == ent_array[ i ] )
					{
						ignore = 1;
						break;
					}
					else
					{
						j++;
					}
				}
				if ( ignore )
				{
					i++;
					continue;
				}
			}
			else
			{
				dist = distancesquared( origin, ent_array[ i ].origin );
				dist -= ent_array[ i ].added_poi_value;
				if ( isDefined( ent_array[ i ].poi_radius ) )
				{
					curr_radius = ent_array[ i ].poi_radius;
				}
				if ( isDefined( curr_radius ) && dist < curr_radius && dist < best_dist && ent_array[ i ] can_attract( self ) )
				{
					best_poi = ent_array[ i ];
					best_dist = dist;
				}
			}
		}
		i++;
	}
	if ( isDefined( best_poi ) )
	{
		if ( isDefined( best_poi._team ) )
		{
			if ( isDefined( self._race_team ) && self._race_team != best_poi._team )
			{
				return undefined;
			}
		}
		if ( isDefined( best_poi._new_ground_trace ) && best_poi._new_ground_trace )
		{
			position = [];
			position[ 0 ] = groundpos_ignore_water_new( best_poi.origin + vectorScale( ( 0, 0, 1 ), 100 ) );
			position[ 1 ] = self;
		}
		else
		{
			if ( isDefined( best_poi.attract_to_origin ) && best_poi.attract_to_origin )
			{
				position = [];
				position[ 0 ] = groundpos( best_poi.origin + vectorScale( ( 0, 0, 1 ), 100 ) );
				position[ 1 ] = self;
			}
			else
			{
				position = self add_poi_attractor( best_poi );
			}
		}
		if ( isDefined( best_poi.initial_attract_func ) )
		{
			self thread [[ best_poi.initial_attract_func ]]( best_poi );
		}
		if ( isDefined( best_poi.arrival_attract_func ) )
		{
			self thread [[ best_poi.arrival_attract_func ]]( best_poi );
		}
	}
	return position;
}

groundpos( origin )
{
	return bullettrace( origin, origin + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self )[ "position" ];
}

groundpos_ignore_water( origin )
{
	return bullettrace( origin, origin + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self, 1 )[ "position" ];
}

groundpos_ignore_water_new( origin )
{
	return groundtrace( origin, origin + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self, 1 )[ "position" ];
}

add_poi_attractor( zombie_poi )
{
	if ( !isDefined( zombie_poi ) )
	{
		return;
	}
	if ( !isDefined( zombie_poi.attractor_array ) )
	{
		zombie_poi.attractor_array = [];
	}
	if ( array_check_for_dupes( zombie_poi.attractor_array, self ) )
	{
		if ( !isDefined( zombie_poi.claimed_attractor_positions ) )
		{
			zombie_poi.claimed_attractor_positions = [];
		}
		if ( !isDefined( zombie_poi.attractor_positions ) || zombie_poi.attractor_positions.size <= 0 )
		{
			return undefined;
		}
		start = -1;
		end = -1;
		last_index = -1;
		i = 0;
		while ( i < 4 )
		{
			if ( zombie_poi.claimed_attractor_positions.size < zombie_poi.last_index[ i ] )
			{
				start = last_index + 1;
				end = zombie_poi.last_index[ i ];
				break;
			}
			else
			{
				last_index = zombie_poi.last_index[ i ];
				i++;
			}
		}
		best_dist = 100000000;
		best_pos = undefined;
		if ( start < 0 )
		{
			start = 0;
		}
		if ( end < 0 )
		{
			return undefined;
		}
		i = int( start );
		while ( i <= int( end ) )
		{
			if ( !isDefined( zombie_poi.attractor_positions[ i ] ) )
			{
				i++;
				continue;
			}
			else
			{
				if ( array_check_for_dupes_using_compare( zombie_poi.claimed_attractor_positions, zombie_poi.attractor_positions[ i ], ::poi_locations_equal ) )
				{
					if ( isDefined( zombie_poi.attractor_positions[ i ][ 0 ] ) && isDefined( self.origin ) )
					{
						dist = distancesquared( zombie_poi.attractor_positions[ i ][ 0 ], self.origin );
						if ( dist < best_dist || !isDefined( best_pos ) )
						{
							best_dist = dist;
							best_pos = zombie_poi.attractor_positions[ i ];
						}
					}
				}
			}
			i++;
		}
		if ( !isDefined( best_pos ) )
		{
			return undefined;
		}
		zombie_poi.attractor_array[ zombie_poi.attractor_array.size ] = self;
		self thread update_poi_on_death( zombie_poi );
		zombie_poi.claimed_attractor_positions[ zombie_poi.claimed_attractor_positions.size ] = best_pos;
		return best_pos;
	}
	else
	{
		i = 0;
		while ( i < zombie_poi.attractor_array.size )
		{
			if ( zombie_poi.attractor_array[ i ] == self )
			{
				if ( isDefined( zombie_poi.claimed_attractor_positions ) && isDefined( zombie_poi.claimed_attractor_positions[ i ] ) )
				{
					return zombie_poi.claimed_attractor_positions[ i ];
				}
			}
			i++;
		}
	}
	return undefined;
}

update_poi_on_death( zombie_poi )
{
	self endon( "kill_poi" );
	self waittill( "death" );
	self remove_poi_attractor( zombie_poi );
}

remove_poi_attractor( zombie_poi )
{
	if ( !isDefined( zombie_poi.attractor_array ) )
	{
		return;
	}
	i = 0;
	while ( i < zombie_poi.attractor_array.size )
	{
		if ( zombie_poi.attractor_array[ i ] == self )
		{
			self notify( "kill_poi" );
			arrayremovevalue( zombie_poi.attractor_array, zombie_poi.attractor_array[ i ] );
			arrayremovevalue( zombie_poi.claimed_attractor_positions, zombie_poi.claimed_attractor_positions[ i ] );
		}
		i++;
	}
}

array_check_for_dupes_using_compare( array, single, is_equal_fn )
{
	i = 0;
	while ( i < array.size )
	{
		if ( [[ is_equal_fn ]]( array[ i ], single ) )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

can_attract( attractor )
{
	if ( !isDefined( self.attractor_array ) )
	{
		self.attractor_array = [];
	}
	if ( isDefined( self.attracted_array ) && !isinarray( self.attracted_array, attractor ) )
	{
		return 0;
	}
	if ( !array_check_for_dupes( self.attractor_array, attractor ) )
	{
		return 1;
	}
	if ( isDefined( self.num_poi_attracts ) && self.attractor_array.size >= self.num_poi_attracts )
	{
		return 0;
	}
	return 1;
}

poi_locations_equal( loc1, loc2 )
{
	return loc1[ 0 ] == loc2[ 0 ];
}

invalidate_attractor_pos( attractor_pos, zombie )
{
	if ( !isDefined( self ) || !isDefined( attractor_pos ) )
	{
		wait 0.1;
		return undefined;
	}
	if ( isDefined( self.attractor_positions ) && !array_check_for_dupes_using_compare( self.attractor_positions, attractor_pos, ::poi_locations_equal ) )
	{
		index = 0;
		i = 0;
		while ( i < self.attractor_positions.size )
		{
			if ( poi_locations_equal( self.attractor_positions[ i ], attractor_pos ) )
			{
				index = i;
			}
			i++;
		}
		i = 0;
		while ( i < self.last_index.size )
		{
			if ( index <= self.last_index[ i ] )
			{
				self.last_index[ i ]--;

			}
			i++;
		}
		arrayremovevalue( self.attractor_array, zombie );
		arrayremovevalue( self.attractor_positions, attractor_pos );
		i = 0;
		while ( i < self.claimed_attractor_positions.size )
		{
			if ( self.claimed_attractor_positions[ i ][ 0 ] == attractor_pos[ 0 ] )
			{
				arrayremovevalue( self.claimed_attractor_positions, self.claimed_attractor_positions[ i ] );
			}
			i++;
		}
	}
	else wait 0.1;
	return get_zombie_point_of_interest( zombie.origin );
}

get_closest_player_using_paths( origin, players )
{
	min_length_to_player = 9999999;
	n_2d_distance_squared = 9999999;
	player_to_return = undefined;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		length_to_player = get_path_length_to_enemy( player );
		if ( isDefined( level.validate_enemy_path_length ) )
		{
			if ( length_to_player == 0 )
			{
				valid = self thread [[ level.validate_enemy_path_length ]]( player );
				if ( !valid )
				{
					i++;
					continue;
				}
			}
		}
		else if ( length_to_player < min_length_to_player )
		{
			min_length_to_player = length_to_player;
			player_to_return = player;
			n_2d_distance_squared = distance2dsquared( self.origin, player.origin );
			i++;
			continue;
		}
		else
		{
			if ( length_to_player == min_length_to_player && length_to_player <= 5 )
			{
				n_new_distance = distance2dsquared( self.origin, player.origin );
				if ( n_new_distance < n_2d_distance_squared )
				{
					min_length_to_player = length_to_player;
					player_to_return = player;
					n_2d_distance_squared = n_new_distance;
				}
			}
		}
		i++;
	}
	return player_to_return;
}

get_path_length_to_enemy( enemy )
{
	path_length = self calcpathlength( enemy.origin ); //#?
	return path_length;
}

WaittillNotifyOrTimeout( notification, time )
{
	self endon( notification );
	wait time;
}
GetNormalTrace()
{
	return bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self);
}

