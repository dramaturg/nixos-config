{ pkgs, lib, config, noDev ? false, ... }:
let
  ampache = pkgs.stdenv.mkDerivation rec {
    name = "ampache-${version}";
    version = "4.0.0-develop";

    src = pkgs.fetchFromGitHub {
      owner = "ampache";
      repo = "ampache";
      rev = "bdf854344b099ec4b078e3caad9d2e15bdd9cbe7";
      sha256 = "1l4pyqy5l658ww5k91lrgmaxbqr2v96lw9cv37nlf8rx3gyaiqw7";
    };

    nativeBuildInputs = with pkgs; [
      unzip
      git
    ];
    buildInputs = with pkgs; [
      ffmpeg
    ];

    #nativeBuildInputs = with pkgs; [ openssl ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -pv $out/
      cp -r * $out/

      cp ${pkgs.writeText "ampache.cfg.php" ampacheConfig} \
         $out/config/ampache.cfg.php

      cd $out
    '';
  };

  ampacheConfig = ''
    ;#########################################################
    ; General Config                                         #
    ;#########################################################

    config_version = 40
    http_host = "${cfg.ampacheVHost}"

    ;#########################################################
    ; Database                                               #
    ;#########################################################

    database_hostname = "127.0.0.1"
    database_port = "3306"
    database_name = "ampache"
    database_username = "ampache"
    database_password = "lakdsfiurtamdfndsafi"

    ;#########################################################
    ; Session and Security                                   #
    ;#########################################################

    ; Cryptographic secret
    ; This MUST BE changed with your own secret key. Ampache-specific, just pick any random string you want.
    secret_key = "abcdefghijklmnoprqstuvwyz0123456"

    stream_length = 100000
    session_cookiesecure = 1

    ;#########################################################
    ; Program Settings                                       #
    ;#########################################################

    allow_zip_download = "true"
    allow_zip_types = "artist,album,playlist,search,tmp_playlist"

    ; Caching
    ; This turns the caching mechanisms on or off, due to a large number of
    ; problems with people with very large catalogs and low memory settings
    ; this is off by default as it does significantly increase the memory
    ; requirements on larger catalogs. If you have the memory this can create
    ; a 2-3x speed improvement.
    ; DEFAULT: false
    ;memory_cache = "false"

    lastfm_api_key = "d5df942424c71b754e54ce1832505ae2"
    lastfm_api_secret = ""

    wanted = "true"
    wanted_types = "album,compilation,official"
    wanted_auto_accept = "true"

    ; Broadcasts
    ; Allow users to broadcast music.
    ; This feature requires advanced server configuration, please take a look on the wiki for more information.
    ; DEFAULT: false
    ;broadcast = "false"

    channel = "true"
    live_stream = "true"
    podcast = "true"

    ; Web Socket address
    ; Declare the web socket server address
    ; DEFAULT: determined automatically
    ;websocket_address = "ws://localhost:8100"

    ;#########################################################
    ; OpenID login info (optional)                           #
    ;#########################################################

    ; Requires specific OpenID Provider Authentication Policy
    ; DEFAULT: none
    ; VALUES: PAPE_AUTH_MULTI_FACTOR_PHYSICAL,PAPE_AUTH_MULTI_FACTOR,PAPE_AUTH_PHISHING_RESISTANT
    ;openid_required_pape = ""


    ;#########################################################
    ; Public Registration settings, defaults to disabled     #
    ;#########################################################

    allow_public_registration = "true"
    admin_notify_reg = "true"
    admin_enable_required = "true"
    auto_user = "user"

    ;########################################################
    ; These options control the dynamic downsampling based  #
    ; on current usage                                      #
    ; *Note* Transcoding must be enabled and working        #
    ;########################################################

    max_bit_rate = "320"
    min_bit_rate = "48"

    ;######################################################
    ; These are commands used to transcode non-streaming
    ; formats to the target file type for streaming.

    ;;; Audio
    transcode_m4a = "required"
    transcode_flac = "required"
    transcode_mpc = "required"
    transcode_ogg = "allowed"
    transcode_oga      = required
    transcode_wav = "required"
    transcode_wma      = required
    transcode_ape     = required
    transcode_shn     = required
    transcode_mp3      = allowed

    ;;; Video
    transcode_avi = "allowed"
    transcode_mkv = "allowed"
    transcode_mpg = "allowed"
    transcode_mpeg     = allowed
    transcode_m4v      = allowed
    transcode_mp4      = allowed
    transcode_mov      = allowed
    transcode_wmv      = allowed
    transcode_ogv      = allowed
    transcode_divx     = allowed
    transcode_m2ts     = allowed
    transcode_webm     = allowed

    ; Default output format
    encode_target = "mp3"
    encode_video_target = "webm"
    encode_player_webplayer_target = mp3
    encode_player_api_target = mp3

