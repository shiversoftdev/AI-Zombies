laststand_disable_player_weapons()
{
	weaponinventory = self getweaponslist( 1 );
	self.lastactiveweapon = self getcurrentweapon();
	if ( self isthrowinggrenade() )
	{
		primaryweapons = self getweaponslistprimaries();
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self.lastactiveweapon = primaryweapons[ 0 ];
			self switchtoweaponimmediate( self.lastactiveweapon );
		}
	}
	self.laststandpistol = undefined;
	self.hadpistol = 0;
	if ( isDefined( self.weapon_taken_by_losing_specialty_additionalprimaryweapon ) && self.lastactiveweapon == self.weapon_taken_by_losing_specialty_additionalprimaryweapon )
	{
		self.lastactiveweapon = "none";
		self.weapon_taken_by_losing_specialty_additionalprimaryweapon = undefined;
	}
	i = 0;
	while ( i < weaponinventory.size )
	{
		weapon = weaponinventory[ i ];
		class = weaponclass( weapon );
		if ( issubstr( weapon, "knife_ballistic_" ) )
		{
			class = "knife";
		}
		if ( class != "pistol" && class != "pistol spread" && class == "pistolspread" && !isDefined( self.laststandpistol ) )
		{
			self.laststandpistol = weapon;
			self.hadpistol = 1;
		}
		i++;
	}
	if ( isDefined( self.hadpistol ) && self.hadpistol == 1 && isDefined( level.zombie_last_stand_pistol_memory ) )
	{
		self [[ level.zombie_last_stand_pistol_memory ]]();
	}
	if ( !isDefined( self.laststandpistol ) )
	{
		self.laststandpistol = level.laststandpistol;
	}
	self disableweaponcycling();
	self notify( "weapons_taken_for_last_stand" );
}

playerlaststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	quickrevive = self hasperk("specialty_quickrevive");
	self notify( "entering_last_stand" );
	self.perk_array = [];
	if ( self player_is_in_laststand() )
	{
		return;
	}
	self.pers[ "downs" ]++;
	self.downs++;
	self thread ClearPerkHud();
	self.health = 120;
	self.maxhealth = 120;
	self.laststand = 1;
	self.ignoreme = 1;
	self freezecontrolsallowlook(true);
	if( (level.players.size == 1) && quickrevive)
	{
		self notify( "player_downed" );
		self.revivetrigger = "";
		self setstance("prone");
		self setlowermessage("Reviving Player...");
		wait .25;
		self clearlowermessage( 5 );
		wait 4.75;
		foreach( zombie in level.zombie_team )
		{
			if( Distance( zombie getorigin(), self getorigin() ) < 1250 )
			{
				zombie.thunderwall = 1;
				zombie dodamage( zombie.health + 1, zombie GetOrigin() );
			}
		}
		self notify("player_revived");
		self.laststand = undefined;
		self.revivetrigger = undefined;
		self allowjump( 1 );
		self setstance("stand");
		self thread revive_success( self );
		self Enableweapons();
		return;
	}
	self revive_trigger_spawn();
	self setstance("prone");
	self thread laststand_bleedout( 45 );
	self notify( "player_downed" );
}

cleanup_laststand_on_disconnect()
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "bled_out" );
	trig = self.revivetrigger;
	self waittill( "disconnect" );
	if ( isDefined( trig ) )
	{
		trig delete();
	}
}

refire_player_downed()
{
	self endon( "player_revived" );
	self endon( "death" );
	self endon( "disconnect" );
	wait 1;
	if ( self.num_perks )
	{
		self notify( "player_downed" );
	}
}

laststand_bleedout( delay )
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "zombified" );
	self endon( "disconnect" );
	setclientsysstate( "lsm", "1", self );
	wait delay;
	while ( isDefined( self.revivetrigger ) )
	{
		wait 0.1;
	}
	self notify( "bled_out" );
	waittillframeend;
	self bleed_out();
}

