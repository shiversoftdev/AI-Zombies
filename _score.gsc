AddToPlayerScore( points )
{
	if( isDefined( level.doublepointsactive ) )
		points *= 2;
	self.pers[ "pointstowin" ] += points;
	self.pointstowin += points;
	self notify("score_event_zombies", points);
}

RemoveFromPlayerScore( points )
{
	self.pers[ "pointstowin" ] -= points;
	self.pointstowin -= points;
	self notify("score_event_zombies", (-1 * points));
}



