# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ config, ... }:

{
  services.archivebox = {
    enable = true;
    archivePath = "${config.xdg.userDirs.documents}/ArchiveBox";

    jobs.art = {
      links = [
        "https://www.davidrevoy.com/"
        "https://www.youtube.com/c/ronillust"
      ];
      startAt = "weekly";
    };
  };

  test.stubs.archivebox = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/archivebox-job-art.service
    assertFileExists home-files/.config/systemd/user/archivebox-job-art.timer
  '';
}
