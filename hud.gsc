createString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isValue)
{
  if(level != self)
    hud = self createFontString(font, fontScale);
  else
    hud = level createServerFontString(font, fontScale);
  if( isDefined( input ) )
  {
	  if(!(isDefined(isValue) && isValue))
	    hud setText(input);
	  else
	    hud setValue(input);
  }
  hud setPoint(align, relative, x, y);
  hud.color = color;
  hud.alpha = alpha;
  hud.glowColor = glowColor;
  hud.glowAlpha = glowAlpha;
  hud.sort = sort;
  hud.alpha = alpha;
  hud.archived = false;
  hud.hideWhenInMenu = true;
  return hud;
}

createShader(shader, align, relative, x, y, width, height, color, alpha, sort)
{
	if( self != level )
    	hud = newClientHudElem(self);
    else
    	hud = newHudElem();
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
	hud setParent(level.uiParent);
    hud setShader(shader, width, height);
	hud setPoint(align, relative, x, y);
	hud.hideWhenInMenu = true;
	hud.archived = false;
    return hud;
}

makewp(icon)
{

	headicon = newhudelem();
	headicon.archived = 1;
	headicon.x = 8;
	headicon.y = 8;
	headicon.z = 8;
	headicon.alpha = 0.8;
	headicon setshader( icon, 15, 15 );
	headicon setwaypoint( 0 );
	headicon settargetent( self );
	return headicon;
}

AmmoCounter()
{
	self notify("stop_counter");
	self endon("stop_counter");
	self.AmmoCounter_Weaponname destroy();
	self.AmmoCounter_SuperUpgrade destroy();
	self.AmmoCounter_Stockammo destroy();
	self.AmmoCounter_Magammo destroy();
	self.AmmoCounter_Weaponname = createString(undefined, "objective", 1.3, "LEFT", "BOTTOM", 230, -7, (1,1,1), .9, (0,0,1), .3, 0);
	self.AmmoCounter_SuperUpgrade = createString(undefined, "objective", 1.3, "LEFT", "BOTTOM", 230, 6, (1,1,1), .9, (0,0,1), .3, 0);
	self.AmmoCounter_Stockammo = createString(undefined, "objective", 1.75, "LEFT", "BOTTOM", 265, -25, (1,1,1), .7, (0,0,1), .3, 0, 1);
	self.AmmoCounter_Magammo = createString(undefined, "objective", 2.25, "LEFT", "BOTTOM", 230, -25, (1,1,1), .9, (0,0,1), .3, 0, 1);
	weapon = "";
	while( 1 )
	{
		weaponprev = self GetCurrentWeapon();
		self waittill_any( "weapon_change", "weapon_fired", "reload", "ammo_bought", "super_upgrade" );
		HasUpgrade(weaponprev);
		weapon = self GetCurrentWeapon();
		if( self HasUpgrade(weapon) && isDefined( level.zombie_damage_table[ weapon ].upgradename ) )
		{
			self.AmmoCounter_Weaponname SetText( level.zombie_damage_table[ weapon ].upgradename );
		}
		else if( isDefined( level.zombie_damage_table[ weapon ].name ) )
		{
			self.AmmoCounter_Weaponname SetText( level.zombie_damage_table[ weapon ].name );
		}
		else
		{
			self.AmmoCounter_Weaponname SetText( "" );
		}
		self.AmmoCounter_Stockammo SetValue( self getweaponammostock( weapon ) );
		self.AmmoCounter_Magammo SetValue( self getweaponammoclip( weapon ) );
		if( self HasSuperUpgrade( weapon ) )
		{
			upgrade = GetSuperUpgrade( weapon );
			if( upgrade == 0 )
			{
				self.AmmoCounter_SuperUpgrade SetText("BLAST FURNACE");
				self.AmmoCounter_SuperUpgrade.color = (1,.2,.2);
			}
			else if( upgrade == 1 )
			{
				self.AmmoCounter_SuperUpgrade SetText("THUNDER WALL");
				self.AmmoCounter_SuperUpgrade.color = (.6,.6,.6);
			}
			else if( upgrade == 2 )
			{
				self.AmmoCounter_SuperUpgrade SetText("DEAD WIRE");
				self.AmmoCounter_SuperUpgrade.color = (0,.6,.6);
			}
			else if( upgrade == 3 )
			{
				self.AmmoCounter_SuperUpgrade SetText("DROP DEAD");
				self.AmmoCounter_SuperUpgrade.color = (.75,.75,0);
			}
		}
		else
		{
			self.AmmoCounter_SuperUpgrade SetText("");
		}
	}
}

