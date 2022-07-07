{composerEnv, fetchurl, fetchgit ? null, fetchhg ? null, fetchsvn ? null, noDev ? false}:

let
  packages = {
    "Afterster/php-echonest-api" = {
      targetDir = "";
      src = fetchgit {
        name = "Afterster-php-echonest-api-master";
        url = "https://github.com/Afterster/php-echonest-api.git";
        rev = "master";
        sha256 = null;
      };
    };
    "aehlke/tag-it" = {
      targetDir = "";
      src = fetchgit {
        name = "aehlke-tag-it-v2.0";
        url = "https://github.com/aehlke/tag-it.git";
        rev = "v2.0";
        sha256 = "12pyw16j1r6fnvkf84zw25x794mswkggiddfn542l65lxdgnmr0s";
      };
    };
    "ampache/ampacheapi-php" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ampache-ampacheapi-php-7185626d7bf806e9b25927a66dbca5d9ce64d319";
        src = fetchurl {
          url = https://api.github.com/repos/ampache/ampacheapi-php/zipball/7185626d7bf806e9b25927a66dbca5d9ce64d319;
          sha256 = "091z63laxjnh34id8lqyh64wwfzahdr8ng7wxb79dwygp8vxc7ga";
        };
      };
    };
    "aterrien/jQuery-Knob" = {
      targetDir = "";
      src = fetchgit {
        name = "aterrien-jQuery-Knob-1.2.11";
        url = "https://github.com/aterrien/jQuery-Knob.git";
        rev = "1.2.11";
        sha256 = "0qw1drcddanipbh4vsr0scgl8p1rsrlvjmk6psv7j6p9lkyqr6lw";
      };
    };
    "blueimp/jQuery-File-Upload" = {
      targetDir = "";
      src = fetchgit {
        name = "blueimp-jQuery-File-Upload-9.11.2";
        url = "https://github.com/blueimp/jQuery-File-Upload.git";
        rev = "9.11.2";
        sha256 = "10k6dijknym7idls50l9zip1yz3mrqi9z2nx8kd66y0w25i5r5f7";
      };
    };
    "carhartl/jquery-cookie" = {
      targetDir = "";
      src = fetchgit {
        name = "carhartl-jquery-cookie-v1.4.1";
        url = "https://github.com/carhartl/jquery-cookie.git";
        rev = "v1.4.1";
        sha256 = "0x1vjj69y5l5p405fv4fm41m0dp9ivjvsdbhcp14kg1g99z2ssvj";
      };
    };
    "cboden/ratchet" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "cboden-ratchet-84df35d2a6576985b9e81b564d3c25809f8d647e";
        src = fetchurl {
          url = https://api.github.com/repos/ratchetphp/Ratchet/zipball/84df35d2a6576985b9e81b564d3c25809f8d647e;
          sha256 = "0b1ka08lc4fg0gkw7z9kj9pyw5gn9430mjz5gl70aww6dyhsafrx";
        };
      };
    };
    "components/bootstrap" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-bootstrap-427f4d414fc6ae8385aee02b7efc8e391eb141ad";
        src = fetchurl {
          url = https://api.github.com/repos/components/bootstrap/zipball/427f4d414fc6ae8385aee02b7efc8e391eb141ad;
          sha256 = "07mw1kw47bs1fa0j1q6mad3hgffif9hmalfns6gwx9cmw1x30g9h";
        };
      };
    };
    "components/jquery" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-jquery-981036fcb56668433a7eb0d1e71190324b4574df";
        src = fetchurl {
          url = https://api.github.com/repos/components/jquery/zipball/981036fcb56668433a7eb0d1e71190324b4574df;
          sha256 = "1cq213lrpkqj6ynvxlyfj1vmxzdka3ifyzf04lxmq33svdchzb3v";
        };
      };
    };
    "components/jqueryui" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-jqueryui-44ecf3794cc56b65954cc19737234a3119d036cc";
        src = fetchurl {
          url = https://api.github.com/repos/components/jqueryui/zipball/44ecf3794cc56b65954cc19737234a3119d036cc;
          sha256 = "1y0ppxk44jkxbh38i05sg0zcgk927s5wy6sjngwr5qifibqbcbhk";
        };
      };
    };
    "composer/semver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-semver-46d9139568ccb8d9e7cdd4539cab7347568a5e2e";
        src = fetchurl {
          url = https://api.github.com/repos/composer/semver/zipball/46d9139568ccb8d9e7cdd4539cab7347568a5e2e;
          sha256 = "11nq81abq684v12xfv6xg2y6h8fhyn76s50hvacs51sqqs926i0d";
        };
      };
    };
    "composer/xdebug-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-xdebug-handler-46867cbf8ca9fb8d60c506895449eb799db1184f";
        src = fetchurl {
          url = https://api.github.com/repos/composer/xdebug-handler/zipball/46867cbf8ca9fb8d60c506895449eb799db1184f;
          sha256 = "0y4axhr65ygd2a619xrbfd3yr02jxnazf3clfxrzd63m1jwc5mmx";
        };
      };
    };
    "doctrine/annotations" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-annotations-53120e0eb10355388d6ccbe462f1fea34ddadb24";
        src = fetchurl {
          url = https://api.github.com/repos/doctrine/annotations/zipball/53120e0eb10355388d6ccbe462f1fea34ddadb24;
          sha256 = "15fnvg1mlhrzqnp5pr31d12x02dg9v4czklx0cc9srhb7053dmyx";
        };
      };
    };
    "doctrine/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-cache-d768d58baee9a4862ca783840eca1b9add7a7f57";
        src = fetchurl {
          url = https://api.github.com/repos/doctrine/cache/zipball/d768d58baee9a4862ca783840eca1b9add7a7f57;
          sha256 = "1kljhw4gqp12iz88h6ymsrlfir2fis7icn6dffyizfc1csyb4s2i";
        };
      };
    };
    "doctrine/lexer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-lexer-83893c552fd2045dd78aef794c31e694c37c0b8c";
        src = fetchurl {
          url = https://api.github.com/repos/doctrine/lexer/zipball/83893c552fd2045dd78aef794c31e694c37c0b8c;
          sha256 = "0cyh3vwcl163cx1vrcwmhlh5jg9h47xwiqgzc6rwscxw0ppd1v74";
        };
      };
    };
    "evenement/evenement" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "evenement-evenement-6ba9a777870ab49f417e703229d53931ed40fd7a";
        src = fetchurl {
          url = https://api.github.com/repos/igorw/evenement/zipball/6ba9a777870ab49f417e703229d53931ed40fd7a;
          sha256 = "12iymi47ggkxkgvxxbg5si3h4fvqknvznckb71a07x0hbsmdc6w4";
        };
      };
    };
    "friendsofphp/php-cs-fixer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "friendsofphp-php-cs-fixer-f9522af772c6e9d2d381729cf2788c95ce2744de";
        src = fetchurl {
          url = https://api.github.com/repos/FriendsOfPHP/PHP-CS-Fixer/zipball/f9522af772c6e9d2d381729cf2788c95ce2744de;
          sha256 = "1s4l4spazv7kdl2wlbcwnx2nparqkn3ss017127ax5hl7csq0f6j";
        };
      };
    };
    "gettext/gettext" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "gettext-gettext-93176b272d61fb58a9767be71c50d19149cb1e48";
        src = fetchurl {
          url = https://api.github.com/repos/oscarotero/Gettext/zipball/93176b272d61fb58a9767be71c50d19149cb1e48;
          sha256 = "0048a41rz945nwjmvwzs2ic6blpdgg93wibb79c106vwz6dcjpvw";
        };
      };
    };
    "gettext/languages" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "gettext-languages-78db2d17933f0765a102f368a6663f057162ddbd";
        src = fetchurl {
          url = https://api.github.com/repos/mlocati/cldr-to-gettext-plural-rules/zipball/78db2d17933f0765a102f368a6663f057162ddbd;
          sha256 = "04f92j2z39hd56kg12p14j0a3jq0ryvy1r0bgg1jf6w064dfha2h";
        };
      };
    };
    "guzzle/common" = {
      targetDir = "Guzzle/Common";
      src = composerEnv.buildZipPackage {
        name = "guzzle-common-2e36af7cf2ce3ea1f2d7c2831843b883a8e7b7dc";
        src = fetchurl {
          url = https://api.github.com/repos/Guzzle3/common/zipball/2e36af7cf2ce3ea1f2d7c2831843b883a8e7b7dc;
          sha256 = "1j00q921ilqi3y2w9pi1a8l0hzy8x0dvvwspbpsi7bjq4d5xivlr";
        };
      };
    };
    "guzzle/http" = {
      targetDir = "Guzzle/Http";
      src = composerEnv.buildZipPackage {
        name = "guzzle-http-1e8dd1e2ba9dc42332396f39fbfab950b2301dc5";
        src = fetchurl {
          url = https://api.github.com/repos/Guzzle3/http/zipball/1e8dd1e2ba9dc42332396f39fbfab950b2301dc5;
          sha256 = "0yimcn9id31yg65xns08bpks0p3sfqcb0rmb35a51vlsql4v5abc";
        };
      };
    };
    "guzzle/parser" = {
      targetDir = "Guzzle/Parser";
      src = composerEnv.buildZipPackage {
        name = "guzzle-parser-6874d171318a8e93eb6d224cf85e4678490b625c";
        src = fetchurl {
          url = https://api.github.com/repos/Guzzle3/parser/zipball/6874d171318a8e93eb6d224cf85e4678490b625c;
          sha256 = "1x0j142012lyrq2wj236jk4j0rrqbxlsr3snk3nvw04xxybyj4db";
        };
      };
    };
    "guzzle/stream" = {
      targetDir = "Guzzle/Stream";
      src = composerEnv.buildZipPackage {
        name = "guzzle-stream-60c7fed02e98d2c518dae8f97874c8f4622100f0";
        src = fetchurl {
          url = https://api.github.com/repos/Guzzle3/stream/zipball/60c7fed02e98d2c518dae8f97874c8f4622100f0;
          sha256 = "0d135id51w2ada4a5padh3xf19ki1aj79bd0c3xv7wi46dhwx22r";
        };
      };
    };
    "guzzlehttp/guzzle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-guzzle-407b0cb880ace85c9b63c5f9551db498cb2d50ba";
        src = fetchurl {
          url = https://api.github.com/repos/guzzle/guzzle/zipball/407b0cb880ace85c9b63c5f9551db498cb2d50ba;
          sha256 = "19m6lgb0blhap3qiqm00slgfc1sc6lzqpbdk47fqg4xgcbn0ymmb";
        };
      };
    };
    "guzzlehttp/promises" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-promises-a59da6cf61d80060647ff4d3eb2c03a2bc694646";
        src = fetchurl {
          url = https://api.github.com/repos/guzzle/promises/zipball/a59da6cf61d80060647ff4d3eb2c03a2bc694646;
          sha256 = "1kpl91fzalcgkcs16lpakvzcnbkry3id4ynx6xhq477p4fipdciz";
        };
      };
    };
    "guzzlehttp/psr7" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-psr7-9f83dded91781a01c63574e387eaa769be769115";
        src = fetchurl {
          url = https://api.github.com/repos/guzzle/psr7/zipball/9f83dded91781a01c63574e387eaa769be769115;
          sha256 = "1xv2zlwfazhb6jykm27cscl5m37hq0ifgdnblk0hhnyr1dm8yrvk";
        };
      };
    };
    "happyworm/jplayer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "happyworm-jplayer-34e55cd7694552447bd0dbc38d886fdc96df0d06";
        src = fetchurl {
          url = https://api.github.com/repos/happyworm/jPlayer/zipball/34e55cd7694552447bd0dbc38d886fdc96df0d06;
          sha256 = "0w8f5m1k7riy483fqnis3qv5kv23xc0sv6l7ny9bkblvry868z2c";
        };
      };
    };
    "james-heinrich/getid3" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "james-heinrich-getid3-6c84298e28eda9a4a206c4d0ef7098e20d3feb58";
        src = fetchurl {
          url = https://api.github.com/repos/JamesHeinrich/getID3/zipball/6c84298e28eda9a4a206c4d0ef7098e20d3feb58;
          sha256 = "16ygj0a4lq1pgm71sf236gzcwni0262jaylkdbx88px3h7v4srji";
        };
      };
    };
    "jeromeetienne/jquery-qrcode" = {
      targetDir = "";
      src = fetchgit {
        name = "jeromeetienne-jquery-qrcode-master";
        url = "https://github.com/jeromeetienne/jquery-qrcode.git";
        rev = "master";
        sha256 = null;
      };
    };
    "kevinrob/guzzle-cache-middleware" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "kevinrob-guzzle-cache-middleware-6952064f7747756b0be7b4c234c0fd7535ea4c8c";
        src = fetchurl {
          url = https://api.github.com/repos/Kevinrob/guzzle-cache-middleware/zipball/6952064f7747756b0be7b4c234c0fd7535ea4c8c;
          sha256 = "0mprmq1qhxc3aglb6gf6xil2iwka08qwav7574n3y99jr1syk9g7";
        };
      };
    };
    "kriswallsmith/assetic" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "kriswallsmith-assetic-e911c437dbdf006a8f62c2f59b15b2d69a5e0aa1";
        src = fetchurl {
          url = https://api.github.com/repos/kriswallsmith/assetic/zipball/e911c437dbdf006a8f62c2f59b15b2d69a5e0aa1;
          sha256 = "1dqk4zvx8fgqf8rb81sj9bipl5431jib2b9kcvxyig5fw99irpf8";
        };
      };
    };
    "krixon/xbmc-php-rpc" = {
      targetDir = "";
      src = fetchgit {
        name = "krixon-xbmc-php-rpc-master";
        url = "https://github.com/krixon/xbmc-php-rpc.git";
        rev = "master";
        sha256 = null;
      };
    };
    "kumailht/responsive-elements" = {
      targetDir = "";
      src = fetchgit {
        name = "kumailht-responsive-elements-master";
        url = "https://github.com/kumailht/responsive-elements.git";
        rev = "master";
        sha256 = null;
      };
    };
    "maennchen/zipstream-php" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "maennchen-zipstream-php-89e0cdb3c9ecabef4da988852003781a7802afb7";
        src = fetchurl {
          url = https://api.github.com/repos/maennchen/ZipStream-PHP/zipball/89e0cdb3c9ecabef4da988852003781a7802afb7;
          sha256 = "1ijcg5b0fjsgycqx0h1kkmh45k9pj2bbzd8qn9z1129gsrzymkj8";
        };
      };
    };
    "mikealmond/musicbrainz" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "mikealmond-musicbrainz-072717cb264c18e3b1eb7bfb2edf2e1e80202dbc";
        src = fetchurl {
          url = https://api.github.com/repos/mikealmond/MusicBrainz/zipball/072717cb264c18e3b1eb7bfb2edf2e1e80202dbc;
          sha256 = "056mdmadxy7rx8l4fssx4zfkh5wr41q32256hg9qajzq5bln5223";
        };
      };
    };
    "moinax/tvdb" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "moinax-tvdb-26f33df9e0ddf9b0b6ba9deeb43f1fa83b483085";
        src = fetchurl {
          url = https://api.github.com/repos/Moinax/TvDb/zipball/26f33df9e0ddf9b0b6ba9deeb43f1fa83b483085;
          sha256 = "1qb2c072lmh6qjfs98p1k7f56mgriay89pixm6qn46r6ar32wky2";
        };
      };
    };
    "mptre/php-soundcloud" = {
      targetDir = "";
      src = fetchgit {
        name = "mptre-php-soundcloud-v2.3.2";
        url = "https://github.com/mptre/php-soundcloud.git";
        rev = "v2.3.2";
        sha256 = "06n19c0ncvh20bbcrc5lcdxj3azr8mybinnhn8zhrd6rj7i1mnw9";
      };
    };
    "needim/noty" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "needim-noty-d03d12f3e712253ef06184b85e5629b1aef43acb";
        src = fetchurl {
          url = https://api.github.com/repos/needim/noty/zipball/d03d12f3e712253ef06184b85e5629b1aef43acb;
          sha256 = "0i8bvsk4f54w4yfj6xgz4w1xw8jl6gmkh1gp320bc8by9rjk1c8w";
        };
      };
    };
    "openid/php-openid" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "openid-php-openid-924f9aa42453cd0f9dba72587b4e2cdf7f4de874";
        src = fetchurl {
          url = https://api.github.com/repos/openid/php-openid/zipball/924f9aa42453cd0f9dba72587b4e2cdf7f4de874;
          sha256 = "1icf6bva1qk9bzkbpl6n0dp53qncckbq6775ffw47rvfsa14yxsa";
        };
      };
    };
    "paragonie/random_compat" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "paragonie-random_compat-84b4dfb120c6f9b4ff7b3685f9b8f1aa365a0c95";
        src = fetchurl {
          url = https://api.github.com/repos/paragonie/random_compat/zipball/84b4dfb120c6f9b4ff7b3685f9b8f1aa365a0c95;
          sha256 = "03nsccdvcb79l64b7lsmx0n8ldf5z3v8niqr7bpp6wg401qp9p09";
        };
      };
    };
    "php-cs-fixer/diff" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "php-cs-fixer-diff-78bb099e9c16361126c86ce82ec4405ebab8e756";
        src = fetchurl {
          url = https://api.github.com/repos/PHP-CS-Fixer/diff/zipball/78bb099e9c16361126c86ce82ec4405ebab8e756;
          sha256 = "082w79q2bipw5iibpw6whihnz2zafljh5bgpfs4qdxmz25n8g00l";
        };
      };
    };
    "php-tmdb/api" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "php-tmdb-api-53925e50c0541b20a24f4cfc89b253b251a236c7";
        src = fetchurl {
          url = https://api.github.com/repos/php-tmdb/api/zipball/53925e50c0541b20a24f4cfc89b253b251a236c7;
          sha256 = "0241qw4pwqacvfxrcdga5xkdm8r6spdnag4752bj65cil7n0s73j";
        };
      };
    };
    "phpmailer/phpmailer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpmailer-phpmailer-dde1db116511aa4956389d75546c5be4c2beb2a6";
        src = fetchurl {
          url = https://api.github.com/repos/PHPMailer/PHPMailer/zipball/dde1db116511aa4956389d75546c5be4c2beb2a6;
          sha256 = "1z2zlpja00m0yc85gx2xnjrzd8clkyi13bgkwdadwii2yprfmcd1";
        };
      };
    };
    "pklauzinski/jscroll" = {
      targetDir = "";
      src = fetchgit {
        name = "pklauzinski-jscroll-v2.3.4";
        url = "https://github.com/pklauzinski/jscroll.git";
        rev = "v2.3.4";
        sha256 = "1gqq9kg31m6rcdsykh51i3mzn6cbq9khszsmzwxk5p7y0l0733nn";
      };
    };
    "psr/http-message" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-message-f6561bf28d520154e4b0ec72be95418abe6d9363";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/http-message/zipball/f6561bf28d520154e4b0ec72be95418abe6d9363;
          sha256 = "195dd67hva9bmr52iadr4kyp2gw2f5l51lplfiay2pv6l9y4cf45";
        };
      };
    };
    "psr/log" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-log-6c001f1daafa3a3ac1d8ff69ee4db8e799a654dd";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/log/zipball/6c001f1daafa3a3ac1d8ff69ee4db8e799a654dd;
          sha256 = "1i351p3gd1pgjcjxv7mwwkiw79f1xiqr38irq22156h05zlcx80d";
        };
      };
    };
    "ralouphie/getallheaders" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ralouphie-getallheaders-5601c8a83fbba7ef674a7369456d12f1e0d0eafa";
        src = fetchurl {
          url = https://api.github.com/repos/ralouphie/getallheaders/zipball/5601c8a83fbba7ef674a7369456d12f1e0d0eafa;
          sha256 = "1axanjwrxcmnh6am7a813j1xqa1cx2jp0gal93dr33wpqq0ys09l";
        };
      };
    };
    "react/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-cache-75494f26b4ef089db9bf8c90b63c296246e099e8";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/cache/zipball/75494f26b4ef089db9bf8c90b63c296246e099e8;
          sha256 = "0yf25cp1vgz1mdg57r45010gc630lm8y43i15cz12dk5i0ghjj6d";
        };
      };
    };
    "react/child-process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-child-process-b81d06daaafb5d7d592b6f7f8b1b7905cdef9ac6";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/child-process/zipball/b81d06daaafb5d7d592b6f7f8b1b7905cdef9ac6;
          sha256 = "1pr0lslspwr3ydmpkrbw5vw7jd0bb9l6apca6g1qqmy2aammawvb";
        };
      };
    };
    "react/dns" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-dns-0f30c6ceb71504d359d51132a97e1703051f1589";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/dns/zipball/0f30c6ceb71504d359d51132a97e1703051f1589;
          sha256 = "0b8cjkapwxiy87av02rql2r6a7hi1rqd1hbp8i3cyfn63dr718pa";
        };
      };
    };
    "react/event-loop" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-event-loop-8bde03488ee897dc6bb3d91e4e17c353f9c5252f";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/event-loop/zipball/8bde03488ee897dc6bb3d91e4e17c353f9c5252f;
          sha256 = "11w0n0zin0ryxklnjgq5pv1pkn3aqh19kvqygwpr6x6bsb2x87bm";
        };
      };
    };
    "react/http" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-http-aac319bd789cbc7b478d42cde2d03596e97e3222";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/http/zipball/aac319bd789cbc7b478d42cde2d03596e97e3222;
          sha256 = "1vdhkzw55a4v9zrfmw1gmvk34iwr5k698rla499bw754kqcxyci6";
        };
      };
    };
    "react/http-client" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-http-client-75ee8a113f156834aaabfe0055e8db531cb4892c";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/http-client/zipball/75ee8a113f156834aaabfe0055e8db531cb4892c;
          sha256 = "042xprfqnmklpg3p64lvby39bmrnzn6mpah3zlrn5hvgzqjgrsaa";
        };
      };
    };
    "react/promise" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-promise-31ffa96f8d2ed0341a57848cbb84d88b89dd664d";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/promise/zipball/31ffa96f8d2ed0341a57848cbb84d88b89dd664d;
          sha256 = "12pz35wc1zy4djkigqikg74fxi88s46fk22hzp5qkyjy829bbj42";
        };
      };
    };
    "react/promise-timer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-promise-timer-35fb910604fd86b00023fc5cda477c8074ad0abc";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/promise-timer/zipball/35fb910604fd86b00023fc5cda477c8074ad0abc;
          sha256 = "0qpx8v1kp0hzmhxzrqmkc2hn0r4d81cbwgg638f7cvxiang55hw5";
        };
      };
    };
    "react/react" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-react-457b6b8a16a37c11278cac0870d6d2ff911c5765";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/react/zipball/457b6b8a16a37c11278cac0870d6d2ff911c5765;
          sha256 = "1wg9wfj8mmyh9mrvmnhka359q903g3vlzfax4php0k9pp3d3cj29";
        };
      };
    };
    "react/socket" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-socket-cf074e53c974df52388ebd09710a9018894745d2";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/socket/zipball/cf074e53c974df52388ebd09710a9018894745d2;
          sha256 = "0hkybxhxxnk3p6c02krvs5zb3mi6w915yarmrkii4763055bfmpj";
        };
      };
    };
    "react/socket-client" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-socket-client-49e730523b73d912e56f7a41f53ed3fc083ae167";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/socket-client/zipball/49e730523b73d912e56f7a41f53ed3fc083ae167;
          sha256 = "0hv1nqx1czrxk7a361axnfwndn041z1z1147f050wcnm2q51gczr";
        };
      };
    };
    "react/stream" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-stream-44dc7f51ea48624110136b535b9ba44fd7d0c1ee";
        src = fetchurl {
          url = https://api.github.com/repos/reactphp/stream/zipball/44dc7f51ea48624110136b535b9ba44fd7d0c1ee;
          sha256 = "0fwrsrpirim4q305jxzrk0f5mga082a598aq7dcpn8rph85i49py";
        };
      };
    };
    "ringcentral/psr7" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ringcentral-psr7-dcd84bbb49b96c616d1dcc8bfb9bef3f2cd53d1c";
        src = fetchurl {
          url = https://api.github.com/repos/ringcentral/psr7/zipball/dcd84bbb49b96c616d1dcc8bfb9bef3f2cd53d1c;
          sha256 = "0vfzkf4b2lcwrrqkbd9gafdhnx2mjww43nawa5lxpxcbw9dgyxx7";
        };
      };
    };
    "rmccue/requests" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "rmccue-requests-87932f52ffad70504d93f04f15690cf16a089546";
        src = fetchurl {
          url = https://api.github.com/repos/rmccue/Requests/zipball/87932f52ffad70504d93f04f15690cf16a089546;
          sha256 = "17cqi6s318dwsc2jb5sslh3gf32a1wy8ap6iq9flhw2yq66k3ns6";
        };
      };
    };
    "robloach/component-installer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "robloach-component-installer-908a859aa7c4949ba9ad67091e67bac10b66d3d7";
        src = fetchurl {
          url = https://api.github.com/repos/RobLoach/component-installer/zipball/908a859aa7c4949ba9ad67091e67bac10b66d3d7;
          sha256 = "19y5sv4k338bihzmm8iac6q43r18vxhmbpvrdhz8jn39r51ampq9";
        };
      };
    };
    "rtheunissen/guzzle-log-middleware" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "rtheunissen-guzzle-log-middleware-6a15b7f71c6fc3f8456abeed530b2f12846f075f";
        src = fetchurl {
          url = https://api.github.com/repos/rtheunissen/guzzle-log-middleware/zipball/6a15b7f71c6fc3f8456abeed530b2f12846f075f;
          sha256 = "1a4xxh98wgsmc0x1690ny1qy2kq7szdpgbiq1kmmsrcdyddbygdh";
        };
      };
    };
    "sabre/dav" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sabre-dav-a9780ce4f35560ecbd0af524ad32d9d2c8954b80";
        src = fetchurl {
          url = https://api.github.com/repos/sabre-io/dav/zipball/a9780ce4f35560ecbd0af524ad32d9d2c8954b80;
          sha256 = "0fps2clcwl61hn16hbii8k3sh0s06gwaysca7wi9c9k0ji2zi21s";
        };
      };
    };
    "sabre/event" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sabre-event-831d586f5a442dceacdcf5e9c4c36a4db99a3534";
        src = fetchurl {
          url = https://api.github.com/repos/sabre-io/event/zipball/831d586f5a442dceacdcf5e9c4c36a4db99a3534;
          sha256 = "1qfbva83cfxxndxddv6y07j6jqmvf3lr7l4wkd1nriirzvxs7p8z";
        };
      };
    };
    "sabre/http" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sabre-http-acccec4ba863959b2d10c1fa0fb902736c5c8956";
        src = fetchurl {
          url = https://api.github.com/repos/sabre-io/http/zipball/acccec4ba863959b2d10c1fa0fb902736c5c8956;
          sha256 = "1bw743yrbzxpi2k18vc5dmq44ms7dpyklwb1krij5bfcln1pp274";
        };
      };
    };
    "sabre/uri" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sabre-uri-ada354d83579565949d80b2e15593c2371225e61";
        src = fetchurl {
          url = https://api.github.com/repos/sabre-io/uri/zipball/ada354d83579565949d80b2e15593c2371225e61;
          sha256 = "05ahxk2xm9slmkjip1zmgbwzlc8czjg48mki7vfpn4j7bahqya57";
        };
      };
    };
    "sabre/vobject" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sabre-vobject-bd500019764e434ff65872d426f523e7882a0739";
        src = fetchurl {
          url = https://api.github.com/repos/sabre-io/vobject/zipball/bd500019764e434ff65872d426f523e7882a0739;
          sha256 = "158cxdljc9k99b4yvg0dfp9v9d8r51faz8mj530lw54sy0w0yj4w";
        };
      };
    };
    "sabre/xml" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sabre-xml-a367665f1df614c3b8fefc30a54de7cd295e444e";
        src = fetchurl {
          url = https://api.github.com/repos/sabre-io/xml/zipball/a367665f1df614c3b8fefc30a54de7cd295e444e;
          sha256 = "0vn4q9a8awzxi0d74lknq3g5jaa20nn80ahcd0gjjzkd447h71i4";
        };
      };
    };
    "scaron/prettyphoto" = {
      targetDir = "";
      src = fetchgit {
        name = "scaron-prettyphoto-3.1.6";
        url = "https://github.com/scaron/prettyphoto.git";
        rev = "3.1.6";
        sha256 = "19yafn0n7hviivida2lw6ag5bbsd7lipd7klcm28z9n4rlp0xdd8";
      };
    };
    "swisnl/jQuery-contextMenu" = {
      targetDir = "";
      src = fetchgit {
        name = "swisnl-jQuery-contextMenu-2.1.0";
        url = "https://github.com/swisnl/jQuery-contextMenu.git";
        rev = "2.1.0";
        sha256 = "0dmaj7v650xpvfnxnyq5gpcir81a8ki4ry0m1ky7qs2ckf4mqjq3";
      };
    };
    "symfony/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-console-e2840bb38bddad7a0feaf85931e38fdcffdb2f81";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/console/zipball/e2840bb38bddad7a0feaf85931e38fdcffdb2f81;
          sha256 = "15krd0lh03zx2hskxvl5wj8aai5kqfwqzd1i7w7pkk25g9vwmdgm";
        };
      };
    };
    "symfony/contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-contracts-d3636025e8253c6144358ec0a62773cae588395b";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/contracts/zipball/d3636025e8253c6144358ec0a62773cae588395b;
          sha256 = "1rnvslypar0fjsawmxcbrzivchj09lfnmxxzkhjqak9j9rpm24wa";
        };
      };
    };
    "symfony/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-a088aafcefb4eef2520a290ed82e4374092a6dff";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/event-dispatcher/zipball/a088aafcefb4eef2520a290ed82e4374092a6dff;
          sha256 = "1b46m2ajd6l5fc5lgijf9rxil0y9pzjhqh1zcih6rzv209qgr8hn";
        };
      };
    };
    "symfony/filesystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-filesystem-e16b9e471703b2c60b95f14d31c1239f68f11601";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/filesystem/zipball/e16b9e471703b2c60b95f14d31c1239f68f11601;
          sha256 = "04x92xn7mivjyirzy20jb94aq2qgqha9cihn9q1mrb03lpaybf4z";
        };
      };
    };
    "symfony/finder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-finder-e45135658bd6c14b61850bf131c4f09a55133f69";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/finder/zipball/e45135658bd6c14b61850bf131c4f09a55133f69;
          sha256 = "087rapvridgksdk52vyf33rcm1ha9m2wki985al650qza5i0wdwd";
        };
      };
    };
    "symfony/http-foundation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-foundation-fa02215233be8de1c2b44617088192f9e8db3512";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/http-foundation/zipball/fa02215233be8de1c2b44617088192f9e8db3512;
          sha256 = "0qh5y195dpaiydm96v28grj67p9nak82kddlq3b14kk4l5inr33c";
        };
      };
    };
    "symfony/options-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-options-resolver-fd4a5f27b7cd085b489247b9890ebca9f3e10044";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/options-resolver/zipball/fd4a5f27b7cd085b489247b9890ebca9f3e10044;
          sha256 = "0c5l47kpv2bdn0jc2zmr04maa3b48b70hivnr2m97j2pd5cvc7ky";
        };
      };
    };
    "symfony/polyfill-ctype" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-ctype-82ebae02209c21113908c229e9883c419720738a";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-ctype/zipball/82ebae02209c21113908c229e9883c419720738a;
          sha256 = "1p3grd56c4agrv3v5lfnsi0ryghha7f0jx5hqs2lj7hvcx1fzam5";
        };
      };
    };
    "symfony/polyfill-mbstring" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-mbstring-fe5e94c604826c35a32fa832f35bd036b6799609";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-mbstring/zipball/fe5e94c604826c35a32fa832f35bd036b6799609;
          sha256 = "18n89mqn3nw62gmd10h63ci8s45jya3kcvx5g0pxdnm7grxn0ykr";
        };
      };
    };
    "symfony/polyfill-php70" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php70-bc4858fb611bda58719124ca079baff854149c89";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-php70/zipball/bc4858fb611bda58719124ca079baff854149c89;
          sha256 = "0b3cmb7bmixwqqjclzkah6aq03ic00g7rnla3scq100y7fc5za0n";
        };
      };
    };
    "symfony/polyfill-php72" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php72-ab50dcf166d5f577978419edd37aa2bb8eabce0c";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-php72/zipball/ab50dcf166d5f577978419edd37aa2bb8eabce0c;
          sha256 = "0a2qn3n12kzd79g08aazcjv6zd834zrrlxcskhcp5vag8z46psgg";
        };
      };
    };
    "symfony/process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-process-a9c4dfbf653023b668c282e4e02609d131f4057a";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/process/zipball/a9c4dfbf653023b668c282e4e02609d131f4057a;
          sha256 = "1ch065l0dnsfmpcfzqvqga1bams5qkbq20aj6kj41v3irm03wq4y";
        };
      };
    };
    "symfony/routing" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-routing-ff11aac46d6cb8a65f2855687bb9a1ac9d860eec";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/routing/zipball/ff11aac46d6cb8a65f2855687bb9a1ac9d860eec;
          sha256 = "0s0ipgmccz6l35vw7f2bqr9q9g671isj1bm3fg62l1vq0xqnhwil";
        };
      };
    };
    "symfony/stopwatch" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-stopwatch-b1a5f646d56a3290230dbc8edf2a0d62cda23f67";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/stopwatch/zipball/b1a5f646d56a3290230dbc8edf2a0d62cda23f67;
          sha256 = "1yddg2dmlaybqq0vxn4k7ipp85gm7dscfx31y6a9baayyxpq5gm8";
        };
      };
    };
    "tightenco/collect" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "tightenco-collect-6add72fba3816232c71a3338081ed8cbef41974d";
        src = fetchurl {
          url = https://api.github.com/repos/tightenco/collect/zipball/6add72fba3816232c71a3338081ed8cbef41974d;
          sha256 = "0pppa4nkhqwsrjb7gjr3dz2vi2vh0iw4wqaq8gya4658n9hyykch";
        };
      };
    };
    "vakata/jstree" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "vakata-jstree-c9d7c1425f2272c5400536fa631eba8657522ecf";
        src = fetchurl {
          url = https://api.github.com/repos/vakata/jstree/zipball/c9d7c1425f2272c5400536fa631eba8657522ecf;
          sha256 = "0p1scmwlkrms8q9cpxwwhnlq19bwmj48cd47l8siyzaj64fy3za1";
        };
      };
    };
    "wikimedia/composer-merge-plugin" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "wikimedia-composer-merge-plugin-81c6ac72a24a67383419c7eb9aa2b3437f2ab100";
        src = fetchurl {
          url = https://api.github.com/repos/wikimedia/composer-merge-plugin/zipball/81c6ac72a24a67383419c7eb9aa2b3437f2ab100;
          sha256 = "0nfc7vwffpd1yskp3dj1vl2774ik3amxbsdv5pfvq6ibk9lkwcq4";
        };
      };
    };
    "xdan/datetimepicker" = {
      targetDir = "";
      src = fetchgit {
        name = "xdan-datetimepicker-2.4.5";
        url = "https://github.com/xdan/datetimepicker.git";
        rev = "2.4.5";
        sha256 = "0xhr5vcxhxfgm1gmflcggwqm9sg07ipaq20b1w5j3cl1dyms03fx";
      };
    };
  };
  devPackages = {};
in
composerEnv.buildPackage {
  inherit packages devPackages noDev;
  name = "ampache-ampache";
  src = ./.;
  executable = false;
  symlinkDependencies = false;
  meta = {
    homepage = http://ampache.org;
    license = "AGPL-3.0";
  };
}