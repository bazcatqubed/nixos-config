{ lib, rustPlatform, fetchFromGitHub, cmake, pkg-config, openssl }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastn";
  version = "0.4.109";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-zeiTjZiYlhzld1wrTkLG8EWEmKwPiH3JjVpTnRW9nJA=";
  };

  cargoHash = "sha256-0hXOqfid2kyCCLJpg2Q/0aDUXIis6/YTEioQJWmCqcc=";
  cargoBuildFeatures = [ "edition2024" ];

  nativeBuildInputs = [ rustPlatform.bindgenHook cmake pkg-config ];
  buildInputs = [ openssl ];

  checkFlags = [ "--skip=tests::fbt" ];

  meta = with lib; {
    homepage = "https://fastn.com/";
    description = "An integrated development environment for FTD";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "fastn";
  };
})
