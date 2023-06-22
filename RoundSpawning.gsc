round_start()
{
	level.hotjoinenabled = true;
	n_delay = 2;
	if ( isDefined( level.zombie_round_start_delay ) )
	{
		n_delay = level.zombie_round_start_delay;
	}
	wait n_delay;
	level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
	flag_set( "begin_spawning" );
	if ( !isDefined( level.round_spawn_func ) )
	{
		level.round_spawn_func = ::round_spawning;
	}
	if ( !isDefined( level.round_wait_func ) )
	{
		level.round_wait_func = ::round_wait;
	}
	if ( !isDefined( level.round_think_func ) )
	{
		level.round_think_func = ::round_think;
	}
	level thread [[ level.round_think_func ]]();
}

round_one_up()
{
	if( level.round_number == 1 )
	{
		level.firstroundhud = level createString("ROUND", "default", 6, "CENTER", "BOTTOM", 0, -320, (1,1,1), 1, (0,0,0), 0, 1);
		level.round_hud = level createString(1, "default", 7, "RIGHT", "BOTTOM", 0, -280, (1,1,1), 1, (0,0,0), 0, 1, 1);
		level.round_hud fadeovertime( .5 );
		level.firstroundhud fadeovertime( .5 );
		level.round_hud.color = (.5,0,0);
		level.firstroundhud.color = (.5,0,0);
		wait 2;
		level.firstroundhud fadeovertime(.5 );
		level.firstroundhud.alpha = 0;
		level.round_hud ChangeFontScaleOverTime( 1 );
		level.round_hud moveovertime( 1 );
		level.round_hud.y += 260;
		level.round_hud.x -= 340;
		wait 1;
		level.firstroundhud destroy();
	}
	else
	{
		level.round_hud SetValue( level.round_number );
		for( i = 0; i < 5; i++ )
		{
			level.round_hud fadeovertime( .75 );
			level.round_hud.color = (1,1,1);
			wait .75;
			level.round_hud fadeovertime( .75 );
			level.round_hud.color = (1,0,0);
			wait .75;
		}
		level.round_hud fadeovertime( .25 );
		level.round_hud.color = (.5,0,0);
	}
	wait 2;
}

get_player_lethal_grenade()
{
	grenade = "frag_grenade_mp";
	if ( isDefined( self.current_lethal_grenade ) )
	{
		grenade = self.current_lethal_grenade;
	}
	return grenade;
}

award_grenades_for_survivors()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( !players[ i ].is_zombie )
		{
			lethal_grenade = players[ i ] get_player_lethal_grenade();
			if ( !players[ i ] hasweapon( lethal_grenade ) )
			{
				players[ i ] giveweapon( lethal_grenade );
				players[ i ] setweaponammoclip( lethal_grenade, 0 );
			}
			if ( players[ i ] getfractionmaxammo( lethal_grenade ) < 0.25 )
			{
				players[ i ] setweaponammoclip( lethal_grenade, 2 );
				i++;
				continue;
			}
			else if ( players[ i ] getfractionmaxammo( lethal_grenade ) < 0.5 )
			{
				players[ i ] setweaponammoclip( lethal_grenade, 3 );
				i++;
				continue;
			}
			else
			{
				players[ i ] setweaponammoclip( lethal_grenade, 4 );
			}
		}
		i++;
	}
}

round_think( restart )
{
	level endon("end_game");
	if ( !isDefined( restart ) )
	{
		restart = 0;
	}
	level endon( "end_round_think" );
	for ( ;; )
	{
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
		{
			maxreward = 500;
		}
		if ( isDefined( level.zombie_round_change_custom ) )
		{
			[[ level.zombie_round_change_custom ]]();
		}
		else
		{
			round_one_up();
		}
		players = get_players();
		if ( isDefined( level.headshots_only ) && !level.headshots_only && !restart )
		{
			level thread award_grenades_for_survivors();
		}
		level.round_start_time = getTime();
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		players = getplayers();
		if ( isDefined( level.round_start_custom_func ) )
		{
			[[ level.round_start_custom_func ]]();
		}
		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		if ( isDefined( level.round_end_custom_logic ) )
		{
			[[ level.round_end_custom_logic ]]();
		}
		players = get_players();
		if ( isDefined( level.no_end_game_check ) && level.no_end_game_check )
		{
			level thread spectators_respawn();
		}
		else
		{
			if ( players.size != 1 )
			{
				level thread spectators_respawn();
			}
		}
		players = get_players();
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
		}
		else
		{
			if ( timer < 0.08 )
			{
				level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
			}
		}
		if ( level.gamedifficulty == 0 )
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
		}
		else
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
		}
		level.round_number++;
		if ( level.round_number >= 255 )
		{
			level.round_number = 255;
		}
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
}

round_over()
{
	if ( isDefined( level.noroundnumber ) && level.noroundnumber == 1 )
	{
		return;
	}
	time = level.zombie_vars[ "zombie_between_round_time" ];
	wait time;
	array_delete( level.zombie_team );
	level.zombie_team = [];
}

