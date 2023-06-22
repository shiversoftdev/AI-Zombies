/*
*	 Black Ops 2 - GSC Studio by iMCSx
*
*	 Creator : SeriousHD- & Extinct
*	 Project : Real Zombies
*    Mode : Multiplayer
*	 Date : 2016/07/25 - 06:11:12	

																										TODO
																							
																							1: Fix Multiplayer Downing System
																							2: Map Edits
																							3: Fix Nuketown Railing glitches
																							4: Fix railing glitches on Downhill?
*/	

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;

init()
{
	InitDTable();
	setdvar("scr_cable_car_velocity", 0);
	level.fx_exclude_footsteps = false;
	level.grenadelauncherdudtime = 0;
	level.usingrampage = false;
	level.overrideplayerscore = true;
	level.disablemomentum = true;
	precacheshader("perk_hardline");
	precacheshader("perk_flak_jacket");
	precacheshader("perk_fast_hands");
	precacheshader("perk_ghost");
	precacheshader("perk_marathon");
	precacheshader("perk_dexterity");
	precacheshader("perk_warrior");
	precacheshader("hud_scavenger_pickup");
	precacheshader("hud_ks_emp_drop");
	precacheshader("waypoint_second_chance");
	precacheshader("headicon_dead");
	precacheshader("perk_tactical_mask");
	precacheshader("hud_ks_m32");
	precachemodel("t6_wpn_supply_drop_ally");
	precachemodel("collision_clip_wall_128x128x10");
	precachemodel("collision_clip_wall_256x256x10");
	precachemodel("collision_clip_wall_512x512x10");
	precachemodel("collision_clip_wall_64x64x10");
	precachemodel("t6_wpn_briefcase_bomb_view");
	precachemodel("t6_wpn_c4_world");
	level.dog_abort = 0;
	level.hotjoinenabled = 0;
	level.zombie_total_set_func = ::CalculateZombiesThisRound;
	level.is_specops_level = 1;
	level.zteam = "axis";
	level.playerteam = "allies";
	level.playerhealth = 150;
	level.can_revive = ::truefunc;
	level.zombie_team = [];
	level.passed_introscreen = 0;
	level.no_end_game_check = false;
	level.zombiemode = 1;
	level.teambased = 1;
	level.revivefeature = 0;
	level.swimmingfeature = 0;
	level.curr_gametype_affects_rank = 0;
	level.grenade_multiattack_bookmark_count = 1;
	level.rampage_bookmark_kill_times_count = 3;
	level.rampage_bookmark_kill_times_msec = 6000;
	level.rampage_bookmark_kill_times_delay = 6000;
	level.zombie_visionset = "zombie_neutral";
	precacheshader( "waypoint_revive" );
	precacheshader( "black" );
	precachemodel( "tag_origin" );
	level._zombie_gib_piece_index_all = 0;
	level._zombie_gib_piece_index_right_arm = 1;
	level._zombie_gib_piece_index_left_arm = 2;
	level._zombie_gib_piece_index_right_leg = 3;
	level._zombie_gib_piece_index_left_leg = 4;
	level._zombie_gib_piece_index_head = 5;
	level._zombie_gib_piece_index_guts = 6;
	level._zombie_gib_piece_index_hat = 7;
	level.zombie_actor_limit = 70;
	level.round_number = 1;
	level.zombie_ai_limit = 61;
	setdvar( "revive_trigger_radius", "75" );
	setdvar( "player_lastStandBleedoutTime", "45" );
	setDvar("g_friendlyfireDist", "9999"); 
	level.is_zombie_level = 0;
	level.laststandpistol = "fiveseven_mp";
	level.default_laststandpistol = "fiveseven_mp";
	level.default_solo_laststandpistol = "fiveseven_mp";
	level.start_weapon = "fiveseven_mp";
	level.first_round = 1;
	level.start_round = 1;
	level.round_number = level.start_round;
	level.enable_magic = 1;
	level.headshots_only = 0;
	level.player_starting_points = level.round_number * 500;
	level.round_start_time = 0;
	level.pro_tips_start_time = 0;
	level.intermission = 0;
	level.dog_intermission = 0;
	level.zombie_total = 0;
	level.total_zombies_killed = 0;
	level.laststandgetupallowed = false;
	level.hudelem_count = 0;
	level.zombie_spawn_locations = [];
	level.zombie_rise_spawners = [];
	level.current_zombie_array = [];
	level.current_zombie_count = 0;
	level.zombie_total_subtract = 0;
	level.destructible_callbacks = [];
	level.zombie_vars = [];
	set_zombie_var( "zombie_health_increase", 100);
	set_zombie_var( "zombie_health_increase_multiplier", 0.1);
	set_zombie_var( "zombie_health_start", 150);
	set_zombie_var( "zombie_spawn_delay", 2);
	set_zombie_var( "zombie_new_runner_interval", 10);
	set_zombie_var( "zombie_move_speed_multiplier", 8);
	set_zombie_var( "zombie_max_ai", 60);
	set_zombie_var( "below_world_check", -1000 );
	set_zombie_var( "spectators_respawn", 1 );
	set_zombie_var( "zombie_between_round_time", 10 );
	set_zombie_var( "zombie_intermission_time", 15 );
	set_zombie_var( "game_start_delay", 0);
	set_zombie_var( "penalty_no_revive", 0.1);
	set_zombie_var( "penalty_died", 0);
	set_zombie_var( "penalty_downed", 0.05);
	set_zombie_var( "starting_lives", 1);
	set_zombie_var( "zombie_score_damage_normal", 10 );
	set_zombie_var( "zombie_score_damage_light", 10 );
	set_zombie_var( "zombie_score_bonus_melee", 80 );
	set_zombie_var( "zombie_score_bonus_head", 50 );
	set_zombie_var( "zombie_score_bonus_neck", 20 );
	set_zombie_var( "zombie_score_bonus_torso", 10 );
	set_zombie_var( "zombie_score_bonus_burn", 10 );
	set_zombie_var( "zombie_flame_dmg_point_delay", 500 );
	visionsetnight( "default_night" );
	level.noroundnumber = false;
	level.zombie_spawn_locations = [];
	level.current_valid_spawns = level.zombie_spawn_locations;
	level thread start_intro_screen_zm();
	level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
	level.zombie_move_speed = 1;
	level.speed_change_max = 0;
	level.speed_change_num = 0;
	level thread PreMatchOverride();
	init_flags();
	init_function_overrides();
	level thread onPlayerConnected();
	level thread post_all_players_connected();
	level thread onallplayersready();
	level.blood_fx = loadfx( "impacts/fx_deathfx_dogbite" );
	_laststand_init();
	_playerhealth_init();
	powerups_init();
	maps/mp/_utility::registerclientsys( "lsm" );
	setscoreboardcolumns( "pointstowin", "kills", "downs", "revives", "headshots");
}

