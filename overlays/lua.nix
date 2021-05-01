final: prev:
with prev;
with lua5_3.pkgs;
{
  fennel = buildLuarocksPackage {
    pname = "fennel";
    version = "0.9.1-1";

    src = fetchurl {
      url    = "https://luarocks.org/fennel-0.9.1-1.src.rock";
      sha256 = "11sv6cmb4l7ain3p0wqf23n0966n2xls42ynigb7mdbdjy89afa0";
    };
    disabled = (luaOlder "5.1");
    propagatedBuildInputs = [ lua5_3 ];

    meta = with lib; {
      homepage = "https://fennel-lang.org/";
      description = "Lisp that compiles to Lua";
      license.fullName = "MIT";
    };
  };
}
