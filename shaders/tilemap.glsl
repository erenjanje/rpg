
#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform Image tilemap_atlas;
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    ivec4 index_vector = ivec4(Texel(tex, texture_coords) * 255);
    int index = index_vector.r; // TODO: add green and blue after shifting them
    int y = index / 16;
    int x = index - (y * 16);
    vec2 tile = vec2(float(x), float(y)) / 16.0;
    vec2 in_tile_texcoord = mod(texture_coords, 1.0 / 16.0);
    vec4 texcolor = Texel(tilemap_atlas, tile + in_tile_texcoord);
    return texcolor;
}
#endif