CreateWallWeapon( weapon, location, angles, cost, ammocost, papammocost )
{
	model = getWeaponModel(Weapon);
	Wep = spawn("script_model", location);
	Wep SetModel( model );
	Wep.angles = angles;
	Wep.cost = cost;
	Wep.ammocost = ammocost;
	Wep.papammocost = papammocost;
	Wep.name = weapon;
	return Wep;
}
has_powerup_weapon()
{
	return (self GetCurrentWeapon() == "minigun_mp");
}

WeaponTriggerMonitor( weapon )
{
	self notify("weapon_monitor_" + weapon.name);
	self endon("weapon_monitor_" + weapon.name);
	self endon("death");
	cost = 0;
	while( 1 )
	{
		wait .25;
		if( Distance( self GetOrigin(), weapon GetOrigin() ) < 128 && bullettracepassed( weapon GetOrigin(), self GetEye(), 0, self ))
		{
			if( self HasUpgrade( weapon.name ) )
			{
				self setlowermessage( "Press [{+usereload}] for ammo (Cost: " + weapon.papammocost + ")" );
				cost = weapon.papammocost;
			}
			else if( self HasWeapon( weapon.name ) )
			{
				self setlowermessage( "Press [{+usereload}] for ammo (Cost: " + weapon.ammocost + ")" );
				cost = weapon.ammocost;
			}
			else
			{
				self setlowermessage( "Press [{+usereload}] to purchase " + level.zombie_damage_table[ weapon.name ].name + " (Cost: " + weapon.cost + ")" );
				cost = weapon.cost;
			}
			while( Distance( self GetOrigin(), weapon GetOrigin() ) < 128 && isAlive( self ) && !self player_is_in_laststand() && !self has_powerup_weapon() && bullettracepassed( weapon GetOrigin(), self GetEye(), 0, self ))
			{
				if( self usebuttonpressed() )
				{
					wait .25;
					if( !self usebuttonpressed() )
					{
						break;
					}
					if( self HasUpgrade( weapon.name ) && self.pers[ "pointstowin" ] >= weapon.papammocost)
					{
						self GiveMaxAmmo( weapon.name );
						self RemoveFromPlayerScore( weapon.papammocost );
						self notify("ammo_bought");
					}
					else if( self HasWeapon( weapon.name ) && self.pers[ "pointstowin" ] >= weapon.ammocost)
					{
						self GiveMaxAmmo( weapon.name );
						self RemoveFromPlayerScore( weapon.ammocost );
						self notify("ammo_bought");
					}
					else if( self.pers[ "pointstowin" ] >= weapon.cost )
					{
						if( self GetWeaponsListPrimaries().size > 1 )
						{
							if( self.mulekick && self GetWeaponsListPrimaries().size > 2)
								self takeweapon( self getcurrentweapon() );
							else if( !self.mulekick )
								self takeweapon( self getcurrentweapon() );
						}
						self RemoveFromPlayerScore( weapon.cost );
						self giveweapon( weapon.name );
						self givemaxammo( weapon.name );
						self switchtoweapon( weapon.name );
						if( isDefined( level.zombie_damage_table[ weapon ].wonderweapon ) )
						{
							self thread [[ level.zombie_damage_table[ weapon ].wonderweapon ]]();
						}
					}
					while( self usebuttonpressed() )
						wait .05;
					break;
				}				
				wait .05;
				waittillframeend;
			}
			self clearLowerMessage( .1 );
		}		
	}
}

CreateMysteryBox( location, forwardvector, moving )
{
	level.currentboxhits = 0;
	box = spawnstruct();
	box.crates = [];
	box.crates[0] = spawn("script_model", (location + ((cos(forwardvector[1]), sin(forwardvector[1]), 1) * (-25,-25,0))));
	box.crates[1] = spawn("script_model", (location + ((cos(forwardvector[1]), sin(forwardvector[1]), 1) * (25,25,0))));
	box.crates[2] = spawn("script_model", (location + ((cos(forwardvector[1]), sin(forwardvector[1]), 1) * (-25,-25,12.5))));
	box.crates[3] = spawn("script_model", (location + ((cos(forwardvector[1]), sin(forwardvector[1]), 1) * (25,25,12.5))));
	box.location = location;
	box.forwardvector = forwardvector;
	box.inuse = false;
	foreach( crate in box.crates )
	{
		crate SetModel("t6_wpn_supply_drop_ally");
		crate.angles = ( forwardvector - (0,90,0) );
		crate Disconnectpaths();
	}
	if( isDefined( moving ) && moving )
	{
		foreach( player in level.players )
		{
			player thread MysteryBoxTrigger();
		}
	}
	level.thebox = box;
}