bleed_out()
{
	if ( isDefined( self.revivetrigger ) )
	{
		self.revivetrigger delete();
	}
	self.revivetrigger = undefined;
	self.laststand = undefined;
	setclientsysstate( "lsm", "0", self );
	level notify( "bleed_out" );
	self undolaststand();
	self freezecontrolsallowlook(false);
	self thread [[ level.spawnspectator ]]();
}

laststand_getup_hud()
{
	self endon( "player_revived" );
	self endon( "disconnect" );
	hudelem = newclienthudelem( self );
	hudelem.alignx = "left";
	hudelem.aligny = "middle";
	hudelem.horzalign = "left";
	hudelem.vertalign = "middle";
	hudelem.x = 5;
	hudelem.y = 170;
	hudelem.font = "big";
	hudelem.fontscale = 1.5;
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = 1;
	hudelem.hidewhendead = 1;
	hudelem.sort = 2;
	hudelem.label = &"SO_WAR_LASTSTAND_GETUP_BAR";
	self thread laststand_getup_hud_destroy( hudelem );
	while ( 1 )
	{
		hudelem setvalue( self.laststand_info.getup_bar_value );
		wait 0.05;
	}
}

laststand_getup_hud_destroy( hudelem )
{
	self waittill_any( "player_revived", "disconnect" );
	hudelem destroy();
}

laststand_getup_damage_watcher()
{
	self endon( "player_revived" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "damage" );
		self.laststand_info.getup_bar_value -= level.const_laststand_getup_bar_damage;
		if ( self.laststand_info.getup_bar_value < 0 )
		{
			self.laststand_info.getup_bar_value = 0;
		}
	}
}

laststand_getup()
{
	self endon( "player_revived" );
	self endon( "disconnect" );
	setclientsysstate( "lsm", "1", self );
	self.laststand_info.getup_bar_value = level.const_laststand_getup_bar_start;
	self thread laststand_getup_hud();
	self thread laststand_getup_damage_watcher();
	while ( self.laststand_info.getup_bar_value < 1 )
	{
		self.laststand_info.getup_bar_value += level.const_laststand_getup_bar_regen;
		wait 0.05;
	}
	self auto_revive( self );
	setclientsysstate( "lsm", "0", self );
}

laststand_give_pistol()
{
	self giveweapon( self.laststandpistol );
	self givemaxammo( self.laststandpistol );
	self switchtoweapon( self.laststandpistol );
}

player_is_in_laststand()
{
	if ( isDefined( self.no_revive_trigger ) && !self.no_revive_trigger )
	{
		return isDefined( self.revivetrigger );
	}
	else
	{
		if ( isDefined( self.laststand ) )
		{
			return self.laststand;
		}
	}
	return false;
}

revive_hud_show_n_fade( time )
{
	revive_hud_show();
	self.revive_hud fadeovertime( time );
	self.revive_hud.alpha = 0;
}

auto_revive( reviver, dont_enable_weapons )
{
	if ( isDefined( self.revivetrigger ) )
	{
		self.revivetrigger.auto_revive = 1;
		while ( self.revivetrigger.beingrevived == 1 )
		{
			while ( 1 )
			{
				if ( self.revivetrigger.beingrevived == 0 )
				{
					break;
				}
				else
				{
					waittillframeend;
				}
			}
		}
		self.revivetrigger.auto_trigger = 0;
	}
	self reviveplayer();
	self freezecontrolsallowlook(false);
	setclientsysstate( "lsm", "0", self );
	player useServerVisionSet(true);
	player SetVisionSetforPlayer("remote_mortar_enhanced", 0);
	self notify( "stop_revive_trigger" );
	if ( isDefined( self.revivetrigger ) )
	{
		self.revivetrigger delete();
		self.revivetrigger = undefined;
	}
	if ( !isDefined( dont_enable_weapons ) || dont_enable_weapons == 0 )
	{
		self laststand_enable_player_weapons();
	}
	self allowjump( 1 );
	self.ignoreme = 0;
	self.laststand = undefined;
	if ( isDefined( level.isresetting_grief ) && !level.isresetting_grief )
	{
		reviver.revives++;
	}
	self notify( "player_revived" );
}

