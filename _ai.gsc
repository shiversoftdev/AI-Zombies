find_flesh()
{
	self endon( "death" );
	level endon( "intermission" );
	self endon( "stop_find_flesh" );
	self.ai_state = "find_flesh";
	self.helitarget = 1;
	self.ignoreme = 0;
	self.nododgemove = 1;
	self.ignore_player = [];
	self.goalradius = 32;
	if ( isDefined( self.custom_goalradius_override ) )
	{
		self.goalradius = self.custom_goalradius_override;
	}
	while ( 1 )
	{
		zombie_poi = undefined;
		if ( isDefined( level.zombietheaterteleporterseeklogicfunc ) )
		{
			self [[ level.zombietheaterteleporterseeklogicfunc ]]();
		}
		if ( isDefined( level._poi_override ) )
		{
			zombie_poi = self [[ level._poi_override ]]();
		}
		if ( !isDefined( zombie_poi ) )
		{
			zombie_poi = self get_zombie_point_of_interest( self.origin );
		}
		players = get_players();
		if ( !isDefined( self.ignore_player ) || players.size == 1 )
		{
			self.ignore_player = [];
		}
		else
		{
			if ( !isDefined( level._should_skip_ignore_player_logic ) || !( [[ level._should_skip_ignore_player_logic ]]() ) )
			{
				i = 0;
				while ( i < self.ignore_player.size )
				{
					while ( isDefined( self.ignore_player[ i ] ) && isDefined( self.ignore_player[ i ].ignore_counter ) && self.ignore_player[ i ].ignore_counter > 3 )
					{
						self.ignore_player[ i ].ignore_counter = 0;
						self.ignore_player = arrayremovevalue( self.ignore_player, self.ignore_player[ i ] );
						if ( !isDefined( self.ignore_player ) )
						{
							self.ignore_player = [];
						}
						i = 0;
					}
					i++;
				}
			}
		}
		player = get_closest_valid_player( self.origin, self.ignore_player );
		while ( !isDefined( player ) && !isDefined( zombie_poi ) )
		{
			if ( isDefined( self.ignore_player ) )
			{
				while ( isDefined( level._should_skip_ignore_player_logic ) && [[ level._should_skip_ignore_player_logic ]]() )
				{
					wait 1;
				}
				self.ignore_player = [];
			}
			wait 1;
		}
		if ( !isDefined( level.check_for_alternate_poi ) || !( [[ level.check_for_alternate_poi ]]() ) )
		{
			self.enemyoverride = zombie_poi;
			self.favoriteenemy = player;
		}
		self thread zombie_pathing();
		if ( players.size > 1 )
		{
			i = 0;
			while ( i < self.ignore_player.size )
			{
				if ( isDefined( self.ignore_player[ i ] ) )
				{
					if ( !isDefined( self.ignore_player[ i ].ignore_counter ) )
					{
						self.ignore_player[ i ].ignore_counter = 0;
						i++;
						continue;
					}
					else
					{
						self.ignore_player[ i ].ignore_counter += 1;
					}
				}
				i++;
			}
		}
		self thread attractors_generated_listener();
		if ( isDefined( level._zombie_path_timer_override ) )
		{
			self.zombie_path_timer = [[ level._zombie_path_timer_override ]]();
		}
		else
		{
			self.zombie_path_timer = getTime() + ( randomfloatrange( 1, 3 ) * 1000 );
		}
		while ( getTime() < self.zombie_path_timer )
		{
			wait 0.1;
		}
		self notify( "path_timer_done" );
		self notify( "zombie_acquire_enemy" );
	}
}

attractors_generated_listener()
{
	self endon( "death" );
	level endon( "intermission" );
	self endon( "stop_find_flesh" );
	self endon( "path_timer_done" );
	level waittill( "attractor_positions_generated" );
	self.zombie_path_timer = 0;
}

get_closest_valid_player( origin, ignore_player )
{
	valid_player_found = 0;
	players = get_players();
	if ( isDefined( level._zombie_using_humangun ) && level._zombie_using_humangun )
	{
		players = arraycombine( players, level._zombie_human_array, 0, 0 );
	}
	if ( isDefined( ignore_player ) )
	{
		i = 0;
		while ( i < ignore_player.size )
		{
			arrayremovevalue( players, ignore_player[ i ] );
			i++;
		}
	}
	done = 0;
	while ( players.size && !done )
	{
		done = 1;
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			if ( !is_player_valid( player, 1 ) )
			{
				arrayremovevalue( players, player );
				done = 0;
				break;
			}
			else
			{
				i++;
			}
		}
		wait .005;
	}
	if ( players.size == 0 )
	{
		return undefined;
	}
	if ( !valid_player_found )
	{
		if ( isDefined( self.closest_player_override ) )
		{
			player = [[ self.closest_player_override ]]( origin, players );
		}
		else if ( isDefined( level.closest_player_override ) )
		{
			player = [[ level.closest_player_override ]]( origin, players );
		}
		else if ( isDefined( level.calc_closest_player_using_paths ) && level.calc_closest_player_using_paths )
		{
			player = get_closest_player_using_paths( origin, players );
		}
		else
		{
			player = getclosest( origin, players );
		}
		if ( !isDefined( player ) || players.size == 0 )
		{
			return undefined;
		}
		if ( isDefined( level._zombie_using_humangun ) && level._zombie_using_humangun && isai( player ) )
		{
			return player;
		}
		while ( !is_player_valid( player, 1 ) )
		{
			arrayremovevalue( players, player );
			if ( players.size == 0 )
			{
				return undefined;
			}
		}
		return player;
	}
}

is_player_valid( player, checkignoremeflag, ignore_laststand_players )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( isDefined( player.is_zombie ) && player.is_zombie == 1 )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( isDefined( self.intermission ) && self.intermission )
	{
		return 0;
	}
	if ( isDefined( ignore_laststand_players ) && !ignore_laststand_players )
	{
		if ( player player_is_in_laststand() )
		{
			return 0;
		}
	}
	if ( isDefined( checkignoremeflag ) && checkignoremeflag && player.ignoreme )
	{
		return 0;
	}
	if ( isDefined( level.is_player_valid_override ) )
	{
		return [[ level.is_player_valid_override ]]( player );
	}
	return 1;
}


