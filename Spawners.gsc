spawn_zombie( targetname )
{
	while ( getfreeactorcount() < 1 )
	{
		wait 0.05;
	}
	spawner = getent( "dog_spawner", "targetname" );
	spawner.script_moveoverride = 1;
	guy = spawner spawnactor();
	guy.isbot = true;
	guy.aiweapon = "dog_bite_mp";
	guy enableaimassist();
	guy.aiteam = level.zteam;
	guy.team = level.zteam;
	guy clearentityowner();
	level.zombiemeleeplayercounter = 0;
	guy thread run_spawn_functions();
	spawn = level.spawnpoints[ randomintrange(0, level.spawnpoints.size ) ];
	betterspawn = GetGoodSpawnpoint();
	if( isDefined( betterspawn ) )
		spawn = betterspawn;
	guy forceteleport( spawn.origin );
	guy show();
	spawner.count = 666;
	if ( !spawn_failed( guy ) )
	{
		level.zombie_team = add_to_array(level.zombie_team, guy, 0);
		return guy;
	}
	return undefined;
}

GetGoodSpawnpoint()
{
	spawns = [];
	spawns = array_copy( level.spawnpoints );
	betterspawns = [];
	for( i = 0; i < (level.players.size * 4) && spawns.size > 0; i++ )
	{
		goodSpawn = GetClosest( level.players[ randomintrange( 0, level.players.size ) ] GetOrigin(), spawns );
		betterspawns = add_to_array( betterspawns, goodspawn, 0 );
		arrayremovevalue( spawns, goodspawn );
	}
	return betterspawns[ randomintrange( 0, betterspawns.size ) ];
}

spawn_failed( spawn )
{
	if ( isDefined( spawn ) && isalive( spawn ) )
	{
		if ( isalive( spawn ) )
		{
			return 0;
		}
	}
	return 1;
}

run_custom_ai_spawn_checks()
{
	temp = array_randomize( level.spawnpoints );
	/*
	for( i = 0; i < temp.size; i++ )
	{
		foreach( player in level.players )
		{
			if( (Distance( player getorigin(), temp[i].origin ) < 25) )
			{
				arrayremovevalue( temp, temp[i] );
				i--;
				continue;
			}
		}
		if( Distance( GetClosest(temp[i].origin, level.players), temp[i].origin ) > 1500 )
		{
			arrayremovevalue( temp, temp[i] );
			i--;
			continue;
		}
	}
	*/
	level.current_valid_spawns = temp;
}

run_spawn_functions()
{
	self endon( "death" );
	waittillframeend;
	i = 0;
	self InitZombie();
}

zombie_repath_notifier()
{
	note = 0;
	notes = [];
	i = 0;
	while ( i < 4 )
	{
		notes[ notes.size ] = "zombie_repath_notify_" + i;
		i++;
	}
	while ( 1 )
	{
		level notify( notes[ note ] );
		note = ( note + 1 ) % 4;
		wait 0.05;
	}
}

zombie_follow_enemy()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	self endon( "bad_path" );
	level endon( "intermission" );
	if ( !isDefined( level.repathnotifierstarted ) )
	{
		level.repathnotifierstarted = 1;
		level thread zombie_repath_notifier();
	}
	if ( !isDefined( self.zombie_repath_notify ) )
	{
		self.zombie_repath_notify = "zombie_repath_notify_" + ( self getentitynumber() % 4 );
	}
	while ( 1 )
	{
		if ( !isDefined( self._skip_pathing_first_delay ) )
		{
			level waittill( self.zombie_repath_notify );
		}
		else
		{
			self._skip_pathing_first_delay = undefined;
		}
		if ( isDefined( self.ignore_enemyoverride ) && !self.ignore_enemyoverride && isDefined( self.enemyoverride ) && isDefined( self.enemyoverride[ 1 ] ) )
		{
			if ( distancesquared( self.origin, self.enemyoverride[ 0 ] ) > 1 )
			{
				self orientmode( "face motion" );
			}
			else
			{
				self orientmode( "face point", self.enemyoverride[ 1 ].origin );
			}
			self.ignoreall = 1;
			goalpos = self.enemyoverride[ 0 ];
			if ( isDefined( level.adjust_enemyoverride_func ) )
			{
				goalpos = self [[ level.adjust_enemyoverride_func ]]();
			}
			self setgoalpos( goalpos );
		}
		else
		{
			if ( isDefined( self.favoriteenemy ) )
			{
				self.ignoreall = 0;
				self orientmode( "face default" );
				goalpos = self.favoriteenemy.origin;
				if ( isDefined( level.enemy_location_override_func ) )
				{
					goalpos = [[ level.enemy_location_override_func ]]( self, self.favoriteenemy );
				}
				self setgoalpos( goalpos );
				if ( !isDefined( level.ignore_path_delays ) )
				{
					distsq = distancesquared( self.origin, self.favoriteenemy.origin );
					if ( distsq > 10240000 )
					{
						wait ( 2 + randomfloat( 1 ) );
						break;
					}
					else if ( distsq > 4840000 )
					{
						wait ( 1 + randomfloat( 0.5 ) );
						break;
					}
					else
					{
						if ( distsq > 1440000 )
						{
							wait ( 0.5 + randomfloat( 0.5 ) );
						}
					}
				}
			}
		}
		if ( isDefined( level.inaccesible_player_func ) )
		{
			self [[ level.inaccessible_player_func ]]();
		}
	}
}

