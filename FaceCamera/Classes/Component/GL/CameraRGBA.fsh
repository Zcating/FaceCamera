#version 300 es

precision mediump float;

in highp vec2 outTexCoord;

out highp vec4 fragColor;


uniform sampler2D samplerRGBA;

void main()
{
    mediump vec3 yuv;
    lowp vec3 rgb;
    
////     Subtract constants to map the video range start at 0
//        yuv.x = (texture(SamplerY, texCoordVarying).r);// - (16.0/255.0));
//        yuv.yz = (texture(SamplerUV, texCoordVarying).ra - vec2(0.5, 0.5));
//        rgb = colorConversionMatrix * yuv;
//        fragColor = vec4(rgb, 1);
    
    fragColor = texture(samplerRGBA, outTexCoord);
}