transcode_cmd = "${pkgs.ffmpeg}/bin/ffmpeg"
    transcode_input = "-i %FILE%"
    encode_args_mp3 = "-vn -b:a %BITRATE%K -c:a libmp3lame -f mp3 pipe:1"
    encode_args_ogg = "-vn -b:a %BITRATE%K -c:a libvorbis -f ogg pipe:1"
    encode_args_opus = "-vn -b:a %BITRATE%K -c:a libopus -compression_level 10 -vsync 2 -f ogg pipe:1"
    encode_args_m4a = "-vn -b:a %BITRATE%K -c:a libfdk_aac -f adts pipe:1"
    encode_args_wav = "-vn -b:a %BITRATE%K -c:a pcm_s16le -f wav pipe:1"
    encode_args_flv = "-b:a %BITRATE%K -ar 44100 -ac 2 -v 0 -f flv -c:v libx264 -preset superfast -threads 0 pipe:1"
    encode_args_webm = "-q %QUALITY% -f webm -c:v libvpx -maxrate %MAXBITRATE%k -preset superfast -threads 0 pipe:1"
    encode_args_ts = "-q %QUALITY% -s %RESOLUTION% -f mpegts -c:v libx264 -c:a libmp3lame -maxrate %MAXBITRATE%k -preset superfast -threads 0 pipe:1"
    encode_args_ogv = "-codec:v libtheora -qscale:v 7 -codec:a libvorbis -qscale:a 5 -f ogg pipe:1"

    ; Encoding arguments to retrieve an image from a single frame
    encode_get_image = "-ss %TIME% -f image2 -vframes 1 pipe:1"

    ; Encoding argument to encrust subtitle
    encode_srt = "-vf \"subtitles='%SRTFILE%'\""

    ; Encode segment frame argument
    encode_ss_frame = "-ss %TIME%"

    ; Encode segment duration argument
    encode_ss_duration = "-t %DURATION%"

    ; If Ampache is behind an https reverse proxy, force use HTTPS protocol.
    ;Default: false
    force_ssl = "true"

    ;#########################################################
    ;  Mail Settings                                         #
    ;#########################################################

    mail_enable = "true"
    mail_domain = "ds.ag"
    mail_user = "service@ds.ag"

    mail_host = "sslout.df.eu"
    mail_port = "587"
    mail_secure_smtp = "tls"
    mail_auth = "true"
    mail_auth_user = "service@ds.ag"
    mail_auth_pass = "S3rv1ce1982!"

    common_abbr = "divx,xvid,dvdrip,hdtv,lol,axxo,repack,xor,pdtv,real,vtv,caph,2hd,proper,fqm,uncut,topaz,tvt,notv,fpn,fov,orenji,0tv,omicron,dsr,ws,sys,crimson,wat,hiqt,internal,brrip,boheme,vost,vostfr,fastsub,addiction,x264,LOL,720p,1080p,YIFY,evolve,fihtv,first,bokutox,bluray,tvboom,info"
  '';
  #ampachePath = import ampache;
  cfg = config;