init_flags()
{
	flag_init( "solo_game" );
	flag_init( "start_zombie_round_logic" );
	flag_init( "start_encounters_match_logic" );
	flag_init( "spawn_point_override" );
	flag_init( "power_on" );
	flag_init( "crawler_round" );
	flag_init( "spawn_zombies", 1 );
	flag_init( "dog_round" );
	flag_init( "begin_spawning" );
	flag_init( "end_round_wait" );
	flag_init( "wait_and_revive" );
	flag_init( "instant_revive" );
	flag_init( "initial_blackscreen_passed" );
	flag_init( "initial_players_connected" );
}

init_function_overrides()
{
	level.callbackplayerdamage = ::callback_playerdamage;
	level.overrideplayerdamage = ::player_damage_override;
	level.callbackplayerkilled = ::player_killed_override;
	level.playerlaststand_func = ::player_laststand;
	level.callbackplayerlaststand = ::callback_playerlaststand;
	level.prevent_player_damage = ::player_prevent_damage;
	level.custom_introscreen = ::zombie_intro_screen;
	level.reset_clientdvars = ::onplayerconnect_clientdvars;
	level.zombie_last_stand = ::last_stand_pistol_swap;
}

OnPlayerConnected()
{
	while( 1 )
	{
		level waittill("connected", player);
		wait .01;
		if( isDefined( player.isbot ) && player.isbot )
			continue;
		player thread OnConnected();
	}
}