MysteryBoxTrigger()
{
	self endon("death");
	self endon("spawned_player");
	self notify("newboxtrigger");
	self endon("newboxtrigger");
	level endon("boxmove");
	while( 1 )
	{
		if( Distance( self GetOrigin(), level.thebox.location ) < 128 && !level.thebox.inuse && bullettracepassed( level.thebox.location GetOrigin(), self GetEye(), 0, level.thebox ))
		{
			self setlowermessage( "Hold [{+usereload}] for mystery box (Cost: 950)" );
			while( Distance( self GetOrigin(), level.thebox.location ) < 128 && isAlive( self ) && !self player_is_in_laststand() && !level.thebox.inuse && bullettracepassed( level.thebox.location GetOrigin(), self GetEye(), 0, level.thebox ))
			{
				if( self useButtonPressed() )
				{
					wait .25;
					if( !self usebuttonpressed() )
						break;
					if( self.pers["pointstowin"] >= 950 )
					{
						level.thebox.inuse = true;
						self RemoveFromPlayerScore( 950 );
						level.thebox thread RandomWeapon( self );
						self clearLowerMessage(.1);
						while( level.thebox.inuse )
							wait .05;
					}
					while( self useButtonPressed() )
						wait .05;
					break;
				}				
				wait .05;
				waittillframeend;
			}
			self clearLowerMessage(.1);
		}
		wait .25;
	}
}

RandomWeapon( player )
{
	level.currentboxhits++;
	table = array_copy( level.zombie_damage_table );
	table = array_randomize( level.zombie_damage_table );
	theboxweapon = Spawn("script_model", level.thebox.location + (0,0,12.5));
	theboxweapon SetModel( getWeaponModel("fiveseven_mp") );
	theboxweapon.angles = level.thebox.forwardvector;
	level.thebox.crates[2] MoveTo( level.thebox.crates[2] GetOrigin() + ((cos(level.thebox.forwardvector[1]) * -35),(sin(level.thebox.forwardvector[1]) * -35),0), .4);
	level.thebox.crates[3] MoveTo( level.thebox.crates[3] GetOrigin() + ((cos(level.thebox.forwardvector[1]) * 35),(sin(level.thebox.forwardvector[1]) * 35),0), .4);
	theboxweapon MoveZ( 25, 5 );
	for( i = 0; i < 23; i++ )
	{
		wait .25;
		mod = i;
		while( mod >= table.size )
			mod -= table.size;
		wep = table[ getarraykeys(table)[mod] ];
		model = getWeaponModel(wep.weapon);
		theboxweapon SetModel( model );
	}
	weapon = table[ getarraykeys(table)[ randomintrange(0, table.size)] ].weapon;
	while( player hasweapon( weapon ) || weapon == "minigun_mp" )
	{
		weapon = table[ getarraykeys(table)[randomintrange(0, table.size)] ].weapon;
		wait .05;
	}
	theboxweapon SetModel( getWeaponModel(weapon) );
	if( randomintrange(-1, level.currentboxhits * 100 ) > 400 )
	{
		level notify("boxmove");
		theboxweapon [[ game[ "set_player_model" ][ "allies" ][ "smg" ] ]]();
		theboxweapon.angles += (0,90,0);
		player AddToPlayerScore( 950 );
		wait 2;
		theboxweapon rotateyaw( 360, 1 );
		wait 1.01;
		theboxweapon rotateyaw( 360, .5 );
		wait .52;
		theboxweapon rotateyaw( 360, .25 );
		wait .26;
		theboxweapon MoveZ( 1000, 1 );
		theboxweapon rotateyaw( 360, .25 );
		wait .26;
		theboxweapon rotateyaw( 360, .25 );
		wait .26;
		level.thebox.crates[2] MoveTo( level.thebox.crates[2] GetOrigin() - ((cos(level.thebox.forwardvector[1]) * -35),(sin(level.thebox.forwardvector[1]) * -35),0), .4);
		level.thebox.crates[3] MoveTo( level.thebox.crates[3] GetOrigin() - ((cos(level.thebox.forwardvector[1]) * 35),(sin(level.thebox.forwardvector[1]) * 35),0), .4);
		theboxweapon rotateyaw( 360, .25 );
		wait .26;
		theboxweapon rotateyaw( 360, .25 );
		wait .26;
		theboxweapon delete();
		foreach( crate in level.thebox.crates )
			crate MoveZ( 100, 1 );
		wait 1.5;
		foreach( crate in level.thebox.crates )
			crate MoveZ( -500, 1 );
		wait 1.1;
		array_delete( level.thebox.crates );
		level.thebox delete();
		RandomLocation = level.boxlocations[ randomintrange(0, level.boxlocations.size) ];
		while( RandomLocation.location == level.thebox.location )
		{
			RandomLocation = level.boxlocations[ randomintrange(0, level.boxlocations.size) ];
			wait .01;
		}
		CreateMysteryBox( RandomLocation.location, RandomLocation.angles, 1 );
		return;
	}
	theboxweapon.name = weapon;
	theboxweapon thread TriggerWeapon( player, weapon, level.thebox.location );
	theboxweapon MoveZ( -25, 10 );
	theboxweapon WaittillNotifyOrTimeout( "weapon_taken", 10);
	theboxweapon notify("End_trigger_Monitor");
	level.thebox.crates[2] MoveTo( level.thebox.crates[2] GetOrigin() - ((cos(level.thebox.forwardvector[1]) * -35),(sin(level.thebox.forwardvector[1]) * -35),0), .4);
	level.thebox.crates[3] MoveTo( level.thebox.crates[3] GetOrigin() - ((cos(level.thebox.forwardvector[1]) * 35),(sin(level.thebox.forwardvector[1]) * 35),0), .4);
	theboxweapon delete();
	level.thebox.inuse = false;
}

