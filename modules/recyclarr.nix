{
  flake.modules.nixos.recyclarr =
    { config, ... }:
    let
      allProfiles = [
        { name = "HD Bluray + WEB"; }
        { name = "UHD Bluray + WEB"; }
        { name = "Remux + WEB 1080p"; }
        { name = "Remux + WEB 2160p"; }
      ];
      uhdProfiles = [
        { name = "UHD Bluray + WEB"; }
        { name = "Remux + WEB 2160p"; }
      ];
    in
    {
      services.recyclarr = {
        enable = true;

        configuration = {
          radarr.radarr = {
            base_url = "http://127.0.0.1:7878";
            api_key._secret = config.sops.secrets."services/recyclarr/radarr-api-key".path;
            delete_old_custom_formats = true;

            media_naming = {
              folder = "jellyfin-tmdb";
              movie = {
                rename = true;
                standard = "jellyfin-tmdb";
              };
            };

            quality_definition.type = "movie";

            quality_profiles = [
              {
                name = "HD Bluray + WEB";
                reset_unmatched_scores.enabled = true;
                upgrade = {
                  allowed = true;
                  until_quality = "Bluray-1080p";
                  until_score = 10000;
                };
                min_format_score = 0;
                qualities = [
                  { name = "Bluray-1080p"; }
                  {
                    name = "WEB 1080p";
                    qualities = [
                      "WEBDL-1080p"
                      "WEBRip-1080p"
                    ];
                  }
                  { name = "Bluray-720p"; }
                  {
                    name = "WEB 720p";
                    qualities = [
                      "WEBDL-720p"
                      "WEBRip-720p"
                    ];
                  }
                ];
              }
              {
                name = "UHD Bluray + WEB";
                reset_unmatched_scores.enabled = true;
                upgrade = {
                  allowed = true;
                  until_quality = "Bluray-2160p";
                  until_score = 10000;
                };
                min_format_score = 0;
                qualities = [
                  { name = "Bluray-2160p"; }
                  {
                    name = "WEB 2160p";
                    qualities = [
                      "WEBDL-2160p"
                      "WEBRip-2160p"
                    ];
                  }
                  { name = "Bluray-1080p"; }
                  {
                    name = "WEB 1080p";
                    qualities = [
                      "WEBDL-1080p"
                      "WEBRip-1080p"
                    ];
                  }
                ];
              }
              {
                name = "Remux + WEB 1080p";
                reset_unmatched_scores.enabled = true;
                upgrade = {
                  allowed = true;
                  until_quality = "Remux-1080p";
                  until_score = 10000;
                };
                min_format_score = 0;
                qualities = [
                  { name = "Remux-1080p"; }
                  {
                    name = "WEB 1080p";
                    qualities = [
                      "WEBDL-1080p"
                      "WEBRip-1080p"
                    ];
                  }
                  { name = "Bluray-1080p"; }
                  {
                    name = "WEB 720p";
                    qualities = [
                      "WEBDL-720p"
                      "WEBRip-720p"
                    ];
                  }
                ];
              }
              {
                name = "Remux + WEB 2160p";
                reset_unmatched_scores.enabled = true;
                upgrade = {
                  allowed = true;
                  until_quality = "Remux-2160p";
                  until_score = 10000;
                };
                min_format_score = 0;
                qualities = [
                  { name = "Remux-2160p"; }
                  {
                    name = "WEB 2160p";
                    qualities = [
                      "WEBDL-2160p"
                      "WEBRip-2160p"
                    ];
                  }
                  { name = "Bluray-2160p"; }
                  {
                    name = "WEB 1080p";
                    qualities = [
                      "WEBDL-1080p"
                      "WEBRip-1080p"
                    ];
                  }
                ];
              }
            ];

            custom_formats = [
              # Misc
              {
                trash_ids = [
                  "e7718d7a3ce595f289bfee26adc178f5" # Repack/Proper
                  "ae43b294509409a6a13919dedd4764c4" # Repack2
                  "5caaaa1c08c1742aa4342d8c4cc463f2" # Repack3
                ];
                assign_scores_to = allProfiles;
              }

              # Unwanted
              {
                trash_ids = [
                  "ed38b889b31be83fda192888e2286d83" # BR-DISK
                  "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
                  "90a6f9a284dff5103f6346090e6280c8" # LQ
                  "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
                  "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
                  "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
                  "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
                  "0a3f082873eb454bde444150b70253cc" # Extras
                  "712d74cd88bceb883ee32f773656b1f5" # Sing-Along Versions
                  "cae4ca30163749b891686f95532519bd" # AV1
                ];
                assign_scores_to = allProfiles;
              }

              # Streaming Services (score)
              {
                trash_ids = [
                  "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE
                  "16622a6911d1ab5d5b8b713d5b0036d4" # CRiT
                  "2a6039655313bf5dab1e43523b62c374" # MA
                ];
                assign_scores_to = allProfiles;
              }

              # Streaming Services (no score)
              {
                trash_ids = [
                  "b3b3a6ac74ecbd56bcdbefa4799fb9df" # AMZN
                  "40e9380490e748672c2522eaaeb692f7" # ATVP
                  "84272245b2988854bfb76a16e60baea5" # DSNP
                  "509e5f41146e278f9eab1ddaceb34515" # HBO
                  "5763d1b0ce84aff3b21038eea8e9b8ad" # HMAX
                  "526d445d4c16214309f0fd2b3be18a89" # Hulu
                  "e0ec9672be6cac914ffad34a6b077209" # iT
                  "6a061313d22e51e0f25b7cd4dc065233" # MAX
                  "170b1d363bd8516fbf3a3eb05d4faff6" # NF
                  "c9fd353f8f5f1baf56dc601c4cb29920" # PCOK
                  "e36a0ba1bc902b26ee40818a1d59b8bd" # PMTP
                  "c2863d2a50c9acad1fb50e53ece60817" # STAN
                ];
                assign_scores_to = allProfiles;
              }

              # HQ Release Groups - HD Bluray
              {
                trash_ids = [
                  "ed27ebfef2f323e964fb1f61391bcb35" # HD Bluray Tier 01
                  "c20c8647f2746a1f4c4262b0fbbeeeae" # HD Bluray Tier 02
                  "5608c71bcebba0a5e666223bae8c9227" # HD Bluray Tier 03
                ];
                assign_scores_to = [
                  { name = "HD Bluray + WEB"; }
                ];
              }

              # HQ Release Groups - UHD Bluray
              {
                trash_ids = [
                  "4d74ac4c4db0b64bff6ce0cffef99bf0" # UHD Bluray Tier 01
                  "a58f517a70193f8e578056642178419d" # UHD Bluray Tier 02
                  "e71939fae578037e7aed3ee219bbe7c1" # UHD Bluray Tier 03
                ];
                assign_scores_to = [
                  { name = "UHD Bluray + WEB"; }
                ];
              }

              # HQ Release Groups - Remux
              {
                trash_ids = [
                  "3a3ff47579026e76d6504ebea39390de" # Remux Tier 01
                  "9f98181fe5a3fbeb0cc29340da2a468a" # Remux Tier 02
                  "8baaf0b3142bf4d94c42a724f034e27a" # Remux Tier 03
                ];
                assign_scores_to = [
                  { name = "Remux + WEB 1080p"; }
                  { name = "Remux + WEB 2160p"; }
                ];
              }

              # HQ Release Groups - WEB (all profiles)
              {
                trash_ids = [
                  "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
                  "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
                  "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03
                ];
                assign_scores_to = allProfiles;
              }

              # UHD-specific: HDR
              {
                trash_ids = [
                  "493b6d1dbec3c3364c59d7607f7e3405" # HDR
                ];
                assign_scores_to = uhdProfiles;
              }

              # UHD-specific: DV (w/o HDR fallback) - penalize
              {
                trash_ids = [
                  "923b6abef9b17f937fab56cfcf89e1f1" # DV (w/o HDR fallback)
                ];
                assign_scores_to = uhdProfiles;
              }

              # UHD-specific: SDR - block
              {
                trash_ids = [
                  "9c38ebb7384dada637be8899efa68e6f" # SDR
                ];
                assign_scores_to = uhdProfiles;
              }
            ];
          };

          sonarr.sonarr = {
            base_url = "http://127.0.0.1:8989";
            api_key._secret = config.sops.secrets."services/recyclarr/sonarr-api-key".path;
            delete_old_custom_formats = true;

            media_naming = {
              series = "jellyfin-tvdb";
              season = "default";
              episodes = {
                rename = true;
                standard = "default";
                daily = "default";
                anime = "default";
              };
            };

            quality_definition.type = "series";

            quality_profiles = [
              {
                name = "WEB-1080p";
                reset_unmatched_scores.enabled = true;
                upgrade = {
                  allowed = true;
                  until_quality = "WEB 1080p";
                  until_score = 10000;
                };
                min_format_score = 0;
                quality_sort = "top";
                qualities = [
                  {
                    name = "WEB 1080p";
                    qualities = [
                      "WEBDL-1080p"
                      "WEBRip-1080p"
                    ];
                  }
                ];
              }
              {
                name = "WEB-2160p";
                reset_unmatched_scores.enabled = true;
                upgrade = {
                  allowed = true;
                  until_quality = "WEB 2160p";
                  until_score = 10000;
                };
                min_format_score = 0;
                quality_sort = "top";
                qualities = [
                  {
                    name = "WEB 2160p";
                    qualities = [
                      "WEBDL-2160p"
                      "WEBRip-2160p"
                    ];
                  }
                ];
              }
            ];

            custom_formats = [
              # Unwanted
              {
                trash_ids = [
                  "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                  "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                  "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                  "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
                  "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
                  "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
                ];
                assign_scores_to = [
                  { name = "WEB-1080p"; }
                  { name = "WEB-2160p"; }
                ];
              }

              # Misc
              {
                trash_ids = [
                  "ec8fa7296b64e8cd390a1600981f3923" # Repack/Proper
                  "eb3d5cc0a2be0db205fb823640db6a3c" # Repack v2
                  "44e7c4de10ae50265753082e5dc76047" # Repack v3
                ];
                assign_scores_to = [
                  { name = "WEB-1080p"; }
                  { name = "WEB-2160p"; }
                ];
              }

              # Streaming Services
              {
                trash_ids = [
                  "d660701077794679fd59e8bdf4ce3a29" # AMZN
                  "f67c9ca88f463a48346062e8ad07713f" # ATVP
                  "77a7b25585c18af08f60b1547bb9b4fb" # CC
                  "36b72f59f4ea20aad9316f475f2d9fbb" # DCU
                  "dc5f2bb0e0262155b5fedd0f6c5d2b55" # DSCP
                  "89358767a60cc28783cdc3d0be9388a4" # DSNP
                  "7a235133c87f7da4c8cccceca7e3c7a6" # HBO
                  "a880d6abc21e7c16884f3ae393f84179" # HMAX
                  "f6cce30f1733d5c8194222a7507909bb" # Hulu
                  "0ac24a2a68a9700bcb7eeca8e5cd644c" # iT
                  "81d1fbf600e2540cee87f3a23f9d3c1c" # MAX
                  "d34870697c9db575f17700212167be23" # NF
                  "1656adc6d7bb2c8cca6acfb6592db421" # PCOK
                  "c67a75ae4a1715f2bb4d492755ba4195" # PMTP
                  "ae58039e1319178e6be73caab5c42166" # SHO
                  "1efe8da11bfd74fbbcd4d8117ddb9213" # STAN
                  "9623c5c9cac8e939c1b9aedd32f640bf" # SYFY
                ];
                assign_scores_to = [
                  { name = "WEB-1080p"; }
                  { name = "WEB-2160p"; }
                ];
              }

              # Streaming Boost
              {
                trash_ids = [
                  "218e93e5702f44a68ad9e3c6ba87d2f0" # HD Streaming Boost
                ];
                assign_scores_to = [
                  { name = "WEB-1080p"; }
                  { name = "WEB-2160p"; }
                ];
              }
              {
                trash_ids = [
                  "43b3cf48cb385cd3eac608ee6bca7f09" # UHD Streaming Boost
                ];
                assign_scores_to = [
                  { name = "WEB-2160p"; }
                ];
              }

              # HQ Source Groups
              {
                trash_ids = [
                  "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                  "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                  "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                  "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene
                ];
                assign_scores_to = [
                  { name = "WEB-1080p"; }
                  { name = "WEB-2160p"; }
                ];
              }

              # UHD-specific: HDR
              {
                trash_ids = [
                  "505d871304820ba7106b693be6fe4a9e" # HDR
                ];
                assign_scores_to = [
                  { name = "WEB-2160p"; }
                ];
              }

              # UHD-specific: DV (w/o HDR fallback) - penalize
              {
                trash_ids = [
                  "9b27ab6498ec0f31a3353992e19434ca" # DV (w/o HDR fallback)
                ];
                assign_scores_to = [
                  { name = "WEB-2160p"; }
                ];
              }

              # UHD-specific: SDR - block
              {
                trash_ids = [
                  "2016d1676f5ee13a5b7257ff86ac9a93" # SDR
                ];
                assign_scores_to = [
                  { name = "WEB-2160p"; }
                ];
              }
            ];
          };
        };
      };

      sops.secrets."services/recyclarr/radarr-api-key" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
      };

      sops.secrets."services/recyclarr/sonarr-api-key" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
      };
    };
}