WaitForHotJoinAllowed()
{
	level endon("hotjoinallowed");
	if( level.hotjoinenabled )
		self waittill("forever");
}

OnConnected()
{
	self endon( "disconnect" );
	self notify( "stop_onPlayerSpawned" );
	self endon( "stop_onPlayerSpawned" );
	if( self ishost() )
	{
		level thread OnAllPlayersDown();
	}
	disablegrenadesuicide();
	self WaitForHotJoinAllowed();
	self notify("menuresponse", "changeclass", "class_smg");
	while( !isAlive( self ) && !level.hotjoinenabled )
	{
		self notify("menuresponse", "changeclass", "class_smg");
		wait .01;
	}
	self.player_initialized = false;
	self.pers["team"] = level.playerteam;
	self.team = level.playerteam;
	self.sessionteam = level.playerteam;
	self.ignoreme = false;
	self.is_zombie = 0;
	self.pers[ "downs" ] = 0;
	self.downs = 0;
	self.lives = 0;
	self.soloquickrevivesremaining = 3;
	self.maxhealth = 120;
	self.pers[ "pointstowin" ] = 0;
	self.score = 0;
	self.perkinhand = 0;
	firstspawn = true;
	for ( ;; )
	{
		self.mulekick = 0;
		self.juggernog = 0;
		self.doubletap = 0;
		self.quickrevive = 0;
		self.divetonuke = 0;
		self setmovespeedscale( 1.25 );
		self.ignoretriggers = 0;
		if( self ishost() && firstspawn )
		{
			self thread pausegameafter1minute();
			MapInit();
			firstspawn = false;
		}
		foreach( weapon in level.wallweapons )
			self thread WeaponTriggerMonitor( weapon );
		self.hud_damagefeedback destroy();
		self.pers[ "momentum" ] = -99999999;
		self thread AmmoCounter();
		self thread ScoreCounter();
		self AddToPlayerScore( 500 ); //Update Score HUD
		self.maxhealth = 125;
		self notify( "noHealthOverlay" );
		self InitPlayer();
		self.laststand = false;
		self thread playerhealthregen();
		self useServerVisionSet(true);
		self SetVisionSetforPlayer("remote_mortar_enhanced", 0);
		self.zombiehealth = level.playerhealth;
		self.health = level.playerhealth;
		self setclientuivisibilityflag( "hud_visible", 0 );
		self takeallweapons();
		self giveweapon( "knife_mp" );
		self clearperks();
		self.no_revive_trigger = false;
		self giveweapon( level.laststandpistol );
		self switchtoweapon( level.laststandpistol );
		if ( level.passed_introscreen )
		{
			self setclientuivisibilityflag( "hud_visible", 0 );
		}
		if ( isDefined( level.host_ended_game ) && !level.host_ended_game )
		{
			self freezecontrols( 0 );
		}
		self.hits = 0;
		self setactionslot( 3, "altMode" );
		self playerknockback( 0 );
		self setclientthirdperson( 0 );
		self resetfov();
		self setclientthirdpersonangle( 0 );
		self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
		self cameraactivate( 0 );
		self.num_perks = 0;
		self.on_lander_last_stand = undefined;
		self setblur( 0, 0.1 );
		self.zmbdialogqueue = [];
		self.zmbdialogactive = 0;
		self.zmbdialoggroups = [];
		self.zmbdialoggroup = "";
		if ( isDefined( level.player_out_of_playable_area_monitor ) && level.player_out_of_playable_area_monitor )
		{
			self thread player_out_of_playable_area_monitor();
		}
		if ( isDefined( level.player_too_many_weapons_monitor ) && level.player_too_many_weapons_monitor )
		{
			self thread [[ level.player_too_many_weapons_monitor_func ]]();
		}
		self.disabled_perks = [];
		self thread MysteryBoxTrigger();
		self thread PAP_Trigger();
		foreach( perk in level.perkmachines)
		{
			self thread PerkTrigger( perk );
		}
		if ( isDefined( self.player_initialized ) )
		{
			if ( self.player_initialized == 0 )
			{
				self.player_initialized = 1;
				self giveweapon( "frag_grenade_mp" );
				self setweaponammoclip( "frag_grenade_mp", 0 );
				self setclientammocounterhide( 0 );
				self setclientminiscoreboardhide( 0 );
				self.is_drinking = 0;
				self thread player_zombie_breadcrumb();
				self revive_hud_create();
				self thread player_spawn_protection();
				if ( !isDefined( self.lives ) )
				{
					self.lives = 0;
				}
			}
		}
		DebugMode();
		self waittill( "spawned_player" );
	}
}
pausegameafter1minute()
{
	wait 60;
	maps\mp\gametypes\_globallogic_utils::pausetimer();
}

