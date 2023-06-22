zombie_death_event( zombie )
{
	zombie.marked_for_recycle = 0;
	force_explode = 0;
	force_head_gib = 0;
	zombie waittill( "death", attacker );
	time_of_death = getTime();
	if ( isDefined( zombie ) )
	{
		zombie stopsounds();
	}
	if ( isDefined( zombie ) && isDefined( zombie.marked_for_insta_upgraded_death ) )
	{
		force_head_gib = 1;
	}
	if ( !isDefined( zombie.damagehit_origin ) && isDefined( attacker ) )
	{
		zombie.damagehit_origin = attacker getweaponmuzzlepoint();
	}
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		if ( isDefined( zombie ) && isDefined( zombie.damagelocation ) )
		{
			if ( is_headshot( zombie.damageweapon, zombie.damagelocation, zombie.damagemod ) )
			{
				attacker.headshots++;
			}
			else
			{
				attacker notify( "zombie_death_no_headshot" );
			}
		}
		if ( isDefined( zombie ) && isDefined( zombie.damagemod ) && zombie.damagemod == "MOD_MELEE" )
		{
			attacker notify( "melee_kill" );
		}
		attacker.kills++;
		dmgweapon = zombie.damageweapon;
		if ( isDefined( level.pers_upgrade_nube ) && level.pers_upgrade_nube )
		{
			attacker notify( "pers_player_zombie_kill" );
		}
	}
	if ( !isDefined( zombie ) )
	{
		return;
	}
	level.global_zombies_killed++;
	if ( isDefined( zombie.marked_for_death ) && !isDefined( zombie.nuked ) )
	{
		level.zombie_trap_killed_count++;
	}
	zombie check_zombie_death_event_callbacks();
	name = zombie.animname;
	if ( isDefined( zombie.sndname ) )
	{
		name = zombie.sndname;
	}
	level notify( "zom_kill" );
	level.total_zombies_killed++;
}

check_zombie_death_event_callbacks()
{
	if ( !isDefined( level.zombie_death_event_callbacks ) )
	{
		return;
	}
	i = 0;
	while ( i < level.zombie_death_event_callbacks.size )
	{
		self [[ level.zombie_death_event_callbacks[ i ] ]]();
		i++;
	}
}

init_zombie_run_cycle()
{
	self set_zombie_run_cycle();
}

zombie_think()
{
	self endon( "death" );
	self.ai_state = "zombie_think";
}

enemy_death_detection()
{
	self endon( "death" );
	for ( ;; )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		if ( !isDefined( amount ) )
		{
			continue;
		}
		else if ( !isalive( self ) || self.delayeddeath )
		{
			return;
		}
		self.has_been_damaged_by_player = 1;
		self player_attacks_enemy( attacker, amount, type, point );
	}
}

player_attacks_enemy( attacker, amount, type, point )
{
	//todododo
}

bullet_attack( type )
{
	if ( type == "MOD_PISTOL_BULLET" )
	{
		return 1;
	}
	return type == "MOD_RIFLE_BULLET";
}

