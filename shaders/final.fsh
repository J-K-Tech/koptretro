#version 330 compatibility

uniform sampler2D DiffuseSampler;
#include "lib/Uniforms.inc"

varying vec2 texcoord;

const mat4 ditherTable = mat4(
    -4.0, 0.0, -3.0, 1.0,
    2.0, -2.0, 3.0, -1.0,
    -3.0, 1.0, -4.0, 0.0,
    3.0, -1.0, 2.0, -2.0
);

vec3 render(float PIXEL_FACTOR){
	vec2 size = PIXEL_FACTOR * vec2(1920.,1080.) /1920.;
    vec2 coor = floor( vec2(texcoord.x,texcoord.y) * size) ;
    vec2 uv = coor / size;   
                
   	// Get source color
    vec3 col = texture2D(DiffuseSampler, uv).rgb;

    // Dither
    col += ditherTable[int( coor.x ) % 4][int( coor.y ) % 4] * 0.005; // last number is dithering strength

    // Reduce colors    
    col = floor(col * float(BITS)) / float(BITS);    
   
    // Output to screen
    return col;
}




void main() {

	
	float redbits;
	float greenbits;
	float bluebits;
	if (BITS==8){
		redbits=3.0;
		greenbits=3.0;
		bluebits=2.0;
	}
	else if (BITS==12){
		redbits=4.0;
		greenbits=4.0;
		bluebits=4.0;
	}
	else {
		redbits=5.0;
		greenbits=5.0;
		bluebits=5.0;
	}
      

	vec3 color;
	if (DITHERING==true){
		float px;
		
		if (HIGHRES==true){px= 400.0;}
		
		else {px=240.0;}
		
		color=render(px);
		
	}



	else {
	float px;
	if (HIGHRES==true){
		px= 2000.0;}
	else {px=1000.0;}
	float dx = 5.0 * (1.0 / px);
      float dy = 10.0 * (1.0 / px);
      vec2 Coord = vec2(dx * floor(texcoord.x / dx),dy * floor(texcoord.y / dy));
	color = texture2D(DiffuseSampler, Coord).rgb;
	color.r+=0.01;
	color.g-=0.02;
	color.b+=0.01;
	float r = exp2(redbits)-1.0;
	float g = exp2(greenbits)-1.0;
	float b = exp2(bluebits)-1.0;

	color.r = mix(color.r+0.5/r, color.r*(1.0+0.5/r), 0.0);
	color.g = mix(color.g+0.5/g, color.g*(1.0+0.5/g), 0.0);
	color.b = mix(color.b+0.5/b, color.b*(1.0+0.5/b), 0.0);

	color = min(color, 1.0);


	color.r = floor(color.r*r)/r;
	color.g = floor(color.g*g)/g;
	color.b = floor(color.b*b)/b;
	color.r-=0.01;
	color.g+=0.02;
	color.b-=0.01;
	}
	gl_FragColor.rgb = color;
	gl_FragColor.a = 1.0;
}