player_spawn_protection()
{
	self endon( "disconnect" );
	x = 0;
	while ( x < 60 )
	{
		self.ignoreme = 1;
		x++;
		wait 0.05;
	}
	self.ignoreme = 0;
}

post_all_players_connected()
{
	level thread end_game();
	flag_wait( "start_zombie_round_logic" );
	wait 5;
	level thread round_start();
}

end_game()
{
	level waittill( "end_game" );
	foreach( player in level.players )
	{
		if( player.sessionstate == "spectator" )
			player [[ level.spawnplayer ]]();
		player EnableInvulnerability();
	}
	wait 1;
	foreach( player in level.players )
	{
		player freezecontrols( true );
		player setstance( "prone" );
		player disableweapons();
	}
	foreach( zombie in level.zombie_team )
		zombie dodamage( zombie.health + 1, zombie getorigin() );
	setmatchflag( "disableIngameMenu", 1 );
	game_over = newhudelem();
	game_over.alignx = "center";
	game_over.aligny = "middle";
	game_over.horzalign = "center";
	game_over.vertalign = "middle";
	game_over.y -= 130;
	game_over.foreground = 1;
	game_over.fontscale = 3;
	game_over.alpha = 0;
	game_over.color = ( 0, 0, -1 );
	game_over.hidewheninmenu = 1;
	game_over settext( "GAME OVER" );
	game_over fadeovertime( 1 );
	game_over.alpha = 1;
	survived = newhudelem();
	survived.alignx = "center";
	survived.aligny = "middle";
	survived.horzalign = "center";
	survived.vertalign = "middle";
	survived.y -= 100;
	survived.foreground = 1;
	survived.fontscale = 2;
	survived.alpha = 0;
	survived.color = ( 0, 0, -1 );
	survived.hidewheninmenu = 1;
	if( level.round_number != 1 )
		survived SetText( "YOU SURVIVED " + level.round_number + " ROUNDS" );
	else
		survived SetText( "YOU SURVIVED " + level.round_number + " ROUND" );
	survived fadeovertime( 1 );
	survived.alpha = 1;
	survived.color = (1,1,1);
	game_over.color = (1,1,1);
	wait 5;
	iprintln("^2Gamemode by: SeriousHD- and ExtinctMods");
	iprintln("^2www.youtube.com/anthonything");
	iprintln("^2www.youtube.com/c/ExtinctMods");
	level.outroscreen = newhudelem();
	level.outroscreen.alpha = 0;
	level.outroscreen.x = 0;
	level.outroscreen.y = 0;
	level.outroscreen.horzalign = "fullscreen";
	level.outroscreen.vertalign = "fullscreen";
	level.outroscreen.foreground = 0;
	level.outroscreen setshader( "black", 640, 480 );
	level.outroscreen.immunetodemogamehudsettings = 1;
	level.outroscreen.immunetodemofreecamera = 1;
	PlayCinematicOutro();
	if( level.outroscreen.alpha != 1 )
	{
		level.outroscreen fadeovertime( 1 );
		level.outroscreen.alpha = 1;
	}
	game_over fadeovertime( 1 );
	survived fadeovertime( 1 );
	Madeby.alpha = 0;
	MyChannel.alpha = 0;
	HisChannel.alpha = 0;
	game_over.alpha = 0;
	survived.alpha = 0;
	wait 4;
	exitlevel( 1 );
}

