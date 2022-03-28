{ stdenv, lib, python2, python2Packages,
gnupg1, config, writeText, makeWrapper }:
let
configFile = writeText "mailgate.conf" ((builtins.readFile ./gpg-mailgate.conf.sample) + config);
in
stdenv.mkDerivation {
	pname = "gpg-mailgate";
	version = "0.0";

	src = ./.;
	phases = [ "installPhase" ];
	buildInputs = [ python2 python2Packages.m2crypto makeWrapper ];

	installPhase = ''
		mkdir -p $out/bin $out/lib/python
		BIN=$out/bin/gpg-mailgate
		cp $src/gpg-mailgate.py $BIN
		cp -r $src/GnuPG $out/lib/python/GnuPG
		patchShebangs $BIN
		wrapProgram $BIN \
			--set PYTHONPATH "$PYTHONPATH:$out/lib/python" \
			--set PATH "${lib.makeBinPath [ gnupg1 ]}" \
			--set GPG_MAILGATE_CONFIG ${configFile}
	'';
}