TriggerWeapon( player, weapon, location )
{
	self endon("End_trigger_Monitor");
	self endon("newboxtrigger");
	level endon("boxmove");
	while( 1 )
	{
		if( Distance( player GetOrigin(), location ) < 128 && isAlive( player ) && !player player_is_in_laststand() && bullettracepassed( level.thebox.location GetOrigin(), self GetEye(), 0, level.thebox ))
		{
			player setlowermessage( "Hold [{+usereload}] for weapon" );
			while( Distance( player GetOrigin(), location ) < 128 && isAlive( player ) && !player player_is_in_laststand() && bullettracepassed( level.thebox.location GetOrigin(), self GetEye(), 0, level.thebox ))
			{
				if( player UseButtonPressed() )
				{
					wait .25;
					if( !player UseButtonPressed() )
						break;
					if( !player.mulekick && player GetWeaponsListPrimaries().size > 1 )
					{
						player takeweapon( player GetCurrentWeapon() );
					}
					else if( player GetWeaponsListPrimaries().size > 2 )
					{
						player takeweapon( player GetCurrentWeapon() );
					}
					player giveweapon(weapon);
					player switchtoweapon(weapon);
					player GiveMaxAmmo(weapon);
					player clearlowermessage(.1);
					self notify("weapon_taken");
					return;
				}				
				wait .05;
				waittillframeend;
			}			
			player clearlowermessage(.1);
		}
		wait .25;
	}
}


AddBoxLocation( angles, location )
{
	box = spawnstruct();
	box.location = location;
	box.angles = angles + (0,90,0);
	level.boxlocations = add_to_array( level.boxlocations, box, 0 );
}