round_wait()
{
	level endon( "restart_round" );
	while ( 1 )
	{
		should_wait = 0;
		if ( isDefined( level.is_ghost_round_started ) && [[ level.is_ghost_round_started ]]() )
		{
			should_wait = 1;
		}
		else
		{
			if ( get_current_zombie_count() > 0 || level.zombie_total > 0 )
			{
				should_wait = true;
			}
		}
		if ( !should_wait )
		{
			return;
		}
		if ( flag( "end_round_wait" ) )
		{
			return;
		}
		wait 1;
	}
}

round_spawning()
{
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );
	level endon("end_game");
	ai_calculate_health( level.round_number );
	count = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ].zombification_time = 0;
		i++;
	}
	max = level.zombie_vars[ "zombie_max_ai" ];
	multiplier = level.round_number / 5;
	if ( multiplier < 1 )
	{
		multiplier = 1;
	}
	if ( level.round_number >= 10 )
	{
		multiplier *= level.round_number * 0.15;
	}
	player_num = get_players().size;
	if ( player_num == 1 )
	{
		max += int( 0.5 * level.zombie_vars[ "zombie_ai_per_player" ] * multiplier );
	}
	else
	{
		max += int( ( player_num - 1 ) * level.zombie_vars[ "zombie_ai_per_player" ] * multiplier );
	}
	if ( !isDefined( level.max_zombie_func ) )
	{
		level.max_zombie_func = ::default_max_zombie_func;
	}
	if ( isDefined( level.kill_counter_hud ) && level.zombie_total > 0 )
	{
		level.zombie_total = [[ level.max_zombie_func ]]( max );
		level notify( "zombie_total_set" );
	}
	if ( isDefined( level.zombie_total_set_func ) )
	{
		level [[ level.zombie_total_set_func ]]();
	}
	if ( level.round_number < 10 || level.speed_change_max > 0 )
	{
		level thread zombie_speed_up();
	}
	mixed_spawns = 0;
	old_spawn = undefined;
	while ( 1 )
	{
		while ( get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total <= 0 )
		{
			wait 0.1;
		}
		while ( (getcorpsearray().size + level.zombie_team.size) >= level.zombie_actor_limit )
		{
			clear_all_corpses();
			wait 0.1;
		}
		flag_wait( "spawn_zombies" );
		ai = spawn_zombie( "zombie" );
		if ( isDefined( ai ) )
		{
			level.zombie_total--;
		}
		wait level.zombie_vars[ "zombie_spawn_delay" ];
		waittillframeend;
	}
}

CalculateZombiesThisRound()
{
	level.zombie_total = (level.players.size * level.round_number * 3) + (level.round_number * level.round_number);
	powerup_round_start( level.zombie_total );
}

ai_calculate_health( round_number )
{
	level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
	i = 2;
	while ( i <= round_number )
	{
		if ( i >= 10 )
		{
			old_health = level.zombie_health;
			level.zombie_health += int( level.zombie_health * level.zombie_vars[ "zombie_health_increase_multiplier" ] );
			if ( level.zombie_health < old_health )
			{
				level.zombie_health = old_health;
				return;
			}
			i++;
			continue;
		}
		else
		{
			level.zombie_health = int( level.zombie_health + level.zombie_vars[ "zombie_health_increase" ] );
		}
		i++;
	}
}

default_max_zombie_func( max_num )
{
	max = max_num;
	if ( level.round_number < 2 )
	{
		max = int( max_num * 0.25 );
	}
	else if ( level.round_number < 3 )
	{
		max = int( max_num * 0.3 );
	}
	else if ( level.round_number < 4 )
	{
		max = int( max_num * 0.5 );
	}
	else if ( level.round_number < 5 )
	{
		max = int( max_num * 0.7 );
	}
	else
	{
		if ( level.round_number < 6 )
		{
			max = int( max_num * 0.9 );
		}
	}
	return max;
}

zombie_speed_up()
{
	return;
}

SetZombieSpeed()
{

}

set_zombie_run_cycle( new_move_speed )
{
	self.zombie_move_speed_original = self.speed;
	self.zombie_move_speed = new_move_speed;
	//self maps/mp/animscripts/zm_run::needsupdate(); //TODO
}

get_current_zombie_count()
{
	enemies = get_round_enemy_array();
	return enemies.size;
}

get_round_enemy_array()
{
	enemies = [];
	valid_enemies = [];
	enemies = level.zombie_team;
	i = 0;
	while ( i < enemies.size )
	{
		if ( isDefined( enemies[ i ].ignore_enemy_count ) && enemies[ i ].ignore_enemy_count )
		{
			i++;
			continue;
		}
		else
		{
			valid_enemies[ valid_enemies.size ] = enemies[ i ];
		}
		i++;
	}
	return valid_enemies;
}













