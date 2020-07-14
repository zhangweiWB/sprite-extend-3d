export default `
precision highp float;
attribute vec3 position;
attribute vec3 next;
attribute vec3 prev;
attribute float side;
attribute vec4 color;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec2 uResolution;
uniform float uDPR;
uniform float uThickness;
uniform float uMiter;

varying vec4 vColor;

vec4 getPosition() {
    mat4 mvp = projectionMatrix * modelViewMatrix;
    vec4 current = mvp * vec4(position, 1);
    vec4 nextPos = mvp * vec4(next, 1);
    vec4 prevPos = mvp * vec4(prev, 1);
    vec2 aspect = vec2(uResolution.x / uResolution.y, 1);    
    vec2 currentScreen = current.xy / current.w * aspect;
    vec2 nextScreen = nextPos.xy / nextPos.w * aspect;
    vec2 prevScreen = prevPos.xy / prevPos.w * aspect;

    vec2 dir1 = normalize(currentScreen - prevScreen);
    vec2 dir2 = normalize(nextScreen - currentScreen);
    vec2 dir = normalize(dir1 + dir2);

    vec2 normal = vec2(-dir.y, dir.x);
    normal /= mix(1.0, max(0.3, dot(normal, vec2(-dir1.y, dir1.x))), uMiter);
    normal /= aspect;
    float pixelWidthRatio = 1.0 / (uResolution.y / uDPR);
    float pixelWidth = current.w * pixelWidthRatio;
    normal *= pixelWidth * uThickness;
    current.xy -= normal * side;
    return current;
}

void main() {
    gl_Position = getPosition();
    vColor = color;
}
`;