CreatePAP( origin, rightvector )
{
	level.offangles = rightvector;
	pap = spawnstruct();
	pap.camos = [];
	pap.camos[0] = 44;
	pap.camos[1] = 43;
	pap.camos[2] = 31;
	pap.camos[3] = 32;
	pap.lastcamo = 0;
	pap.root = spawn("script_model", origin);
	pap.root SetModel("script_origin");
	pap.machine = [];
	pap.rollers = [];
	pap.machine[0] = SpawnLinkedCrate( (0,0,0), (-55,90,0), pap.root);
	pap.machine[1] = SpawnLinkedCrate( (40,0,30), (0,-90,90), pap.root);
	pap.machine[2] = SpawnLinkedCrate( (-40,0,30), (0,-90,90), pap.root);
	pap.machine[3] = SpawnLinkedCrate( (40,30,30), (0,-90,90), pap.root);
	pap.machine[4] = SpawnLinkedCrate( (-40,30,30), (0,-90,90), pap.root);
	pap.machine[5] = SpawnLinkedCrate( (40,60,30), (0,-90,90), pap.root);
	pap.machine[6] = SpawnLinkedCrate( (-40,60,30), (0,-90,90), pap.root);
	pap.machine[7] = SpawnLinkedCrate( (0,60,12.5), (0,90,0), pap.root);
	pap.machine[8] = SpawnLinkedCrate( (0,60,37.5), (0,90,0), pap.root);
	pap.machine[9] = SpawnLinkedCrate( (0,60,62.5), (0,90,0), pap.root);
	pap.machine[10] = SpawnLinkedCrate( (40,25,62.5), (-90,0,0), pap.root);
	pap.machine[11] = SpawnLinkedCrate( (-40,25,62.5), (-90,0,0), pap.root);
	pap.machine[12] = SpawnLinkedCrate( (40,37.5,62.5), (-90,0,0), pap.root);
	pap.machine[13] = SpawnLinkedCrate( (-40,37.5,62.5), (-90,0,0), pap.root);
	pap.machine[14] = SpawnLinkedCrate( (40,37.5,77.5), (-90,0,0), pap.root);
	pap.machine[15] = SpawnLinkedCrate( (-40,37.5,77.5), (-90,0,0), pap.root);
	pap.machine[16] = SpawnLinkedCrate( (0,60,77.5), (0,90,0), pap.root);
	pap.rollers[0] = SpawnLinkedCrate( (0,30,30), (0,90,0), pap.root);
	pap.rollers[1] = SpawnLinkedCrate( (0,30,70), (0,90,0), pap.root);
	pap.rollers[0] thread papBottomRoller();
	pap.rollers[1] thread papTopRoller();
	pap.root.angles = rightvector; //DO THIS LAST !!
	pap.doubleupgrades = [];
	pap.doubleupgrades[0] = spawnstruct();
	pap.doubleupgrades[0].cooldown = 30;
	pap.doubleupgrades[0].activationchance = 25;
	pap.doubleupgrades[1] = spawnstruct();
	pap.doubleupgrades[1].cooldown = 15;
	pap.doubleupgrades[1].activationchance = 35;
	pap.doubleupgrades[2] = spawnstruct();
	pap.doubleupgrades[2].cooldown = 7.5;
	pap.doubleupgrades[2].activationchance = 85;
	pap.doubleupgrades[3] = spawnstruct();
	pap.doubleupgrades[3].cooldown = 60;
	pap.doubleupgrades[3].activationchance = 45;
	level.thepap = pap;
	level.thepap.inuse = false;
	level.thepap.location = origin;
	level.thepap.rightvector = rightvector;
	wait 2;
	level notify("PAP_ENABLED"); //Power can notify
}

SpawnLinkedCrate( location, crateangles, machine)
{
	crate = spawn("script_model", location);
	crate SetModel("t6_wpn_supply_drop_ally");
	crate.angles = crateangles;
	crate EnableLinkTo();
	crate LinkTo(machine, "", location, crateangles);
	crate Disconnectpaths();
	return crate;
}

papBottomRoller()
{
	level endon("PAPTrigger");
	level waittill("PAP_ENABLED");
	self unlink();
	while( 1 )
	{
		self rotatePitch(360, 10);
		wait 10.01;
	}
}

papTopRoller()
{
	level endon("PAPTrigger");
	level waittill("PAP_ENABLED");
	self unlink();
	while( 1 )
	{
		self rotatePitch(-360, 10);
		wait 10.01;
	}
}

papBottomFastRoller()
{
	level endon("WEAPON_DONE");
	level waittill("PAP_GO");
	while( 1 )
	{
		self rotatePitch(360, 1);
		wait 1.01;
	}
}

papTopFastRoller()
{
	level endon("WEAPON_DONE");
	level waittill("PAP_GO");
	while( 1 )
	{
		self rotatePitch(-360, 1);
		wait 1.01;
	}
}