onallplayersready()
{
	timeout = getTime() + 5000;
	while ( getnumexpectedplayers() == 0 && getTime() < timeout )
	{
		wait 0.1;
	}
	player_count_actual = 0;
	while ( getnumconnectedplayers() < getnumexpectedplayers() || player_count_actual != getnumexpectedplayers() )
	{
		players = get_players();
		player_count_actual = 0;
		i = 0;
		while ( i < players.size )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ].sessionstate == "playing" )
			{
				player_count_actual++;
			}
			i++;
		}
		wait 0.1;
	}
	players = get_players();
	if ( players.size == 1 )
	{
		flag_set( "solo_game" );
		level.solo_lives_given = 0;
		_a379 = players;
		_k379 = getFirstArrayKey( _a379 );
		while ( isDefined( _k379 ) )
		{
			player = _a379[ _k379 ];
			player.lives = 0;
			_k379 = getNextArrayKey( _a379, _k379 );
		}
	}
	flag_set( "initial_players_connected" );
	thread start_zombie_logic_in_x_sec( 3 );
	fade_out_intro_screen_zm( 5, 1.5, 1 );
}

start_zombie_logic_in_x_sec( time_to_wait )
{
	wait time_to_wait;
	flag_set( "start_zombie_round_logic" );
}

PreMatchOverride()
{
	level.prematchperiod = 0;
	while( level.inprematchperiod == 0 )
		wait .1;
	level.prematchperiod = 0;
}

fade_out_intro_screen_zm( hold_black_time, fade_out_time, destroyed_afterwards )
{
	if ( !isDefined( level.introscreen ) )
	{
		level.introscreen = newhudelem();
		level.introscreen.x = 0;
		level.introscreen.y = 0;
		level.introscreen.horzalign = "fullscreen";
		level.introscreen.vertalign = "fullscreen";
		level.introscreen.foreground = 0;
		level.introscreen setshader( "black", 640, 480 );
		level.introscreen.immunetodemogamehudsettings = 1;
		level.introscreen.immunetodemofreecamera = 1;
		wait 0.05;
	}
	level.introscreen.alpha = 1;
	if ( isDefined( hold_black_time ) )
	{
		wait hold_black_time;
	}
	else
	{
		wait 0.2;
	}
	if ( !isDefined( fade_out_time ) )
	{
		fade_out_time = 1.5;
	}
	level.introscreen fadeovertime( fade_out_time );
	level.introscreen.alpha = 0;
	wait 1.6;
	level.passed_introscreen = 1;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] setclientuivisibilityflag( "hud_visible", 0 );
		players[ i ] freezecontrols( 0 );
		i++;
	}
	if ( destroyed_afterwards == 1 )
	{
		level.introscreen destroy();
	}
	flag_set( "initial_blackscreen_passed" );
}

start_intro_screen_zm()
{
	if ( level.createfx_enabled )
	{
		return;
	}
	if ( !isDefined( level.introscreen ) )
	{
		level.introscreen = newhudelem();
		level.introscreen.x = 0;
		level.introscreen.y = 0;
		level.introscreen.horzalign = "fullscreen";
		level.introscreen.vertalign = "fullscreen";
		level.introscreen.foreground = 0;
		level.introscreen setshader( "black", 640, 480 );
		level.introscreen.immunetodemogamehudsettings = 1;
		level.introscreen.immunetodemofreecamera = 1;
		wait 0.05;
	}
	level.introscreen.alpha = 1;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] freezecontrols( 1 );
		i++;
	}
	wait 1;
}

HasUpgrade( weapon )
{
	if( isDefined( self.upgraded_weapons ) )
	{
		if( isinarray(self.upgraded_weapons, weapon) )
		{
			if( !self HasWeapon( weapon ) )
			{
				arrayremovevalue(self.upgraded_weapons,weapon);
				self notify("STOP_PAP_"+weapon);
			}
		}
		return isinarray(self.upgraded_weapons, weapon);
	}
	return false;
}

GiveUpgrade( name )
{
	if( !isDefined( self.upgraded_weapons ) )
		self.upgraded_weapons = [];
	self.upgraded_weapons = add_to_array( self.upgraded_weapons, name, 0);
}

OnAllPlayersDown()
{
	flag_wait("start_zombie_round_logic");
	isOneAlive = false;
	while( 1 )
	{
		wait 1;
		isOneAlive = false;
		foreach( player in level.players )
		{
			if( !player player_is_in_laststand() )
			{
				isOneAlive = true;
			}
		}
		if(!isOneAlive)
			level notify("end_game");
	}
}
