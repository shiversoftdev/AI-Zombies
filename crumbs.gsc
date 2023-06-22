player_zombie_breadcrumb()
{
	self notify( "stop_player_zombie_breadcrumb" );
	self endon( "stop_player_zombie_breadcrumb" );
	self endon( "disconnect" );
	self endon( "spawned_spectator" );
	level endon( "intermission" );
	self.zombie_breadcrumbs = [];
	self.zombie_breadcrumb_distance = 576;
	self.zombie_breadcrumb_area_num = 3;
	self.zombie_breadcrumb_area_distance = 16;
	self store_crumb( self.origin );
	last_crumb = self.origin;
	while ( 1 )
	{
		wait_time = 0.1;
		while ( self.ignoreme )
		{
			wait wait_time;
		}
		store_crumb = 1;
		airborne = 0;
		crumb = self.origin;
		if ( !self isonground() && self isinvehicle() )
		{
			trace = bullettrace( self.origin + vectorScale( ( 0, 0, -1 ), 10 ), self.origin, 0, undefined );
			crumb = trace[ "position" ];
		}
		if ( !airborne && distancesquared( crumb, last_crumb ) < self.zombie_breadcrumb_distance )
		{
			store_crumb = 0;
		}
		if ( airborne && self isonground() )
		{
			store_crumb = 1;
			airborne = 0;
		}
		if ( isDefined( level.custom_breadcrumb_store_func ) )
		{
			store_crumb = self [[ level.custom_breadcrumb_store_func ]]( store_crumb );
		}
		if ( isDefined( level.custom_airborne_func ) )
		{
			airborne = self [[ level.custom_airborne_func ]]( airborne );
		}
		if ( store_crumb )
		{
			last_crumb = crumb;
			self store_crumb( crumb );
		}
		wait wait_time;
	}
}

store_crumb( origin )
{
	offsets = [];
	height_offset = 32;
	index = 0;
	j = 1;
	while ( j <= self.zombie_breadcrumb_area_num )
	{
		offset = j * self.zombie_breadcrumb_area_distance;
		offsets[ 0 ] = ( origin[ 0 ] - offset, origin[ 1 ], origin[ 2 ] );
		offsets[ 1 ] = ( origin[ 0 ] + offset, origin[ 1 ], origin[ 2 ] );
		offsets[ 2 ] = ( origin[ 0 ], origin[ 1 ] - offset, origin[ 2 ] );
		offsets[ 3 ] = ( origin[ 0 ], origin[ 1 ] + offset, origin[ 2 ] );
		offsets[ 4 ] = ( origin[ 0 ] - offset, origin[ 1 ], origin[ 2 ] + height_offset );
		offsets[ 5 ] = ( origin[ 0 ] + offset, origin[ 1 ], origin[ 2 ] + height_offset );
		offsets[ 6 ] = ( origin[ 0 ], origin[ 1 ] - offset, origin[ 2 ] + height_offset );
		offsets[ 7 ] = ( origin[ 0 ], origin[ 1 ] + offset, origin[ 2 ] + height_offset );
		i = 0;
		while ( i < offsets.size )
		{
			self.zombie_breadcrumbs[ index ] = offsets[ i ];
			index++;
			i++;
		}
		j++;
	}
}

