MPD_Adjustment()
{
	weapon = undefined;
	extradamage = 0;
	while( isDefined( self ) && isAlive( self ) )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		if( isDefined( level.zombieinstakill ) )
		{
			self dodamage( self.health + 1, self getorigin());
			attacker AddToPlayerScore( 100 );
			return;
		}
		if( !isDefined(mod) || mod != "MOD_MELEE" )
		{
			attacker notify("hit_zombie", point);
		}
		weapon = attacker getcurrentweapon();
		if( isDefined( mod ) && mod == "MOD_DODAMAGE" || mod == "MOD_DOMELEEDAMAGE" )
		{
			self dodamage( amount, self GetOrigin(), attacker );
		}
		if( isDefined( level.zombie_damage_table[ weapon ] ) && mod != "MOD_MELEE" && mod != "MOD_DOMELEEDAMAGE" )
		{
			extradamage = 0;
			if( mod == "MOD_HEAD_SHOT" )
			{
				if( attacker HasUpgrade(weapon) )
					extradamage += level.zombie_damage_table[ weapon ].upgradehead;
				else
					extradamage += level.zombie_damage_table[ weapon ].head;
				isHeadShot = true;
			}
			else
			{
				if( attacker HasUpgrade(weapon) )
					extradamage += level.zombie_damage_table[ weapon ].upgradebody;
				else
					extradamage += level.zombie_damage_table[ weapon ].body;
			}
			if( extradamage < 0 )
			{
				self.health -= extradamage;
				attacker AddToPlayerScore( 10 );
				continue;
			}
			else
			{
				if( (self.health - (amount + extradamage)) < 1 )
				{
					if( isDefined( mod ) && mod == "MOD_HEAD_SHOT" )
					{
						attacker AddToPlayerScore( 100 );
					}
					else
					{
						if( isDefined( attacker.pers["headshots"] ) )
						{
							if( !(level.script == "mp_downhill" && weapon == "fnp45_mp") && weapon != "usrpg_mp" )
							{
								attacker.pers["headshots"]--;
								attacker.headshots--;
							}
						}
						attacker AddToPlayerScore( 50 );
					}
				}
				else
				{
					attacker AddToPlayerScore( 10 );
				}
				if( isHeadshot )
				{
					self dodamage( extradamage, self getorigin(), attacker);
				}
				else
				{
					self dodamage( extradamage, self getorigin(), attacker);
				}
				continue;
			}
		}
		if( (self.health - amount) < 1 )
		{
			if( mod == "MOD_MELEE" || mod == "MOD_DOMELEEDAMAGE")
				attacker AddToPlayerScore( 130 );
			else
				attacker AddToPlayerScore( 50 );
		}
		else
		{
			attacker AddToPlayerScore( 10 );
		}
	}
}