zombie_pathing()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	level endon( "intermission" );
	self._skip_pathing_first_delay = 1;
	self thread zombie_follow_enemy();
	self waittill( "bad_path" );
	level.zombie_pathing_failed++;
	if ( isDefined( self.enemyoverride ) )
	{
		if ( isDefined( self.enemyoverride[ 1 ] ) )
		{
			self.enemyoverride = self.enemyoverride[ 1 ] invalidate_attractor_pos( self.enemyoverride, self );
			self.zombie_path_timer = 0;
			return;
		}
	}
	else if ( isDefined( self.favoriteenemy ) )
	{
	}
	else
	{
	}
	if ( !isDefined( self.favoriteenemy ) )
	{
		self.zombie_path_timer = 0;
		return;
	}
	else
	{
		self.favoriteenemy endon( "disconnect" );
	}
	players = get_players();
	valid_player_num = 0;
	i = 0;
	while ( i < players.size )
	{
		if ( is_player_valid( players[ i ], 1 ) )
		{
			valid_player_num += 1;
		}
		i++;
	}
	if ( players.size > 1 )
	{
		if ( isDefined( level._should_skip_ignore_player_logic ) && [[ level._should_skip_ignore_player_logic ]]() )
		{
			self.zombie_path_timer = 0;
			return;
		}
		if ( array_check_for_dupes( self.ignore_player, self.favoriteenemy ) )
		{
			self.ignore_player[ self.ignore_player.size ] = self.favoriteenemy;
		}
		if ( self.ignore_player.size < valid_player_num )
		{
			self.zombie_path_timer = 0;
			return;
		}
	}
	crumb_list = self.favoriteenemy.zombie_breadcrumbs;
	bad_crumbs = [];
	while ( 1 )
	{
		if ( !is_player_valid( self.favoriteenemy, 1 ) )
		{
			self.zombie_path_timer = 0;
			return;
		}
		goal = zombie_pathing_get_breadcrumb( self.favoriteenemy.origin, crumb_list, bad_crumbs, randomint( 100 ) < 20 );
		if ( !isDefined( goal ) )
		{
			level.zombie_breadcrumb_failed++;
			goal = self.favoriteenemy.spectator_respawn.origin;
		}
		self.zombie_path_timer += 100;
		self setgoalpos( goal );
		self waittill( "bad_path" );
		i = 0;
		while ( i < crumb_list.size )
		{
			if ( goal == crumb_list[ i ] )
			{
				bad_crumbs[ bad_crumbs.size ] = i;
				break;
			}
			else
			{
				i++;
			}
		}
	}
}

zombie_pathing_get_breadcrumb( origin, breadcrumbs, bad_crumbs, pick_random )
{
	i = 0;
	while ( i < breadcrumbs.size )
	{
		if ( pick_random )
		{
			crumb_index = randomint( breadcrumbs.size );
		}
		else
		{
			crumb_index = i;
		}
		if ( crumb_is_bad( crumb_index, bad_crumbs ) )
		{
			i++;
			continue;
		}
		else
		{
			return breadcrumbs[ crumb_index ];
		}
		i++;
	}
	return undefined;
}

crumb_is_bad( crumb, bad_crumbs )
{
	i = 0;
	while ( i < bad_crumbs.size )
	{
		if ( bad_crumbs[ i ] == crumb )
		{
			return 1;
		}
		i++;
	}
	return 0;
}












