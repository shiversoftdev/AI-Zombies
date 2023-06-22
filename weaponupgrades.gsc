MustangUpgrade()
{
	self notify("MustangUpgrade");
	self endon("MustangUpgrade");
	self endon("spawned_player");
	while( self hasweapon( "fiveseven_mp" ) && self HasUpgrade("fiveseven_mp") )
	{
		self waittill("weapon_fired", weapon);
		if( self GetCurrentWeapon() != "fiveseven_mp" )
		{
			self waittill("weapon_change");
			continue;
		}
		magicbullet("m32_mp", self GetEye(), (self GetNormalTrace()["position"]), self);
		if( isDefined( self.doubletap ) && self.doubletap )
			magicbullet("m32_mp", self GetEye(), (self GetNormalTrace()["position"]), self);
	}
}

RamboUpgrade()
{
	self notify("RamboUpgrade");
	self endon("RamboUpgrade");
	self endon("spawned_player");
	while( self hasweapon( "mk48_mp" ) && self HasUpgrade("mk48_mp") )
	{
		self waittill("weapon_fired", weapon);
		if( self GetCurrentWeapon() != "mk48_mp" )
		{
			self waittill("weapon_change");
			continue;
		}
		if( randomintrange(0,1337) > 1000 )
		{
			self SetWeaponAmmoClip( "mk48_mp", (self getweaponammoclip( "mk48_mp" ) + 1) );
		}
	}
}

PAP_Weapon_Function( weapon )
{
	self endon("STOP_PAP_" + weapon);
	fired = 0;
	while( self hasweapon( weapon ) && self HasUpgrade(weapon) )
	{
		self waittill("weapon_fired", _weapon);
		if( self GetCurrentWeapon() != weapon )
		{
			self waittill("weapon_change");
			continue;
		}
		fired++;
		if( fired > 1 )
		{
			self SetWeaponAmmoClip( _weapon, (self getweaponammoclip( _weapon ) + 1) );
			self notify("ammo_bought");
			fired = 0;
		}
	}
}

R870Upgraded()
{

}

LostUpgradeByWeaponChange( weapon )
{
	self endon("lost_upgrade_"+weapon);
	while( 1 )
	{
		self waittill("weapon_change");
		if( !self hasweapon( weapon ) )
		{
			self notify("lost_upgrade_"+weapon);
			self TakeSuperUpgrade( weapon );
		}
	}
}

GiveSuperUpgrade( wep, upgrade )
{
	if(!isdefined(self.superupgrades))
		self.superupgrades = [];
	TakeSuperUpgrade( wep );
	superupgrade = spawnstruct();
	superupgrade.name = wep;
	superupgrade.upgrade = upgrade;
	self.superupgrades = add_to_array(self.superupgrades, superupgrade, 0);
	self notify("super_upgrade");
}

GetSuperUpgrade( weapon )
{
	if( !isDefined( self.superupgrades ) )
		return -1;
	for( i = 0; i < self.superupgrades.size; i++ )
	{
		if( self.superupgrades[i].name == weapon )
			return self.superupgrades[i].upgrade;
	}
	return -1;
}

HasSuperUpgrade( weapon )
{
	if( !isDefined( self.superupgrades ) )
		return false;
	for( i = 0; i < self.superupgrades.size; i++ )
	{
		if( self.superupgrades[i].name == weapon )
			return true;
	}
	return false;
}

TakeSuperUpgrade( wep )
{
	if( !isDefined( self.superupgrades ) )
		return;
	for( i = 0; i < self.superupgrades.size; i++ )
	{
		if( self.superupgrades[i].name == wep )
			arrayremovevalue( self.superupgrades, self.superupgrades[i] );
	}
}

FireMeUp(attacker)
{
	playfx( level._effect["character_fire_death_torso"], (self.zombiemodel GetOrigin() + (0,50,0)));
	self dodamage( self.maxhealth / 3, self getorigin());
	wait 1;
	self dodamage( self.maxhealth / 3, self getorigin());
	wait 1;
	self dodamage( self.maxhealth / 3, self getorigin());
	self startragdoll();
}