InitDTable()
{
	level.zombie_damage_table = [];
	level.zombie_weapons = [];
	AddZombieWeapon( "fiveseven_mp", 0, 50, "FIVE SEVEN", 2000, 2000, "MUSTANG", undefined, 0, ::MustangUpgrade );
	AddZombieWeapon( "870mcs_mp", 1500, 4000, "REMINGTON 870 MCS", 4000, 8000, "R870 GAT BLASTER", undefined, 1, ::R870Upgraded );
	AddZombieWeapon( "beretta93r_mp", 80, 240, "BERETTA 93R", 1000, 1700, "B34R", undefined, 1, undefined );
	AddZombieWeapon( "sig556_mp", 200, 750, "SWAT556", 500, 1700, "SO556", undefined, 1, undefined );
	AddZombieWeapon( "minigun_mp", 999999, 999999, "DEATH MACHINE" );
	AddZombieWeapon( "an94_mp", 500, 900, "AN94", 1000, 1800, "ACTUATED NEUTRALIZER 9001", undefined, 1, undefined );
	AddZombieWeapon( "saritch_mp", 100, 200, "SMR", 400, 900, "SMILER", undefined, 1, undefined );
	if( level.script == "mp_nuketown_2020" )
	{
		AddZombieWeapon( "ballista_mp", 2000, 9000, "BALLISTA", 4000, 18000, "INFUSED ARBALEST", undefined, 1, undefined );
		AddZombieWeapon( "dsr50_mp", 4000, 14000, "DSR 50", 10000, 20000, "DEAD SPECIMEN REACTOR 5000", undefined, 1, undefined );
		AddZombieWeapon( "evoskorpion_mp", 100, 400, "SKORPION", 400, 900, "EVOLVED DEATH STALKER", undefined, 1, undefined );
		AddZombieWeapon( "hamr_mp", 700, 1400, "HAMR", 1600, 2500, "SLDG HAMR", undefined, 1, undefined );
		AddZombieWeapon( "hk416_mp", 150, 500, "M27", 1100, 2500, "MYSTIFIER", undefined, 1, undefined );
		AddZombieWeapon( "insas_mp", 500, 900, "MSMC", 1000, 2000, "MASTER MC", undefined, 1, undefined );
		AddZombieWeapon( "kard_mp", 200, 400, "KAP40", 400, 800, "WHO CARES", undefined, 1, undefined );
		AddZombieWeapon( "knife_ballistic_mp", 900, 18000, "BALLISTIC KNIFE", 1800, 18000, "THE KRAUSS REFIBRILLATOR", undefined, 1, undefined );//TODO
		AddZombieWeapon( "qbb95_mp", 800, 1500, "QBB LMG", 1600, 3000, "CQB HMG", undefined, 1, undefined );
		AddZombieWeapon( "saiga12_mp", 1300, 2500, "S12", 2000, 4000, "S13", undefined, 1, undefined );
		AddZombieWeapon( "srm1216_mp", 500, 1000, "M1216", 1000, 3600, "MESMERIZER", undefined, 1, undefined );
		AddZombieWeapon( "svu_mp", 1500, 5000, "SVU", 3500, 11000, "SHADOWY VEIL UTILIZER", undefined, 1, undefined );
		AddZombieWeapon( "tar21_mp", 500, 1500, "MTAR", 1000, 3000, "MINOTAUR", undefined, 1, undefined );
		AddZombieWeapon( "type95_mp", 250, 750, "TYPE25", 850, 1000, "STRAIN 25", undefined, 1, undefined );
		AddZombieWeapon( "mk48_mp", -49, 10000, "RAMBO", -49, 50000, "ERASER", undefined, 1, ::RamboUpgrade );
		AddZombieWeapon( "scar_mp", 600, 1100, "SCAR-H", 1200, 2700, "AGARTHAN REAPER", undefined, 1, undefined );
		AddZombieWeapon( "vector_mp", 200, 500, "VECTOR", 500, 1900, "SCALAR", undefined, 1, undefined );
		AddZombieWeapon( "peacekeeper_mp", 500, 1100, "PEACEKEEPER", 1000, 3000, "THE ENFORCER", undefined, 1, undefined );
		AddZombieWeapon( "qcw05_mp", 400, 1500, "CHICOM", 700, 1700, "SHITCOM", undefined, 1, undefined );
		AddZombieWeapon( "beretta93r_dw_mp", 80, 240, "BERETTA 93R DUAL WIELD", 1300, 1900, "B34R DUAL WIELD", undefined, 1, undefined  );
		AddZombieWeapon( "mp7_mp", 300, 600, "MP7", 700, 1400, "ZM7000", undefined, 1, undefined );
		AddZombieWeapon( "ksg_mp", 3000, 6000, "KSG", 5000, 14000, "MIST MAKER", undefined, 1, undefined );
		AddZombieWeapon( "lsat_mp", 1000, 3000, "LSAT", 2000, 6000, "FSIRT", undefined, 1, undefined );
		AddZombieWeapon( "judge_mp", 1400, 5000, "EXECUTIONER", 10000, 41057, "AFTERLIFE", undefined, 1, undefined );
	}
	if( level.script == "mp_downhill" )
	{
		AddZombieWeapon( "pdw57_mp", 400, 900, "PDW57", 900, 2000, "PREDICTIVE DEATH WISH 5700", undefined, 1, undefined );
		AddZombieWeapon( "peacekeeper_mp", 500, 1100, "PEACEKEEPER", 1000, 3000, "THE ENFORCER", undefined, 1, undefined );
		AddZombieWeapon( "as50_mp", 3000, 10000, "AS50", 6000, 19000, "AREA 51", undefined, 1, undefined );
		AddZombieWeapon( "sa58_mp", 1500, 6000, "FAL MK2", 2000, 9000, "WN AGAIN", undefined, 1, undefined );
		AddZombieWeapon( "fnp45_mp", 200, 900, "MYSTERIOUS HAND CANNON", 3100, 9142, "FATEBRINGER", undefined, 0, ::FateBringer );
		AddZombieWeapon( "xm8_mp", 600, 1200, "M8A1", 2000, 4000, "EXECUTIVE ORDER", undefined, 1, undefined );
		AddZombieWeapon( "scar_mp", 600, 1100, "SCAR-H", 1200, 2700, "AGARTHAN REAPER", undefined, 1, undefined );
		AddZombieWeapon( "vector_mp", 200, 500, "VECTOR", 500, 1900, "SCALAR", undefined, 1, undefined );
		AddZombieWeapon( "ksg_mp", 3000, 6000, "KSG", 5000, 14000, "MIST MAKER", undefined, 1, undefined );
		AddZombieWeapon( "lsat_mp", 1000, 3000, "LSAT", 2000, 6000, "FSIRT", undefined, 1, undefined );
		AddZombieWeapon( "saiga12_mp", 1300, 2500, "S12", 2000, 4000, "S13", undefined, 1, undefined );
		AddZombieWeapon( "ballista_mp", 2000, 9000, "BALLISTA", 4000, 18000, "INFUSED ARBALEST", undefined, 1, undefined );
		AddZombieWeapon( "dsr50_mp", 4000, 14000, "DSR 50", 10000, 20000, "DEAD SPECIMEN REACTOR 5000", undefined, 1, undefined );
	}
	if( level.script == "mp_uplink")
	{
		AddZombieWeapon( "dsr50_mp", 4000, 14000, "DSR 50", 10000, 20000, "DEAD SPECIMEN REACTOR 5000", undefined, 1, undefined );
		AddZombieWeapon( "mp7_mp", 300, 600, "MP7", 700, 1400, "ZM7000", undefined, 1, undefined );
		AddZombieWeapon( "ksg_mp", 3000, 6000, "KSG", 5000, 14000, "MIST MAKER", undefined, 1, undefined );
		AddZombieWeapon( "lsat_mp", 1000, 3000, "LSAT", 2000, 6000, "FSIRT", undefined, 1, undefined );
		AddZombieWeapon( "judge_mp", 1400, 5000, "EXECUTIONER", 10000, 41057, "AFTERLIFE", undefined, 1, undefined );
		AddZombieWeapon( "scar_mp", 600, 1100, "SCAR-H", 1200, 2700, "AGARTHAN REAPER", undefined, 1, undefined );
		AddZombieWeapon( "vector_mp", 200, 500, "VECTOR", 500, 1900, "SCALAR", undefined, 1, undefined );
		AddZombieWeapon( "usrpg_mp", 5000, 5000, "RISING THUNDER", 25000, 25000, "EYE OF THE STORM", ::RisingThunder, 0, ::EyeOfTheStorm );
		AddZombieWeapon( "as50_mp", 3000, 10000, "AS50", 6000, 19000, "AREA 51", undefined, 1, undefined );
		AddZombieWeapon( "sa58_mp", 1500, 6000, "FAL MK2", 2000, 9000, "WN AGAIN", undefined, 1, undefined );
		AddZombieWeapon( "qbb95_mp", 800, 1500, "QBB LMG", 1600, 3000, "CQB HMG", undefined, 1, undefined );
		AddZombieWeapon( "saiga12_mp", 1300, 2500, "S12", 2000, 4000, "S13", undefined, 1, undefined );
		AddZombieWeapon( "srm1216_mp", 500, 1000, "M1216", 1000, 3600, "MESMERIZER", undefined, 1, undefined );
	}
	if( level.script == "mp_paintball" )
	{
		//TODO Wonder weapon and full weapon list
		AddZombieWeapon( "srm1216_mp", 500, 1000, "M1216", 1000, 3600, "MESMERIZER", undefined, 1, undefined );
		AddZombieWeapon( "kard_mp", 200, 400, "KAP40", 400, 800, "WHO CARES", undefined, 1, undefined );
		AddZombieWeapon( "lsat_mp", 1000, 3000, "LSAT", 2000, 6000, "FSIRT", undefined, 1, undefined );
	}
}

AddZombieWeapon( weapon, body, head, name, upgradebody, upgradehead, upgradename, wonderweapon, doubleupgrade, papfunction )
{
	level.zombie_damage_table[ weapon ] = spawnstruct();
	level.zombie_damage_table[ weapon ].head = head;
	level.zombie_damage_table[ weapon ].body = body;
	level.zombie_damage_table[ weapon ].name = name;
	level.zombie_damage_table[ weapon ].upgradebody = upgradebody;
	level.zombie_damage_table[ weapon ].upgradehead = upgradehead;
	level.zombie_damage_table[ weapon ].upgradename = upgradename;
	level.zombie_damage_table[ weapon ].wonderweapon = wonderweapon;
	level.zombie_damage_table[ weapon ].weapon = weapon;
	level.zombie_damage_table[ weapon ].doubleupgrade = doubleupgrade;
	level.zombie_damage_table[ weapon ].papfunction = papfunction;
	level.zombie_weapons = add_to_array( level.zombie_weapons, weapon, 0);
}



