ScoreCounter()
{
	self notify("stop_scorecounter");
	self endon("stop_scorecounter");
	self.score_hud destroy();
	self.score_hud = createString(undefined, "objective", 2.75, "RIGHT", "CENTER", 310, 130, (1,1,1), .9, (0,0,1), .2, 0, 1);
	self.score_hud SetValue( 0 );
	self thread ScoreAnim();
	while( 1 )
	{
		self waittill("score_event_zombies");
		self.score_hud SetValue( self.pers[ "pointstowin" ] );
	}
}

ScoreAnim()
{
	self endon("stop_scorecounter");
	self.scoreanim destroy();
	self.scoreanim = createString(undefined, "objective", 2.0, "LEFT", "CENTER", 320, 160, (1,1,1), 0, (.5,.5,0), .1, 0, 1);
	self.scoreanim.label = "";
	self.current_ascore = 0;
	self.scoreanim maps/mp/gametypes/_hud::fontpulseinit();
	color = (1,1,0);
	noanim = false;
	while( 1 )
	{
		self waittill("score_event_zombies", amount);
		noanim = false;
		if( self.current_ascore != 0 )
		{
			noanim = true;
			if( self.current_ascore > 0 && amount < 0 )
			{
				self.current_ascore = 0;
			}
			else if( self.current_ascore < 0 && amount > 0 )
			{
				self.current_ascore = 0;
			}
		}
		self.current_ascore += amount;
		if( self.current_ascore < 0 )
		{
			color = (1,0,0);
			self.scoreanim.label = &"-";
		}
		else
		{
			color = (1,1,0);
			self.scoreanim.label = &"+";
		}
		self.scoreanim.color = color;
		self.scoreanim setValue( abs( self.current_ascore ) );
		self.scoreanim thread ScoreAnimation( !noanim, self );
	}
}

ScoreAnimation( move, player )
{
	self notify("scoreanim");
	self endon("scoreanim");
	if( move )
	{
		if( self.y != 160 )
			self.y = 160;
		self fadeovertime(.25);
		self moveovertime(.25);
		self.y -= 30;
		self.alpha = 1;
		wait .25;
	}
	self maps/mp/gametypes/_hud::fontpulse( player );
	wait 2;
	player.current_ascore = 0;
	self fadeovertime(.25);
	self.alpha = 0;
	wait .25;
	self.y = 160;
}

AddPerkHud( perk )
{
	if(!isDefined( self.perkhud_zm ) )
		self.perkhud_zm = [];
	self.perkhud_zm = add_to_array( self.perkhud_zm, createShader(perk.perkshader, "CENTER", "BOTTOM", (-300 + (self.perkhud_zm.size * 35)), 5, 35, 35, (1,1,1), 1, 2), 0 );
	self.perkhud_zm[ self.perkhud_zm.size - 1 ] ScaleOverTime( .5, 25, 25 );
}

ClearPerkHud()
{
	if(!isDefined( self.perkhud_zm ))
		return;
	foreach( hud in self.perkhud_zm )
		hud destroy();
	self.perkhud_zm = [];
}

AddPowerUpHud( type )
{
	foreach( hud in level.poweruphuds )
	{
		hud moveovertime( .5 );
		hud.x -= 40;
	}
	if( type == "Double Points" )
	{
		hud = level createString("2x", "objective", 3, "CENTER", "BOTTOM", 0, 0, (1,1,1), 0, (0,0,1), .3, 2);
		hud moveovertime( .65 );
		hud fadeovertime( .65 );
		hud.y -= 30;
		hud.alpha = 1;
		level.poweruphuds[ level.poweruphuds.size ] = hud;
	}
	if( type == "Insta Kill" )
	{
		hud = level createShader("perk_tactical_mask", "CENTER", "BOTTOM", 0, 0, 35, 35, (1,1,1), 0, 2);
		hud moveovertime( .65 );
		hud fadeovertime( .65 );
		hud.y -= 30;
		hud.alpha = 1;
		level.poweruphuds[ level.poweruphuds.size ] = hud;
	}
	return hud;
}

RemovePowerHud( type )
{
	for( i = 0; i < level.poweruphuds.size; i++ )
	{
		hud = level.poweruphuds[i];
		if(hud.nametype == type )
		{
			hud fadeovertime( .5 );
			hud.alpha = 0;
			wait .5;
			hud destroy();
			arrayremovevalue( level.poweruphuds, hud );
			for( i = i - 1; i > 0; i--)
			{
				hud = level.poweruphuds[i];
				hud moveovertime( .5 );
				hud.x += 40;
			}
			return;
		}
	}
}