player_getup_setup()
{
	self.laststand_info = spawnstruct();
	self.laststand_info.type_getup_lives = level.const_laststand_getup_count_start;
}

revive_hud_create()
{
	self.revive_hud = newclienthudelem( self );
	self.revive_hud.alignx = "center";
	self.revive_hud.aligny = "middle";
	self.revive_hud.horzalign = "center";
	self.revive_hud.vertalign = "bottom";
	self.revive_hud.foreground = 1;
	self.revive_hud.font = "default";
	self.revive_hud.fontscale = 1.5;
	self.revive_hud.alpha = 0;
	self.revive_hud.color = ( 1, 1, 1 );
	self.revive_hud.hidewheninmenu = 1;
	self.revive_hud settext( "" );
	self.revive_hud.y = -160;
}

_laststand_init()
{
	laststand_global_init();
	level.revive_tool = "knife_held_mp";
	precacheitem( level.revive_tool );
	precachestring( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
	precachestring( &"ZOMBIE_PLAYER_NEEDS_TO_BE_REVIVED" );
	precachestring( &"ZOMBIE_PLAYER_IS_REVIVING_YOU" );
	precachestring( &"ZOMBIE_REVIVING" );
	level thread revive_hud_think();
	level.primaryprogressbarx = 0;
	level.primaryprogressbary = 110;
	level.primaryprogressbarheight = 4;
	level.primaryprogressbarwidth = 120;
	level.primaryprogressbary_ss = 280;
	if ( getDvar( "revive_trigger_radius" ) == "" )
	{
		setdvar( "revive_trigger_radius", "40" );
	}
	level.laststandgetupallowed = 0;
}

laststand_global_init()
{
	level.const_laststand_getup_count_start = 0;
	level.const_laststand_getup_bar_start = 0.5;
	level.const_laststand_getup_bar_regen = 0.0025;
	level.const_laststand_getup_bar_damage = 0.1;
}

player_num_in_laststand()
{
	num = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] player_is_in_laststand() )
		{
			num++;
		}
		i++;
	}
	return num;
}

player_all_players_in_laststand()
{
	return player_num_in_laststand() == get_players().size;

}

player_any_player_in_laststand()
{
	return player_num_in_laststand() > 0;

}

revive_hud_think()
{
/*
	self endon( "disconnect" );
	while ( 1 )
	{
		wait 0.1;
		while ( !player_any_player_in_laststand() )
		{
			continue;
		}
		players = get_players();
		playertorevive = undefined;
		i = 0;
		while ( i < players.size )
		{
			if ( !isDefined( players[ i ].revivetrigger ) || !isDefined( players[ i ].revivetrigger.createtime ) )
			{
				i++;
				continue;
			}
			else
			{
				if ( !isDefined( playertorevive ) || playertorevive.revivetrigger.createtime > players[ i ].revivetrigger.createtime )
				{
					playertorevive = players[ i ];
				}
			}
			i++;
		}
		if ( isDefined( playertorevive ) )
		{
			i = 0;
			while ( i < players.size )
			{
				if ( players[ i ] player_is_in_laststand() )
				{
					i++;
					continue;
				}
				else if ( getDvar( "g_gametype" ) == "vs" )
				{
					if ( players[ i ].team != playertorevive.team )
					{
						i++;
						continue;
					}
				}
				else
				{
					players[ i ] thread faderevivemessageover( playertorevive, 3 );
				}
				i++;
			}
			playertorevive.revivetrigger.createtime = undefined;
			wait 3.5;
		}
	}
*/
}

faderevivemessageover( playertorevive, time )
{
	revive_hud_show();
	self.revive_hud settext( &"ZOMBIE_PLAYER_NEEDS_TO_BE_REVIVED", playertorevive );
	self.revive_hud fadeovertime( time );
	self.revive_hud.alpha = 0;
}

revive_hud_show()
{
	self.revive_hud.alpha = 1;
}

