main_anim()
{
	self.a = spawnstruct();
	self.team = level.zteam;
	firstinit();
	self.a.pose = "stand";
	self.a.movement = "stop";
	self.a.state = "stop";
	self.a.special = "none";
	self.a.combatendtime = getTime();
	self.a.script = "init";
	self.a.alertness = "casual";
	self.a.lastenemytime = getTime();
	self.a.forced_cover = "none";
	self.a.desired_script = "none";
	self.a.current_script = "none";
	self.a.lookangle = 0;
	self.a.paintime = 0;
	self.a.nextgrenadetrytime = 0;
	self.walk = 0;
	self.sprint = 0;
	self.a.runblendtime = 0.2;
	self.a.flamepaintime = 0;
	self.a.postscriptfunc = undefined;
	self.a.stance = "stand";
	self._animactive = 0;
	self thread deathnotify();
	self.baseaccuracy = self.accuracy;
	if ( !isDefined( self.script_accuracy ) )
	{
		self.script_accuracy = 1;
	}
	self.a.misstime = 0;
	self.a.yawtransition = "none";
	self.a.nodeath = 0;
	self.a.misstime = 0;
	self.a.misstimedebounce = 0;
	self.a.disablepain = 0;
	self.accuracystationarymod = 1;
	self.chatinitialized = 0;
	self.sightpostime = 0;
	self.sightposleft = 1;
	self.precombatrunenabled = 1;
	self.is_zombie = 1;
	self.a.crouchpain = 0;
	self.a.nextstandinghitdying = 0;
	if ( !isDefined( self.script_forcegrenade ) )
	{
		self.script_forcegrenade = 0;
	}
	self.lastenemysighttime = 0;
	self.combattime = 0;
	self.coveridleselecttime = -696969;
	self.old = spawnstruct();
	self.reacquire_state = 0;
	self.a.allow_shooting = 0;
}

deathnotify()
{
	self waittill( "death", other );
	self notify( anim.scriptchange );
}

firstinit()
{
	if ( isDefined( anim.notfirsttime ) )
	{
		return;
	}
	anim.notfirsttime = 1;
	anim.usefacialanims = 0;
	if ( !isDefined( anim.dog_health ) )
	{
		anim.dog_health = 1;
	}
	if ( !isDefined( anim.dog_presstime ) )
	{
		anim.dog_presstime = 350;
	}
	if ( !isDefined( anim.dog_hits_before_kill ) )
	{
		anim.dog_hits_before_kill = 1;
	}
	level.nextgrenadedrop = randomint( 3 );
	level.lastplayersighted = 100;
	anim.defaultexception = ::empty;
	setdvar( "scr_expDeathMayMoveCheck", "on" );
	anim.lastsidestepanim = 0;
	anim.meleerange = 64;
	anim.meleerangesq = anim.meleerange * anim.meleerange;
	anim.standrangesq = 262144;
	anim.chargerangesq = 40000;
	anim.chargelongrangesq = 262144;
	anim.aivsaimeleerangesq = 160000;
	anim.combatmemorytimeconst = 10000;
	anim.combatmemorytimerand = 6000;
	anim.scriptchange = "script_change";
	anim.lastgibtime = 0;
	anim.gibdelay = 3000;
	anim.mingibs = 2;
	anim.maxgibs = 4;
	anim.totalgibs = randomintrange( anim.mingibs, anim.maxgibs );
	anim.corner_straight_yaw_limit = 36;
	if ( !isDefined( anim.optionalstepeffectfunction ) )
	{
		anim.optionalstepeffects = [];
		anim.optionalstepeffectfunction = ::empty;
	}
	anim.notetracks = [];
	registernotetracks();
	if ( !isDefined( level.flag ) )
	{
		level.flag = [];
		level.flags_lock = [];
	}
	level.painai = undefined;
	anim.maymovecheckenabled = 1;
	anim.badplaces = [];
	anim.badplaceint = 0;
	anim.covercrouchleanpitch = -55;
	anim.lastcarexplosiontime = -100000;
}

empty( one, two, three, whatever )
{
}

onplayerconnect6()
{
	player = self;
	firstinit();
	player.invul = 0;
	player.classname = "player";
}

