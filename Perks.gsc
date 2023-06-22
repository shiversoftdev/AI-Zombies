CreatePerk( location, offsetangles, perkname, perkfunction, cost, perkshader )
{
	perk = spawnstruct();
	perk.location = location;
	perk.offsetangles = offsetangles;
	perk.perkname = perkname;
	perk.perkfunction = perkfunction;
	perk.crate = Spawn("script_model", location);
	perk.crate SetModel("t6_wpn_supply_drop_ally");
	perk.crate.angles = offsetangles;
	perk.laptop = spawn("script_model", (0,0,0));
	perk.laptop SetModel("t6_wpn_briefcase_bomb_view");
	perk.laptop EnableLinkto();
	perk.laptop linkto( perk.crate, "", (0,0,15), (0,180,0) );
	perk.perkshader = perkshader;
	perk.cost = cost;
	perk.crate disconnectpaths();
	return perk;
}

PerkTrigger( perk )
{
	self endon("spawned_player");
	level endon("quick_revive_exhausted");
	if(!isDefined( self.perk_array ) )
		self.perk_array = [];
	while( 1 )
	{
		wait .25;
		if( Distance( self GetOrigin(), perk.location ) < 128 && bullettracepassed( perk.location, self GetEye(), 0, perk.crate ) && !self player_is_in_laststand() && !self.perkinhand )
		{
			if( isinarray(self.perk_array, perk.perkname ) )
				continue;
			self setlowermessage("Hold [{+usereload}] to buy "+perk.perkname + " (Cost: " + perk.cost + ")");
			while( Distance( self GetOrigin(), perk.location ) < 128 && bullettracepassed( perk.location, self GetEye(), 0, perk.crate ) && !self player_is_in_laststand() && !self.perkinhand )
			{
				if( self usebuttonpressed() )
				{
					wait .25;
					if(!self usebuttonpressed() )
						break;
					if( self.pers["pointstowin"] < perk.cost )
						break;
					self clearlowermessage(.1);
					self.perkinhand = 1;
					weapon = self getcurrentweapon();
					self disableweaponcycling();
					self RemoveFromPlayerScore( perk.cost );
					self giveweapon("briefcase_bomb_mp");
					self switchtoweapon("briefcase_bomb_mp");
					wait 3;
					self setBlur( 3, .01);
					wait .01;
					self setBlur( 0, .75);
					self switchtoweapon(weapon);
					wait .5;
					self takeweapon("briefcase_bomb_mp");
					self enableweaponcycling();
					self thread [[ perk.perkfunction ]]();
					self.perk_array = add_to_array( self.perk_array, perk.perkname, 0);
					self.perkinhand = 0;
					self thread AddPerkHud( perk );
					if( perk.perkname == "Quick Revive" && level.players.size < 2)
					{
						self.soloquickrevivesremaining--;
						if( self.soloquickrevivesremaining < 1 )
						{
							machine = perk;
							arrayremovevalue( level.perkmachines, machine);
							machine.crate MoveZ(100, 1);
							wait 1.1;
							machine.crate rotateRoll( 360, .5);
							wait .51;
							machine.crate rotateRoll( 360, .25);
							wait .251;
							machine.crate rotateRoll( 360, .25);
							wait .251;
							machine.crate MoveZ( -500, .5 );
							wait .51;
							machine.laptop unlink();
							machine.laptop delete();
							machine.crate delete();
							level notify("quick_revive_exhausted");
							return; //failsafe
						}
					}
					break;
				}
				wait .05;
				waittillframeend;
			}
			self clearlowermessage(.1);
		}
	}
}

QuickRevive()
{
	self endon("spawned_player");
	self.quickrevive = 1;
	self setperk("specialty_quickrevive");
	self waittill("entering_last_stand");
	self.quickrevive = 0;
	self unsetperk("specialty_quickrevive");
}

Juggernog()
{
	self endon("spawned_player");
	self.juggernog = true;
	self.maxhealth = 250;
	self.health = 250;
	self SetNormalHealth( 250 );
	self waittill("entering_last_stand");
	self.juggernog = false;
	self.maxhealth = 120;
	self.health = 120;
	self SetNormalHealth( 120 );
}

SpeedCola()
{
	self endon("spawned_player");
	self setperk("specialty_fastweaponswitch");
	self setperk("specialty_fastreload");
	self setperk("specialty_stalker");
	self waittill("entering_last_stand");
	self unsetperk("specialty_fastweaponswitch");
	self unsetperk("specialty_fastreload");
	self unsetperk("specialty_stalker");
}

Staminup()
{
	self endon("spawned_player");
	self setperk("specialty_sprintrecovery");
	self setperk("specialty_unlimitedsprint");
	self setperk("specialty_longersprint");
	self setperk("specialty_fastmantle");
	self waittill("entering_last_stand");
	self unsetperk("specialty_sprintrecovery");
	self unsetperk("specialty_unlimitedsprint");
	self unsetperk("specialty_longersprint");
	self unsetperk("specialty_fastmantle");
}

MuleKick()
{
	self endon("spawned_player");
	self.mulekick = true;
	self waittill("entering_last_stand");
	self.mulekick = false;
}

Doubletap()
{
	self endon("spawned_player");
	self setperk("specialty_rof");
	self setperk("specialty_bulletdamage");
	self thread DoubleTap20();
	self.doubletap = true;
	self waittill("entering_last_stand");
	self.doubletap = false;
	self unsetperk("specialty_rof");
	self unsetperk("specialty_bulletdamage");
}

DoubleTap20()
{
	self endon("entering_last_stand");
	while( 1 )
	{
		self waittill("weapon_fired", weapon );
		MagicBullet( weapon, self GetTagOrigin("tag_weapon_right"), self GetNormalTrace()["position"], self);
	}
}

PHDFlopper()
{
	self endon("spawned_player");
	self.divetonuke = 1;
	self thread specialty_divetonuke();
	self waittill("entering_last_stand");
	self.divetonuke = 0;
}

specialty_divetonuke()
{
	self endon("entering_last_stand");
	self endon("spawned_player");
	while( 1 )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		total = 0;
		/*
		if( isDefined( mod ) && mod == "MOD_FALLING" )
		{
			self.health += amount;
			if( self GetStance() == "prone" )
			{
				playfx(level._effect[ "rcbombexplosion" ], self GetOrigin());
				foreach( zombie in level.zombie_team )
				{
					if( Distance( self GetOrigin(), zombie GetOrigin() ) < 500 )
					{
						zombie dodamage( 10000, zombie GetOrigin() );
						total += 25;
					}
				}
				if( total > 0 )
				{
					self AddToPlayerScore( total );
				}
			}
		}
		*/
	}
}