in
{
  imports = [
    ./server.nix
  ];

  options = {
    #ampacheWebRoot = lib.mkOption {
    #  default = "/var/www/ampache";
    #};
    ampacheVHost = lib.mkOption {
      type = lib.types.str;
      default = "sound.w.ds.ag";
    };
    smtp = {
      server = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "localhost";
        description = ''
          Hostname to send outgoing mail. Null to use the system MTA.
        '';
      };

      port = lib.mkOption {
        type = lib.types.int;
        default = 25;
        description = ''
          Port used to connect to SMTP server.
        '';
      };

      login = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          SMTP authentication login used when sending outgoing mail.
        '';
      };

      password = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          SMTP authentication password used when sending outgoing mail.
          ATTENTION: The password is stored world-readable in the nix-store!
        '';
      };
    };
    database = {
      manage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether I should manage the (local) mysql database";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        description = "Host of the MySQL database.";
      };

      port = lib.mkOption {
        type = lib.types.int;
        default = 5432;
        description = "The database's port.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "ampache";
        description = "Name of the database";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "ampache";
        description = "The database user";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          The database user's password. 'null' if no password is set.
        '';
      };
    };
  };

  config = {
    environment.systemPackages = [ ampache ];

    services.nginx = {
      enable = lib.mkDefault true;
      virtualHosts."${cfg.ampacheVHost}" = {
        #root = cfg.ampacheWebRoot;
        root = ampache;
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          index index.php;

          # Use secure headers to avoid XSS and many other things
          add_header X-Content-Type-Options nosniff;
          add_header X-XSS-Protection "1; mode=block";
          add_header X-Robots-Tag none;
          add_header X-Download-Options noopen;
          add_header X-Permitted-Cross-Domain-Policies none;
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header Referrer-Policy "no-referrer";
          add_header Content-Security-Policy "script-src 'self' 'unsafe-inline' 'unsafe-eval'; frame-src 'self'; object-src 'self'";

          # Avoid information leak
          server_tokens off;
          fastcgi_hide_header X-Powered-By;

          # Rewrite rule for Subsonic backend
          if ( !-d $request_filename ) {
            rewrite ^/rest/(.*).view$ /rest/index.php?action=$1 last;
            rewrite ^/rest/fake/(.+)$ /play/$1 last;
          }

          # Rewrite rule for Channels
          if (!-d $request_filename){
            rewrite ^/channel/([0-9]+)/(.*)$ /channel/index.php?channel=$1&target=$2 last;
          }

          # Beautiful URL Rewriting
          rewrite ^/play/ssid/(\w+)/type/(\w+)/oid/([0-9]+)/uid/([0-9]+)/name/(.*)$ /play/index.php?ssid=$1&type=$2&oid=$3&uid=$4&name=$5 last;
          rewrite ^/play/ssid/(\w+)/type/(\w+)/oid/([0-9]+)/uid/([0-9]+)/client/(.*)/noscrobble/([0-1])/name/(.*)$ /play/index.php?ssid=$1&type=$2&oid=$3&uid=$4&client=$5&noscrobble=$6&name=$7 last;
          rewrite ^/play/ssid/(.*)/type/(.*)/oid/([0-9]+)/uid/([0-9]+)/client/(.*)/noscrobble/([0-1])/player/(.*)/name/(.*)$ /play/index.php?ssid=$1&type=$2&oid=$3&uid=$4&client=$5&noscrobble=$6&player=$7&name=$8 last;
          rewrite ^/play/ssid/(.*)/type/(.*)/oid/([0-9]+)/uid/([0-9]+)/client/(.*)/noscrobble/([0-1])/transcode_to/(w+)/bitrate/([0-9]+)/player/(.*)/name/(.*)$ /play/index.php?ssid=$1&type=$2&oid=$3&uid=$4&client=$5&noscrobble=$6&transcode_to=$7&bitrate=$8&player=$9&name=$10 last;

          # the following line was needed for me to get downloads of single songs to work
          rewrite ^/play/ssid/(.*)/type/(.*)/oid/([0-9]+)/uid/([0-9]+)/action/(.*)/name/(.*)$ /play/index.php?ssid=$1&type=$2&oid=$3&uid=$4action=$5&name=$6 last;
        '';
        locations = {
          "/play".extraConfig = ''
            if (!-e $request_filename) {
              rewrite ^/play/art/([^/]+)/([^/]+)/([0-9]+)/thumb([0-9]*)\.([a-z]+)$ /image.php?object_type=$2&object_id=$3&auth=$1;
              break;
            }

            rewrite ^/([^/]+)/([^/]+)(/.*)?$ /play/$3?$1=$2;
            rewrite ^/(/[^/]+|[^/]+/|/?)$ /play/index.php last;
            break;
          '';
          "/rest".extraConfig = ''
            limit_except GET POST {
              deny all;
            }
          '';
          "~ /bin/".extraConfig = ''
            deny all;
            return 403;
          '';
          "~ /config/".extraConfig = ''
            deny all;
            return 403;
          '';
          "/".extraConfig = ''
            limit_except GET POST HEAD{
              deny all;
            }
          '';
          "~ \.php$".extraConfig = ''
            fastcgi_read_timeout 600s;

            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/${cfg.ampacheVHost}-phpfpm.sock;

            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
          '';
          "/ws".extraConfig = ''
            # Rewrite rule for WebSocket
            location /ws {
                  rewrite ^/ws/(.*) /$1 break;
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "upgrade";
                  proxy_set_header Host $host;
                  proxy_pass http://127.0.0.1:8100/;
            }
          '';
        };
      };
    };

      #;extension=${pkgs.phpPackages.apcu}/lib/php/extensions/apcu.so
    services.phpfpm.pools = {
      "${cfg.ampacheVHost}" = {
        listen = "/var/run/${cfg.ampacheVHost}-phpfpm.sock";
      phpOptions = ''
        ; Maximum allowed size for uploaded files.
        upload_max_filesize = 40M

        ; Must be greater than or equal to upload_max_filesize
        post_max_size = 40M

      '';
        extraConfig = ''
          user = nginx
          group = nginx
          listen.owner = nginx
          listen.group = nginx

          pm = dynamic
          pm.max_children = 32
          pm.max_requests = 500
          pm.start_servers = 2
          pm.min_spare_servers = 2
          pm.max_spare_servers = 5

          php_admin_value[error_log] = 'stderr'
          php_admin_flag[log_errors] = on
          env[PATH] = ${lib.makeBinPath [ pkgs.php ]}
          catch_workers_output = yes
        '';
      };
    };

    services.mysql = {
      enable = lib.mkDefault true;
      ensureDatabases = [
        "ampache"
      ];
      ensureUsers = [
        {
          name = "ampache";
          ensurePermissions = {
            "ampache.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    services.mysqlBackup.databases = [ "ampache" ];
  };
}