revive_trigger_spawn()
{
	foreach( player in level.players )
	{
		player setLowerMessage( self.name + " needs to be revived" );
		player clearLowerMessage(3);
	}
	foreach( player in level.players )
	{
		if( player == self )
			continue;
		player thread ReviveTriggerHere( self );
	}
}

ReviveTriggerHere( player )
{
	self endon("death");
	while( player.sessionstate != "spectator" )
	{
		if( player.sessionstate != "spectator" && Distance( player GetOrigin(), self GetOrigin() ) < 128 && isAlive( self ) && !self player_is_in_laststand() )
		{
			self setLowerMessage("Hold [{+usereload}] to revive");
			while( player.sessionstate != "spectator" && Distance( player GetOrigin(), self GetOrigin() ) < 128 && isAlive( self ) && !self player_is_in_laststand() )
			{
				if( self usebuttonpressed() )
				{
					wait .25;
					if( !self usebuttonpressed() )
						break;
					self disableweapons();
					player.revivetrigger = "";
					self setLowerMessage("Reviving player...");
					wait .05;
					revived = false;
					if( self.quickrevive )
					{
						self clearLowerMessage( 2.5 );
						for( i = 0; i < 10; i++ )
						{
							if( player.sessionstate == "spectator" || !self usebuttonpressed() || self player_is_in_laststand() || (Distance( player GetOrigin(), self GetOrigin() ) >= 128) )
								break;
							wait .25;
						}
						if( i == 10 )
							revived = true;
					}
					else
					{
						self clearLowerMessage( 5 );
						for( i = 0; i < 20; i++ )
						{
							if( player.sessionstate == "spectator" || !self usebuttonpressed() || self player_is_in_laststand() || (Distance( player GetOrigin(), self GetOrigin() ) >= 128) )
							wait .25;
						}
						if( i == 20 )
							revived = true;
					}
					if( revived )
					{
						player notify("player_revived");
						player.laststand = undefined;
						player.revivetrigger = undefined;
						player allowjump( 1 );
						player setstance("stand");
						player thread revive_success( self );
						self Enableweapons();
						return;
					}
					player.revivetrigger = undefined;
					self Enableweapons();
				}
				wait .05;
				waittillframeend;
			}
			self clearlowermessage( .1 );		
		}
		wait .25;
	}
}

//player_revived

revive_trigger_think()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "stop_revive_trigger" );
	level endon( "end_game" );
	self endon( "death" );
	while ( 1 )
	{
		wait 0.1;
		self.revivetrigger sethintstring( "" );
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			d = 0;
			if ( players[ i ] can_revive( self ) || d > 20 )
			{
				self.revivetrigger setrevivehintstring( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER", self.team);
				break;
			}
			else
			{
				i++;
			}
		}
		i = 0;
		while ( i < players.size )
		{
			reviver = players[ i ];
			if ( self == reviver || !reviver is_reviving( self ) )
			{
				i++;
				continue;
			}
			else
			{
				gun = reviver getcurrentweapon();
				if ( gun == level.revive_tool )
				{
					i++;
					continue;
				}
				else
				{
					reviver giveweapon( level.revive_tool );
					reviver switchtoweapon( level.revive_tool );
					reviver setweaponammostock( level.revive_tool, 1 );
					revive_success = reviver revive_do_revive( self, gun );
					reviver revive_give_back_weapons( gun );
					if ( isplayer( self ) )
					{
						self allowjump( 1 );
					}
					self.laststand = undefined;
					if ( revive_success )
					{
						self thread revive_success( reviver );
						self cleanup_suicide_hud();
						return;
					}
				}
			}
			i++;
		}
	}
}

cleanup_suicide_hud()
{
	if ( isDefined( self.suicideprompt ) )
	{
		self.suicideprompt destroy();
	}
	self.suicideprompt = undefined;
}

