InitPlayer()
{
	self [[ game[ "set_player_model" ][ "allies" ][ "smg" ] ]]();
}

InitZombie()
{
	self [[ game[ "set_player_model" ][ "axis" ][ "smg" ] ]]();
	self onplayerconnect6();
	self main_anim();
	self onplayerconnect6();
	self zombie_spawn_init();
	self thread find_flesh();
	self thread onDeathMonitor();
	self hide();
	self SetSpeed(level.zombie_move_speed);
	if( level.round_number < 15 )
		self setmovespeedscale( level.round_number / 15 );
	else
		self setmovespeedscale( .95 );
	self thread AttachZombie();
	self stopsounds();
	self.accuracy = 0;
	self thread MeleeMonitor();
	self thread BadPlacesMonitor();
	self thread MPD_Adjustment();
	self.soundmod = "";
}

BadPlacesMonitor()
{
	self endon("death");
	lastorigin = self.origin;
	while( 1 )
	{
		if( self.origin[2] < -1500 )
		{
			self dodamage( self.health + 1, self.origin );
		}
		lastorigin = self.origin;
		wait 5;
		if( lastorigin == self.origin )
		{
			wait 5;
			if( lastorigin == self.origin )
			{
				self dodamage( self.health + 1, self.origin );
			}
		}
	}
}

MeleeMonitor()
{
	self endon("death");
	while( 1 )
	{
		foreach( player in level.players )
		{
			if( Distance(player GetOrigin(), self GetOrigin() ) < 75 && !player player_is_in_laststand())
			{
				player thread AttackWithMelee(self);
			}
		}
		wait 1;
	}
}

AttackWithMelee(dog)
{
	self endon("damage");
	dog endon("death");
	wait .25;
	if( Distance( dog Getorigin(), self getorigin() ) < 75 && !self player_is_in_laststand())
	{
		self dodamage( 50, self GetOrigin(), dog );
	}
}

AttachZombie()
{
	self.zombiemodel = spawn("script_model", self getorigin());
	self.zombiemodel [[ game[ "set_player_model" ][ "axis" ][ "smg" ] ]]();
	self.zombiemodel.angles = self.angles;
	self.zombiemodel EnableLinkTo();
	self.zombiemodel LinkTo( self, "j_spinelower");
	self.zombiemodel.brush = spawn("script_model", (self.zombiemodel GetOrigin()));
	self.zombiemodel.brush SetModel("t6_wpn_supply_drop_ally");
	self.zombiemodel.brush.team = "axis";
	self.zombiemodel.brush.maxhealth = 100;
	self.zombiemodel.brush.healh = 100;
	self.zombiemodel.brush Solid();
	self.zombiemodel.brush SetCanDamage(1);
	self.zombiemodel.brush hide();
	self.zombiemodel.brush LinkTo( self.zombiemodel, "j_spinelower", (-5,0,0), (90,90,0));
	self.zombiemodel.brush thread OnActorDamaged(self);
}

OnActorDamaged( actor )
{
	actor endon("death");
	while( 1 )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		playfx(level.blood_fx,point, (0,0,0), ((attacker GetEye()) - point));
		if( isDefined( mod ) && mod != "MOD_MELEE" && isHitHeadShot( point, self GetOrigin() ) )
		{
			actor notify("damage", amount, attacker, dir, point, "MOD_HEAD_SHOT" );
		}
		else
		{
			if(mod == "MOD_MELEE")
				actor notify("damage", amount, attacker, dir, point, "MOD_DOMELEEDAMAGE" );
			else
				actor notify("damage", amount, attacker, dir, point, "MOD_DODAMAGE" );
		}
	}
}

isHitHeadShot( hitpoint, boxorigin )
{
	DVector = hitpoint - boxorigin;
	if( DVector[2] > 20 )
	{
		return true;
	}
	return false;
}

onDeathMonitor()
{
	self waittill("death");
	if( !isDefined( self.thunderwall ) )
	{
		self thread TryPowerUpDrop( self GetOrigin() );
	}
	arrayremovevalue( level.zombie_team, self );
	self.zombiemodel.brush delete();
	self.zombiemodel delete();
	self show();
	self StartRagdoll( 0 );
	wait 3;
	self delete();
}

DebugZombie()
{
	if( isDefined( level.oneselected ) )
		return;
	level.oneselected = true;
	while( isDefined( self ) )
	{
		wait 1;
	}
}

zombie_spawn_init( animname_set )
{
	if ( !isDefined( animname_set ) )
	{
		animname_set = 0;
	}
	self.targetname = "zombie";
	self.script_noteworthy = undefined;
	if ( !animname_set )
	{
		self.animname = "zombie";
	}
	//Ambient vocals todo
	self.zmb_vocals_attack = "zmb_vocals_zombie_attack";
	self.ignoreall = 1;
	self.speed = level.zombie_move_speed;
	self.ignoreme = 1;
	self.allowdeath = 1;
	self.force_gib = 1;
	self.is_zombie = 1;
	self.has_legs = 1;
	self allowedstances( "stand" );
	self.zombie_damaged_by_bar_knockdown = 0;
	self.gibbed = 0;
	self.head_gibbed = 0;
	self setphysparams( 15, 0, 72 );
	self.disablearrivals = 1;
	self.disableexits = 1;
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;
	self.ignoresuppression = 1;
	self.suppressionthreshold = 1;
	self.nododgemove = 1;
	self.dontshootwhilemoving = 1;
	self.pathenemylookahead = 0;
	self.badplaceawareness = 0;
	self.chatinitialized = 0;
	self.a.disablepain = 1;
	self disable_react();
	if ( isDefined( level.zombie_health ) )
	{
		self.maxhealth = level.zombie_health;
		if ( isDefined( level.zombie_respawned_health ) && level.zombie_respawned_health.size > 0 )
		{
			self.health = level.zombie_respawned_health[ 0 ];
			arrayremovevalue( level.zombie_respawned_health, level.zombie_respawned_health[ 0 ] );
		}
		else
		{
			self.health = level.zombie_health;
		}
	}
	else
	{
		self.maxhealth = level.zombie_vars[ "zombie_health_start" ];
		self.health = self.maxhealth;
	}
	self.freezegun_damage = 0;
	self.dropweapon = 0;
	level thread zombie_death_event( self );
	self init_zombie_run_cycle();
	self thread zombie_think();
	self thread enemy_death_detection();
	if ( isDefined( level._zombie_custom_spawn_logic ) )
	{
		if ( isarray( level._zombie_custom_spawn_logic ) )
		{
			i = 0;
			while ( i < level._zombie_custom_spawn_logic.size )
			{
				self thread [[ level._zombie_custom_spawn_logic[ i ] ]]();
				i++;
			}
		}
		else self thread [[ level._zombie_custom_spawn_logic ]]();
	}
	//self.deathfunction = ::zombie_death_animscript;
	self.flame_damage_time = 0;
	self.meleedamage = 60;
	self.no_powerups = 1;
	self.team = level.zteam;
	if ( isDefined( level.achievement_monitor_func ) )
	{
		self [[ level.achievement_monitor_func ]]();
	}
	if ( isDefined( level.zombie_init_done ) )
	{
		self [[ level.zombie_init_done ]]();
	}
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
}

disable_react()
{
	self.a.disablereact = 1;
	self.allowreact = 0;
}