UpgradedUpgradedWeapon( weapon, upgrade )
{
	self notify("lost_upgrade_"+weapon);
	self endon("lost_upgrade_"+weapon);
	self thread LostUpgradeByWeaponChange(weapon);
	while( 1 )
	{
		self waittill("hit_zombie", point);
		if( self GetCurrentWeapon() != weapon )
		{
			self waittill("weapon_change");
			continue;
		}
		if( randomintrange(0,100) > level.thepap.doubleupgrades[ upgrade ].activationchance )
			continue;
		if( upgrade == 0 )//0 blast furnace
		{
			PlayUpgradeFX( upgrade );
			for( i = 0; i < 40; i++ )
			{
				zombie = GetClosest( point, level.zombie_team );
				if( Distance(point, zombie GetOrigin() ) > 350 )
					break;
				zombie thread FireMeUp( self );
				wait .10;
			}
		}
		else if( upgrade == 1 )//thunderwall
		{
			PlayUpgradeFX( upgrade );
			count = 0;
			foreach( zombie in level.zombie_team )
			{
				if( Distance( Zombie GetOrigin(), point ) < 250 )
				{
					count++;
					zombie.thunderwall = true;
					Zombie DoDamage( Zombie.health + 1, zombie getorigin());
					Zombie startragdoll();
					angle = VectorNormalize((zombie GetOrigin()) - point);
					Zombie launchRagdoll((angle[0] * 200, angle[1] * 200, 300));
				}
			}
			self AddToPlayerScore( count * 100);
		}
		else if( upgrade == 2 )//dead wire
		{
			count = 0;
			PlayUpgradeFX( upgrade );
			for( i = 0; i < 15; i++ )
			{
				zombie = GetClosest( point, level.zombie_team );
				if( Distance(point, zombie GetOrigin() ) > 150 )
					break;
				playFx( level._effect["prox_grenade_player_shock"], (zombie.zombiemodel GetOrigin() + (0,50,0)));
				zombie Dodamage( zombie.health + 1, zombie GetOrigin());
				count++;
				zombie startragdoll();
				zombie PlaySound("wpn_taser_mine_zap");
				wait .15;
			}
			self AddToPlayerScore( count * 50 );
		}
		else if( upgrade == 3 )//3 fireworks
		{
			PlayUpgradeFX( upgrade );
			foreach( zombie in level.zombie_team )
			{
				if( Distance( zombie GetOrigin(), point ) < 750 )
				{
					MagicBullet( self GetCurrentWeapon(), self GetTagOrigin("tag_weapon_right"), zombie GetOrigin(), self);
					zombie dodamage( zombie.health + 1, zombie GetOrigin() );
					zombie startragdoll();
				}
			}
		}		
		wait level.thepap.doubleupgrades[ upgrade ].cooldown;
	}
}

PlayUpgradeFX( upgrade )
{
	//TODO
}

FateBringer()
{
	self notify("FateBringer");
	self endon("FateBringer");
	self endon("spawned_player");
	while( self hasweapon( "fnp45_mp" ) && self HasUpgrade("fnp45_mp") )
	{
		self waittill("weapon_fired", weapon);
		if( self GetCurrentWeapon() != "fnp45_mp" )
		{
			self waittill("weapon_change");
			continue;
		}
		trace = GetNormalTrace()["position"];
		playfx(level._effect[ "rcbombexplosion" ], trace);
		RadiusDamage( trace, 150, 21000, 50, self );
		self SetWeaponAmmoClip( weapon, (self getweaponammoclip( weapon ) - 4) );
		self notify("ammo_bought");
	}

}

RisingThunder()
{
	self notify("RisingThunder");
	self endon("RisingThunder");
	while( self hasweapon("usrpg_mp") )
	{
		self waittill("missile_fire", missile, weapon);
		if( self GetCurrentWeapon() != "usrpg_mp" || weapon != "usrpg_mp" )
		{
			self waittill("weapon_change");
			continue;
		}
		missile thread RisingMissile( self GetPlayerAngles(), self );
	}
}

RisingMissile( angle, attacker )
{
	angle = AnglesToForward( angle );
	lastorigin = undefined;
	while( isDefined( self ) )
	{
		lastorigin = self GetOrigin();
		foreach( zombie in level.zombie_team )
		{
			if( Distance(zombie GetOrigin(), self GetOrigin()) < 100 )
			{
				zombie dodamage( zombie.health + 1, zombie GetOrigin() );
				zombie startragdoll();
				zombie launchRagdoll((angle[0] * 200, angle[1] * 200, 50));
			}
		}
		wait .05;
		waittillframeend;
	}
	return lastorigin;
}

EyeOfTheStorm()
{
	self notify("RisingThunder");
	self endon("RisingThunder");
	self thread EyeOfTheStormMaxAmmo();
	while( self hasweapon("usrpg_mp") )
	{
		self waittill("missile_fire", missile, weapon);
		if( weapon != "usrpg_mp" )
		{
			self waittill("weapon_change");
			continue;
		}
		self thread EyeOftheStormMissile( missile );
	}
}

EyeOfTheStormMaxAmmo()
{
	self endon("RisingThunder");
	while( self hasweapon("usrpg_mp") )
	{
		wait 45;
		self givemaxammo("usrpg_mp");
	}
}

Eyeofthestormmissile( missile )
{
	origin = (missile RisingMissile( self GetPlayerAngles(), self ));
	if(!isDefined( origin ) )
		return;
	playfx(level._effect[ "rcbombexplosion" ], origin);
	wait .5;
	for( i = 0; i < 12; i++ )
	{
		playfx(level._effect[ "acousticsensor_friendly_light" ], origin );
		wait .25;
	}
	playfx(level._effect[ "acousticsensor_enemy_light" ], origin);
	wait .25;
	playfx(level._effect[ "acousticsensor_enemy_light" ], origin);
	wait .25;
	playfx(level._effect[ "rcbombexplosion" ], origin);
	foreach( zombie in level.zombie_team )
	{
		if( Distance( zombie GetOrigin(), origin ) < 750 )
		{
			MagicBullet( "usrpg_mp", origin + (0,0,25 ), zombie GetOrigin(), self );
			Missile_CreateAttractorEnt( zombie, 10000, 750 );
			wait .1;
		}
	}
}