revive_success( reviver, b_track_stats )
{
	if ( !isDefined( b_track_stats ) )
	{
		b_track_stats = 1;
	}
	if ( !isplayer( self ) )
	{
		self notify( "player_revived" );
		return;
	}
	self notify( "player_revived" );
	self reviveplayer();
	self setnormalhealth( self.maxhealth );
	self freezecontrolsallowlook(false);
	setclientsysstate( "lsm", "0", self );
	self.revivetrigger = undefined;
	//self laststand_enable_player_weapons();
	self.ignoreme = 0;
}

laststand_enable_player_weapons()
{
	if ( isDefined( self.hadpistol ) && !self.hadpistol && isDefined( self.laststandpistol ) )
	{
		self takeweapon( self.laststandpistol );
	}
	if ( isDefined( self.hadpistol ) && self.hadpistol == 1 && isDefined( level.zombie_last_stand_ammo_return ) )
	{
		[[ level.zombie_last_stand_ammo_return ]]();
	}
	self enableweaponcycling();
	self enableoffhandweapons();
	if ( isDefined( self.lastactiveweapon ) && self.lastactiveweapon != "none" && self hasweapon( self.lastactiveweapon ) )
	{
		self switchtoweapon( self.lastactiveweapon );
	}
	else
	{
		primaryweapons = self getweaponslistprimaries();
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self switchtoweapon( primaryweapons[ 0 ] );
		}
	}
}

revive_give_back_weapons( gun )
{
	self takeweapon( level.revive_tool );
	if ( self player_is_in_laststand() )
	{
		return;
	}
	if ( gun != "none" && self hasweapon( gun ) )
	{
		self switchtoweapon( gun );
	}
	else
	{
		primaryweapons = self getweaponslistprimaries();
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self switchtoweapon( primaryweapons[ 0 ] );
		}
	}
}

laststand_clean_up_on_disconnect( playerbeingrevived, revivergun )
{
	self endon( "do_revive_ended_normally" );
	revivetrigger = playerbeingrevived.revivetrigger;
	playerbeingrevived waittill( "disconnect" );
	if ( isDefined( revivetrigger ) )
	{
		revivetrigger delete();
	}
	self cleanup_suicide_hud();
	if ( isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar destroyelem();
	}
	if ( isDefined( self.revivetexthud ) )
	{
		self.revivetexthud destroy();
	}
	self revive_give_back_weapons( revivergun );
}

laststand_clean_up_reviving_any( playerbeingrevived )
{
	self endon( "do_revive_ended_normally" );
	playerbeingrevived waittill_any( "disconnect", "zombified", "stop_revive_trigger" );
	self.is_reviving_any--;
	if ( self.is_reviving_any <= 0 )
	{
		self.is_reviving_any = 0;
	}
}

check_for_failed_revive( playerbeingrevived )
{
	self endon( "disconnect" );
	playerbeingrevived endon( "disconnect" );
	playerbeingrevived endon( "player_suicide" );
	self notify( "checking_for_failed_revive" );
	self endon( "checking_for_failed_revive" );
	playerbeingrevived endon( "player_revived" );
	playerbeingrevived waittill( "bled_out" );
}

