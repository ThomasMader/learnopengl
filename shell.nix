with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "learnopengl";
  buildInputs = [ dmd dub ];

  LD_LIBRARY_PATH="/run/opengl-driver/lib:${pkgs.glfw}/lib";
  DISPLAY=":1";
  XAUTHORITY="/run/user/1001/gdm/Xauthority";

  shellHook = ''
    echo For running the triangle example: dub run :hello_triangle
  '';
}