registernotetracks()
{
	anim.notetracks[ "anim_pose = \"stand\"" ] = ::notetrackposestand;
	anim.notetracks[ "anim_pose = \"crouch\"" ] = ::notetrackposecrouch;
	anim.notetracks[ "anim_movement = \"stop\"" ] = ::notetrackmovementstop;
	anim.notetracks[ "anim_movement = \"walk\"" ] = ::notetrackmovementwalk;
	anim.notetracks[ "anim_movement = \"run\"" ] = ::notetrackmovementrun;
	anim.notetracks[ "anim_alertness = causal" ] = ::notetrackalertnesscasual;
	anim.notetracks[ "anim_alertness = alert" ] = ::notetrackalertnessalert;
	anim.notetracks[ "gravity on" ] = ::notetrackgravity;
	anim.notetracks[ "gravity off" ] = ::notetrackgravity;
	anim.notetracks[ "gravity code" ] = ::notetrackgravity;
	anim.notetracks[ "bodyfall large" ] = ::notetrackbodyfall;
	anim.notetracks[ "bodyfall small" ] = ::notetrackbodyfall;
	anim.notetracks[ "footstep" ] = ::notetrackfootstep;
	anim.notetracks[ "step" ] = ::notetrackfootstep;
	anim.notetracks[ "footstep_right_large" ] = ::notetrackfootstep;
	anim.notetracks[ "footstep_right_small" ] = ::notetrackfootstep;
	anim.notetracks[ "footstep_left_large" ] = ::notetrackfootstep;
	anim.notetracks[ "footstep_left_small" ] = ::notetrackfootstep;
	anim.notetracks[ "footscrape" ] = ::notetrackfootscrape;
	anim.notetracks[ "land" ] = ::notetrackland;
	anim.notetracks[ "start_ragdoll" ] = ::notetrackstartragdoll;
}

notetrackposestand( note, flagname )
{
	self.a.pose = "stand";
	self notify( "entered_pose" + "stand" );
}

notetrackposecrouch( note, flagname )
{
	self.a.pose = "crouch";
	self notify( "entered_pose" + "crouch" );
	if ( self.a.crouchpain )
	{
		self.a.crouchpain = 0;
		self.health = 150;
	}
}

notetrackmovementstop( note, flagname )
{
	if ( issentient( self ) )
	{
		self.a.movement = "stop";
	}
}

notetrackmovementwalk( note, flagname )
{
	if ( issentient( self ) )
	{
		self.a.movement = "walk";
	}
}

notetrackmovementrun( note, flagname )
{
	if ( issentient( self ) )
	{
		self.a.movement = "run";
	}
}

notetrackalertnesscasual( note, flagname )
{
	if ( issentient( self ) )
	{
		self.a.alertness = "casual";
	}
}

notetrackalertnessalert( note, flagname )
{
	if ( issentient( self ) )
	{
		self.a.alertness = "alert";
	}
}

notetrackgravity( note, flagname )
{
	if ( issubstr( note, "on" ) )
	{
		self animmode( "gravity" );
	}
	else if ( issubstr( note, "off" ) )
	{
		self animmode( "nogravity" );
		self.nogravity = 1;
	}
	else
	{
		if ( issubstr( note, "code" ) )
		{
			self animmode( "none" );
			self.nogravity = undefined;
		}
	}
}

notetrackbodyfall( note, flagname )
{
	if ( isDefined( self.groundtype ) )
	{
		groundtype = self.groundtype;
	}
	else
	{
		groundtype = "dirt";
	}
	if ( issubstr( note, "large" ) )
	{
		self playsound( "fly_bodyfall_large_" + groundtype );
	}
	else
	{
		if ( issubstr( note, "small" ) )
		{
			self playsound( "fly_bodyfall_small_" + groundtype );
		}
	}
}

notetrackfootstep( note, flagname )
{
	if ( issubstr( note, "left" ) )
	{
		playfootstep( "J_Ball_LE" );
	}
	else
	{
		playfootstep( "J_BALL_RI" );
	}
	if ( !level.clientscripts )
	{
		self playsound( "fly_gear_run" );
	}
}

playfootstep( foot )
{
	if ( !level.clientscripts )
	{
		if ( !isai( self ) )
		{
			self playsound( "fly_step_run_dirt" );
			return;
		}
	}
	groundtype = undefined;
	if ( !isDefined( self.groundtype ) )
	{
		if ( !isDefined( self.lastgroundtype ) )
		{
			if ( !level.clientscripts )
			{
				self playsound( "fly_step_run_dirt" );
			}
			return;
		}
		groundtype = self.lastgroundtype;
	}
	else
	{
		groundtype = self.groundtype;
		self.lastgroundtype = self.groundtype;
	}
	if ( !level.clientscripts )
	{
		self playsound( "fly_step_run_" + groundtype );
	}
	[[ anim.optionalstepeffectfunction ]]( foot, groundtype );
}

notetrackfootscrape( note, flagname )
{
	if ( isDefined( self.groundtype ) )
	{
		groundtype = self.groundtype;
	}
	else
	{
		groundtype = "dirt";
	}
	self playsound( "fly_step_scrape_" + groundtype );
}

notetrackland( note, flagname )
{
	if ( isDefined( self.groundtype ) )
	{
		groundtype = self.groundtype;
	}
	else
	{
		groundtype = "dirt";
	}
	self playsound( "fly_land_npc_" + groundtype );
}

notetrackstartragdoll( note, flagname )
{
	if ( isDefined( self.noragdoll ) )
	{
		return;
	}
	self unlink();
	self startragdoll();
}