revive_do_revive( playerbeingrevived, revivergun )
{
	revivetime = 3;
	if ( self hasperk( "specialty_quickrevive" ) )
	{
		revivetime /= 2;
	}
	timer = 0;
	revived = 0;
	playerbeingrevived.revivetrigger.beingrevived = 1;
	playerbeingrevived.revive_hud settext( &"ZOMBIE_PLAYER_IS_REVIVING_YOU", self );
	playerbeingrevived revive_hud_show_n_fade( 3 );
	playerbeingrevived.revivetrigger sethintstring( "" );
	if ( isplayer( playerbeingrevived ) )
	{
		playerbeingrevived startrevive( self );
	}
	if ( !isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar = self createprimaryprogressbar();
	}
	if ( !isDefined( self.revivetexthud ) )
	{
		self.revivetexthud = newclienthudelem( self );
	}
	self thread laststand_clean_up_on_disconnect( playerbeingrevived, revivergun );
	if ( !isDefined( self.is_reviving_any ) )
	{
		self.is_reviving_any = 0;
	}
	self.is_reviving_any++;
	self thread laststand_clean_up_reviving_any( playerbeingrevived );
	self.reviveprogressbar updatebar( 0.01, 1 / revivetime );
	self.revivetexthud.alignx = "center";
	self.revivetexthud.aligny = "middle";
	self.revivetexthud.horzalign = "center";
	self.revivetexthud.vertalign = "bottom";
	self.revivetexthud.y = -113;
	if ( self issplitscreen() )
	{
		self.revivetexthud.y = -347;
	}
	self.revivetexthud.foreground = 1;
	self.revivetexthud.font = "default";
	self.revivetexthud.fontscale = 1.8;
	self.revivetexthud.alpha = 1;
	self.revivetexthud.color = ( 1, 1, 1 );
	self.revivetexthud.hidewheninmenu = 1;
	self.revivetexthud settext( &"ZOMBIE_REVIVING" );
	self thread check_for_failed_revive( playerbeingrevived );
	while ( self is_reviving( playerbeingrevived ) )
	{
		wait 0.05;
		timer += 0.05;
		if ( self player_is_in_laststand() )
		{
			break;
		}
		else if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
		{
			break;
		}
		else
		{
			if ( timer >= revivetime )
			{
				revived = 1;
				break;
			}
			else
			{
			}
		}
	}
	if ( isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar destroyelem();
	}
	if ( isDefined( self.revivetexthud ) )
	{
		self.revivetexthud destroy();
	}
	if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
	{
	}
	else if ( !revived )
	{
		if ( isplayer( playerbeingrevived ) )
		{
			playerbeingrevived stoprevive( self );
		}
	}
	playerbeingrevived.revivetrigger sethintstring( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
	playerbeingrevived.revivetrigger.beingrevived = 0;
	self notify( "do_revive_ended_normally" );
	self.is_reviving_any--;
	if ( !revived )
	{
		playerbeingrevived thread checkforbleedout( self );
	}
	return revived;
}

checkforbleedout( player )
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "disconnect" );
	player endon( "disconnect" );
	player.failed_revives++;
	player notify( "player_failed_revive" );
}

truefunc( player )
{
	return true;
}

can_revive( revivee )
{
	if ( !isalive( self ) )
	{
		return 0;
	}
	if ( self player_is_in_laststand() )
	{
		return 0;
	}
	if ( isDefined( self.is_zombie ) && self.is_zombie )
	{
		return 0;
	}
	ignore_sight_checks = 0;
	ignore_touch_checks = 0;
	if ( isDefined( level.revive_trigger_should_ignore_sight_checks ) )
	{
		ignore_sight_checks = [[ level.revive_trigger_should_ignore_sight_checks ]]( self );
		if ( ignore_sight_checks && isDefined( revivee.revivetrigger.beingrevived ) && revivee.revivetrigger.beingrevived == 1 )
		{
			ignore_touch_checks = 1;
		}
	}
	if ( !ignore_touch_checks )
	{
		if ( !self istouching( revivee.revivetrigger ) )
		{
			return 0;
		}
	}
	if ( !ignore_sight_checks )
	{
		if ( !self is_facing( revivee ) )
		{
			return 0;
		}
	}
	return 1;
}

is_facing( facee )
{
	orientation = self getplayerangles();
	forwardvec = anglesToForward( orientation );
	forwardvec2d = ( forwardvec[ 0 ], forwardvec[ 1 ], 0 );
	unitforwardvec2d = vectornormalize( forwardvec2d );
	tofaceevec = facee.origin - self.origin;
	tofaceevec2d = ( tofaceevec[ 0 ], tofaceevec[ 1 ], 0 );
	unittofaceevec2d = vectornormalize( tofaceevec2d );
	dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
	return dotproduct > 0.9;
}

is_reviving( revivee )
{
	if ( self usebuttonpressed() )
	{
		return can_revive( revivee );
	}
}

is_reviving_any()
{
	if ( isDefined( self.is_reviving_any ) )
	{
		return self.is_reviving_any;
	}
}