PAP_Trigger()
{
	self endon("spawned_player");
	self endon("death");
	cost = 10000;
	while( 1 )
	{
		wait .25;
		if( (Distance(self GetOrigin(), level.thepap.location) < 128) && !self player_is_in_laststand() && isAlive(self) && bullettracepassed( level.thepap.rollers[0] GetOrigin(), self GetEye(), 0, level.thepap.rollers[0] ) && !self has_powerup_weapon() && !level.thepap.inuse)
		{
			if( self HasUpgrade( self GetCurrentWeapon() ) )
			{
				if( !isDefined(level.zombie_damage_table[ self GetCurrentWeapon() ].doubleupgrade ) )
				{
					continue;
				}
				else if( !level.zombie_damage_table[ self GetCurrentWeapon() ].doubleupgrade )
					continue;
				self setLowerMessage("Hold [{+usereload}] to upgrade weapon (Cost: 5000)");
				cost = 5000;
			}
			else
			{
				self setLowerMessage("Hold [{+usereload}] to upgrade weapon (Cost: 10000)");
				cost = 10000;
			}
			weapon = self GetCurrentWeapon();
			while( (Distance(self GetOrigin(), level.thepap.location) < 128) && !self player_is_in_laststand() && isAlive(self) && bullettracepassed( level.thepap.rollers[0] GetOrigin(), self GetEye(), 0, level.thepap.rollers[0] ) && !self has_powerup_weapon() && !level.thepap.inuse && self GetCurrentWeapon() == weapon)
			{
				if( self usebuttonpressed() )
				{
					weapon = self getcurrentweapon();
					wait .25;
					if( !self usebuttonpressed() )
						break;
					if( self.pers["pointstowin"] < cost )
						break;
					self notify("STOP_PAP_" + weapon);
					self RemoveFromPlayerScore( cost );
					self takeweapon( weapon );
					self clearlowermessage( .1 );
					level.thepap.inuse = 1;
					weaponmodel = spawn("script_model", level.thepap.location + (0,0,45));
					weaponmodel SetModel(getWeaponModel(weapon));
					weaponmodel.angles = level.thepap.rightvector;
					wait .5;
					oldorigin = weaponmodel GetOrigin();
					weaponmodel MoveTo( (level.thepap.machine[8] GetOrigin()), 1 );
					level notify( "PAPTrigger" );
					level.thepap.rollers[0] thread papBottomFastRoller();
					level.thepap.rollers[1] thread papTopFastRoller();
					level notify("PAP_GO");
					wait 4;
					weaponmodel MoveTo( oldorigin, 1 );
					wait 1;
					level notify("WEAPON_DONE");
					level.thepap.rollers[0] thread papBottomRoller();
					level.thepap.rollers[1] thread papTopRoller();
					level notify("PAP_ENABLED");
					self thread UpgradedWeaponTrigger( weaponmodel, weapon, (cost == 10000) );
					weaponmodel WaittillNotifyOrTimeout( "pap_weapon_taken", 10);
					self notify("PAPTimeout");
					level.thepap.inuse = 0;
					weaponmodel delete();
					break;
				}
				wait .05;
				waittillframeend;
			}
			self clearlowermessage( .1 );
			while( self usebuttonpressed() )
				wait .05;
		}
	}
}

UpgradedWeaponTrigger( weaponobject, weapon, firstupgrade )
{
	self endon("PAPTimeout");
	while( 1 )
	{
		wait .25;
		if( Distance(self GetOrigin(), level.thepap.location) < 128 && !self player_is_in_laststand() && isAlive(self) && bullettracepassed( weaponobject GetOrigin(), self GetEye(), 0, weaponobject ) && !self has_powerup_weapon())
		{
			self setLowerMessage("Hold [{+usereload}] for weapon");
			while( Distance(self GetOrigin(), level.thepap.location) < 128 && !self player_is_in_laststand() && isAlive(self) && bullettracepassed( weaponobject GetOrigin(), self GetEye(), 0, weaponobject ) && !self has_powerup_weapon())
			{
				if( self UseButtonPressed() )
				{
					wait .25;
					if(!self usebuttonpressed() )
						break;
					upgrade_o = GetSuperUpgrade( weapon );
					if( !self.mulekick && self GetWeaponsListPrimaries().size > 1 )
					{
						self takeweapon( self GetCurrentWeapon() );
					}
					else if( self GetWeaponsListPrimaries().size > 2 )
					{
						self takeweapon( self GetCurrentWeapon() );
					}
					if( !firstupgrade )
					{
						camo = level.thepap.lastcamo;
						while( camo == level.thepap.lastcamo)
						{
							camo = level.thepap.camos[ randomintrange(0, level.thepap.camos.size) ];
							wait .01;
						}
						level.thepap.lastcamo = camo;
						self giveWeapon(weapon,0,true(camo,0,0,0,0));
					}
					else
					{
						self giveWeapon(weapon,0,true(39,0,0,0,0));
						self givemaxammo( weapon );
					}
					self switchtoweapon( weapon );
					self GiveUpgrade( weapon );
					if( !firstupgrade )
					{
						upgrade = randomintrange(0,4);
						while( upgrade == upgrade_o )
						{
							upgrade = randomintrange(0,4);
							wait .01;
						}
						self GiveSuperUpgrade( weapon, upgrade );
						self thread UpgradedUpgradedWeapon( weapon, upgrade );
					}
					self thread PAP_Weapon_Function( weapon );
					if( isdefined( level.zombie_damage_table[ weapon ].papfunction ) )
						self thread [[ level.zombie_damage_table[ weapon ].papfunction ]]();
					self clearlowermessage( .1 );
					weaponobject notify("pap_weapon_taken");
					return;
				}
				wait .05;
				waittillframeend;
			}			
			self clearLowerMessage( .1 );
		}
	}
}









