{
  configurations.nixos.mimir.module = {
    services.nfs.server.exports = ''
      /srv/archive/games/osu 10.0.10.11(rw,sync,no_subtree_check)
      /srv/media/music 10.0.10.11(rw,sync,no_subtree_check,all_squash,anonuid=406,anongid=406) 10.0.10.12(ro,sync,no_subtree_check,all_squash,anonuid=406,anongid=406)
    '';
  };
}
