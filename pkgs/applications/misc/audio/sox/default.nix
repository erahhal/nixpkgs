{ config
, lib
, stdenv
, fetchzip
, autoreconfHook
, autoconf-archive
, pkg-config
, CoreAudio
, enableAlsa ? true
, alsa-lib
, enableLibao ? true
, libao
, enableLame ? config.sox.enableLame or false
, lame
, enableLibmad ? true
, libmad
, enableLibogg ? true
, libogg
, libvorbis
, enableOpusfile ? true
, opusfile
, enableFLAC ? true
, flac
, enablePNG ? true
, libpng
, enableLibsndfile ? true
, libsndfile
, enableWavpack ? true
, wavpack
  # amrnb and amrwb are unfree, disabled by default
, enableAMR ? false
, amrnb
, amrwb
, enableLibpulseaudio ? stdenv.isLinux
, libpulseaudio
}:

stdenv.mkDerivation rec {
  pname = "sox";
  version = "unstable-2021-05-09";

  src = fetchzip {
    url = "https://sourceforge.net/code-snapshots/git/s/so/sox/code.git/sox-code-42b3557e13e0fe01a83465b672d89faddbe65f49.zip";
    sha256 = "15rp55vr0h2954zl1rllsnriv64qab8fzsp0aprnpx1s5b14xjpm";
  };

  nativeBuildInputs = [ autoreconfHook autoconf-archive ]
    # configure.ac uses pkg-config only to locate libopusfile
    ++ lib.optional enableOpusfile pkg-config;

  patches = [ ./0001-musl-rewind-pipe-workaround.patch ];

  buildInputs =
    lib.optional (enableAlsa && stdenv.isLinux) alsa-lib
    ++ lib.optional enableLibao libao
    ++ lib.optional enableLame lame
    ++ lib.optional enableLibmad libmad
    ++ lib.optionals enableLibogg [ libogg libvorbis ]
    ++ lib.optional enableOpusfile opusfile
    ++ lib.optional enableFLAC flac
    ++ lib.optional enablePNG libpng
    ++ lib.optional enableLibsndfile libsndfile
    ++ lib.optional enableWavpack wavpack
    ++ lib.optionals enableAMR [ amrnb amrwb ]
    ++ lib.optional enableLibpulseaudio libpulseaudio
    ++ lib.optional stdenv.isDarwin CoreAudio;

  meta = with lib; {
    description = "Sample Rate Converter for audio";
    homepage = "http://sox.sourceforge.net/";
    maintainers = with maintainers; [ marcweber ];
    license = if enableAMR then licenses.unfree else licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
