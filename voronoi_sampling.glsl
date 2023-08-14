// Store shift in each center in pseudo-random texture.
vec2 getCellCenterShift(ivec2 tc)
{
	return texelFetch( iChannel1, tc % textureSize(iChannel1, 0).xy, 0 ).xy * 0.8 + 0.1;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	int mip= 3;
	vec2 tc= 0.5 * fragCoord / float(1 << mip);

	// Fetch nearest cells and calculate vector to center.
	ivec2 tc_start= ivec2( floor( tc - vec2( 0.5, 0.5 ) ) );
	ivec2 tc_00= tc_start;
	ivec2 tc_10= tc_start + ivec2(1, 0);
	ivec2 tc_01= tc_start + ivec2(0, 1);
	ivec2 tc_11= tc_start + ivec2(1, 1);
	vec2 vec_00= getCellCenterShift(tc_00) + vec2(tc_00) - tc;
	vec2 vec_10= getCellCenterShift(tc_10) + vec2(tc_10) - tc;
	vec2 vec_01= getCellCenterShift(tc_01) + vec2(tc_01) - tc;
	vec2 vec_11= getCellCenterShift(tc_11) + vec2(tc_11) - tc;
	// Calculate square distance. Do not need to calculate proper distance (with square root).
	float dist_00 = dot(vec_00, vec_00);
	float dist_10 = dot(vec_10, vec_10);
	float dist_01 = dot(vec_01, vec_01);
	float dist_11 = dot(vec_11, vec_11);

	// Select nearest point.
	ivec2 tc_nearest= tc_00;
	float dist_nearest= dist_00;
	if( dist_10 < dist_nearest )
	{
		dist_nearest= dist_10;
		tc_nearest= tc_10;
	}
	if( dist_01 < dist_nearest )
	{
		dist_nearest= dist_01;
		tc_nearest= tc_01;
	}
	if( dist_11 < dist_nearest )
	{
		dist_nearest= dist_11;
		tc_nearest= tc_11;
	}

	float grad_scale= 0.85 - sqrt(dist_nearest) * 0.3;
	fragColor= grad_scale * texelFetch( iChannel0, tc_nearest % textureSize(iChannel0, mip).xy, mip );
}
